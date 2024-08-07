//
//  ViewAttachmentEntity.swift
//  AttachmentsEverywhere
//
//  Created by Elijah Santos on 8/9/24.
//

import Foundation
import SwiftUI
import RealityKit

#if !os(visionOS)

public final class ViewAttachmentEntity: Entity {
    private enum CreateError: Int, Error {
        case missingCGImage
    }
    
    public required init() {
        super.init()
        attachment = .init(id: 0, bounds: .empty, tapResponder: nil)
    }
    
    private var glass: GlassEntity? = nil
    
    internal init(id: AnyHashable, image: CGImage?, bounds: BoundingBox, customization: AttachmentCustomization) async throws {
        guard let image else {
            throw CreateError.missingCGImage
        }
        
        super.init()
        
        attachment = ViewAttachmentComponent(
            id: id,
            bounds: bounds,
            tapResponder: customization.tapResponder)
        
        let plane = MeshResource.generatePlane(width: bounds.extents.x, height: bounds.extents.y)
        let tex = try await TextureResource(
            image: image,
            options: .init(semantic: .color))
        var mat = RealityKit.UnlitMaterial(texture: tex)
        
        // workaround to make transparency work in rendered view image
        // only works with tintColor, not color.tintColor for some reason
        mat.tintColor = .white.withAlphaComponent(0.999)
        components.set(ModelComponent(mesh: plane, materials: [mat]))
        
        components.set(InputTargetComponent())
        components.set(CollisionComponent(
            shapes: [.generateBox(
                width: bounds.extents.x,
                height: bounds.extents.y,
                depth: 0.01)],
            mode: .trigger,
            filter: .default))
        
        switch customization.backgroundType {
        case .none:
            // do not create glass background
            break
        case .capsule:
            let glass = try await GlassEntity(
                width: bounds.extents.x,
                height: bounds.extents.y,
                cornerRadius: bounds.extents.y)
            self.addChild(glass)
            glass.setPosition(.init(x: 0, y: 0, z: -0.01), relativeTo: self)
            self.glass = glass
        case .roundedRectangle(let cornerRadius):
            let glass = try await GlassEntity(
                width: bounds.extents.x,
                height: bounds.extents.y,
                cornerRadius: Float(cornerRadius) * (bounds.extents.y / (Float(image.height) / ImageGenerator_renderScale)))
            self.addChild(glass)
            glass.setPosition(.init(x: 0, y: 0, z: -0.01), relativeTo: self)
            self.glass = glass
        }
    }
    
    public private(set) var attachment: ViewAttachmentComponent {
        get {
            self.components[ViewAttachmentComponent.self]!
        }
        set {
            self.components[ViewAttachmentComponent.self] = newValue
        }
    }
    
    internal func updateAttachment(image: CGImage, bounds: BoundingBox) async throws {
        let plane = MeshResource.generatePlane(width: bounds.extents.x, height: bounds.extents.y)
        let tex = try await TextureResource(
            image: image,
            options: .init(semantic: .color))
        var mat = RealityKit.UnlitMaterial(texture: tex)
        if bounds != attachment.bounds, let glass {
            // size changed; replace glass
            let newglass = try await GlassEntity(
                width: bounds.extents.x,
                height: bounds.extents.y,
                cornerRadius: glass.cornerRadius)
            self.addChild(newglass)
            self.removeChild(glass)
            newglass.setPosition(.init(x: 0, y: 0, z: -0.01), relativeTo: self)
            self.glass = newglass
        }
        mat.tintColor = .white.withAlphaComponent(0.999)
        components[ModelComponent.self] = .init(mesh: plane, materials: [mat])
        self.attachment.bounds = bounds
    }
}

#endif
