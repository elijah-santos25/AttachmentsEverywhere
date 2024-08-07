//
//  RealityViewAttachments.swift
//  AttachmentsEverywhere
//
//  Created by Elijah Santos on 8/9/24.
//

import Foundation
import SwiftUI
import RealityKit

#if !os(visionOS)

@MainActor
internal struct RealityViewAttachmentsBacking {
    internal init() {
        self.metersPerRenderedPx = 0
        self.entities = [:]
        self.imageGenerators = [:]
        self.onChange = {}
    }
    
    internal init(
        metersPerRenderedPx: Float,
        views: [AnyHashable : (AnyView, AttachmentCustomization)],
        onChange: @escaping () -> Void
    ) async {
        self.metersPerRenderedPx = metersPerRenderedPx
        self.entities = [:]
        self.imageGenerators = [:]
        self.onChange = onChange
        
        await createAttachments(views)
    }
    
    private let onChange: () -> Void
    private let metersPerRenderedPx: Float
    private var entities: [AnyHashable: ViewAttachmentEntity]
    private var imageGenerators: [AnyHashable: ImageGenerator<AnyView>]
    
    public func entity(for id: some Hashable) -> ViewAttachmentEntity? {
        return entities[id]
    }
    
    private mutating func createAttachments(_ views: AttachmentContent) async {
        for (id, (view, customization)) in views {
            do {
                let imgGen = ImageGenerator { view }
                guard let img = imgGen.cgImage() else {
                    print("[AttachmentsEverywhere] warning: failed to create image for view with id \(id)")
                    continue
                }
                imageGenerators[id] = imgGen
                entities[id] = try await createEntity(id: id, img: img, customization: customization)
                imgGen.subscribe { [onChange] in
                    onChange()
                }
            } catch {
                print("[AttachmentsEverywhere] warning: failed to create entity for attachment " +
                      "with ID \(id): \(error.localizedDescription)")
            }
        }
    }
    
    private func bounds(for image: CGImage) -> BoundingBox {
        BoundingBox(
            min: .zero,
            max: .init(
                x: Float(image.width) * metersPerRenderedPx,
                y: Float(image.height) * metersPerRenderedPx,
                z: 0))
    }

    private func createEntity(id: AnyHashable, img: CGImage, customization: AttachmentCustomization) async throws -> ViewAttachmentEntity {
        return try await ViewAttachmentEntity(
            id: id,
            image: img,
            bounds: bounds(for: img),
            customization: customization
        )
    }
    
    internal var keys: some Collection<AnyHashable> {
        entities.keys
    }
    
    internal mutating func regenerateAttachments() async throws {
        for (id, generator) in imageGenerators {
            do {
                guard let img = generator.cgImage() else {
                    print("[AttachmentsEverywhere] warning: failed to recreate image for view with id \(id)")
                    continue
                }
                try await entities[id]?.updateAttachment(image: img, bounds: bounds(for: img))
            } catch {
                print("[AttachmentsEverywhere] warning: failed to update entity for attachment " +
                      "with ID \(id): \(error.localizedDescription)")
            }
        }
    }
    
    internal mutating func insertAttachments(_ new: AttachmentContent) async {
        await createAttachments(new)
    }
    
    internal mutating func removeAttachments(
        forKeys keys: some Collection<AnyHashable>,
        from content: inout RealityViewCameraContent
    ) {
        for key in keys {
            if let entity = entities[key] {
                content.remove(entity)
            }
            entities.removeValue(forKey: key)
            imageGenerators.removeValue(forKey: key)
        }
    }
    
    internal func collection(excluding keys: [AnyHashable] = []) -> RealityViewAttachments {
        return .init(entities: self.entities.filter { !keys.contains($0.key) })
    }
}

#endif
