//
//  AttachableRealityView.swift
//  AttachmentsEverywhere
//
//  Created by Elijah Santos on 8/7/24.
//

#if !os(visionOS)

import SwiftUI
import RealityKit

/// Replicates (to the extent possible) the attachments functionality of `RealityView` on visionOS.
///
/// Use as you would a `RealityView`. On visionOS, `AttachableRealityView` is a typealias for `RealityView`.
@MainActor
public struct AttachableRealityView<Placeholder: View>: View {
    private enum AttachmentUpdateState {
        case notInProgress, preUpdate, postUpdate
    }
    private let make: @MainActor (inout RealityViewCameraContent, RealityViewAttachments) async -> Void
    private let update: (@MainActor (inout RealityViewCameraContent, RealityViewAttachments) -> Void)?
    private let placeholder: Placeholder?
    private let attachments: () -> AttachmentContent
    
    @Environment(\.attachmentPointsPerMeter) private var pointsPerMeter
    @StateObject private var updator = Updator()
    @State private var n = 0
    @State private var attachmentUpdateState = AttachmentUpdateState.notInProgress
    @State private var cachedAttachments: RealityViewAttachmentsBacking? = nil
    
    public init(
        make: @escaping @MainActor (inout RealityViewCameraContent, RealityViewAttachments) async -> Void,
        update: (@MainActor (inout RealityViewCameraContent, RealityViewAttachments) -> Void)? = nil,
        @AttachmentContentBuilder attachments: @escaping () -> AttachmentContent
    ) where Placeholder == Never {
        self.make = make
        self.update = update
        self.placeholder = nil
        self.attachments = attachments
    }
    
    public init(
        make: @escaping @MainActor (inout RealityViewCameraContent, RealityViewAttachments) async -> Void,
        update: (@MainActor (inout RealityViewCameraContent, RealityViewAttachments) -> Void)? = nil,
        @ViewBuilder placeholder: () -> Placeholder,
        @AttachmentContentBuilder attachments: @escaping () -> AttachmentContent
    ) {
        self.make = make
        self.update = update
        self.placeholder = placeholder()
        self.attachments = attachments
    }
    
    // TODO: reimplement non-attachment initializers, for convenience
    
    private func createAttachments() async {
        self.cachedAttachments = await RealityViewAttachmentsBacking(
            metersPerRenderedPx: 1 / (pointsPerMeter * ImageGenerator_renderScale),
            views: attachments()) {
                Task { @MainActor in
                    do {
                        var attachments = cachedAttachments
                        try await attachments?.regenerateAttachments()
                        self.cachedAttachments = attachments
                        self.updator.forceViewUpdate()
                    } catch {
                        print("[AttachmentsEverywhere] warning: failed to update attachments: \(error.localizedDescription)")
                    }
                }
            }
    }
    
    private func updateNewAndRemovedAttachments(
        new: AttachmentContent,
        cached: RealityViewAttachmentsBacking,
        content: inout RealityViewCameraContent
    ) -> RealityViewAttachments? {
        if attachmentUpdateState == .postUpdate {
            // attachments now loaded; continue update with new attachments
            DispatchQueue.main.async {
                attachmentUpdateState = .notInProgress
            }
            return cached.collection()
        }
        let newPairs = new.filter { !cached.keys.contains($0.key) }
        let removedKeys = cached.keys.filter { !new.keys.contains($0) }
        if !removedKeys.isEmpty {
            self.cachedAttachments?.removeAttachments(forKeys: removedKeys, from: &content)
        }
        
        if !newPairs.isEmpty {
            Task { @MainActor [newPairs] in
                attachmentUpdateState = .preUpdate
                var c = self.cachedAttachments
                await c?.insertAttachments(newPairs)
                self.cachedAttachments = c
                updator.forceViewUpdate()
                attachmentUpdateState = .postUpdate
            }
            // defer update until attachments loaded
            return nil
        }
        // no attachments to load; proceed with update
        return cached.collection(excluding: removedKeys)
    }
    
    private func doUpdate(_ content: inout RealityViewCameraContent) {
        _ = updator.updateCount
        guard let cachedAttachments else { return }
        let newAttachments = attachments()
        if let pushedAttachments = updateNewAndRemovedAttachments(
            new: newAttachments,
            cached: cachedAttachments,
            content: &content
        ) {
            update?(&content, pushedAttachments)
        }
    }
    
    public var body: some View {
        Group {
            if let placeholder {
                RealityView { content in
                    _ = updator.updateCount
                    await createAttachments()
                    await make(&content, cachedAttachments!.collection())
                } update: { content in
                    doUpdate(&content)
                } placeholder: {
                    placeholder
                }
            } else {
                RealityView { content in
                    _ = updator.updateCount
                    await createAttachments()
                    await make(&content, cachedAttachments!.collection())
                } update: { content in
                    doUpdate(&content)
                }
                
            }
        }
        .gesture(
            SpatialTapGesture()
                .targetedToEntity(where: .has(ViewAttachmentComponent.self))
                .onEnded { value in
                    guard let entity = value.entity as? ViewAttachmentEntity,
                          let tapPoint3D = value.hitTest(
                                point: value.location,
                                in: .local).first?.position
                    else {
                        return
                    }
                    let attachmentOrientation = entity.orientation(relativeTo: nil)
                    let attachmentPosition = entity.position(relativeTo: nil)
                    let xyAlignedPoint = simd_act(simd_negate(attachmentOrientation), tapPoint3D - attachmentPosition)
                    let resultantPoint = CGPoint(
                        x: Double(((xyAlignedPoint.x + (entity.attachment.bounds.extents.x / 2)) * pointsPerMeter)) - Attachment_padding,
                        y: Double((entity.attachment.bounds.extents.y - xyAlignedPoint.y - (entity.attachment.bounds.extents.y / 2)) * pointsPerMeter) - Attachment_padding)
                    entity.attachment.tapResponder?(resultantPoint)
                }
        )
        .overlay {
            // force swiftui to do a view update when updator changes
            Text(updator.updateCount.description)
                .hidden()
        }
    }
}

#endif
