//
//  GlassEntity.swift
//  AttachmentsEverywhere
//
//  Created by Elijah Santos on 8/10/24.
//

import Foundation
import RealityKit
import Synchronization

internal final class GlassEntity: Entity {
    private actor MaterialLoader {
        private var material: ShaderGraphMaterial? = nil
        
        func load() async throws -> ShaderGraphMaterial {
            // TODO: make a better material than this
            if material == nil {
                // framework error if not in bundle; force unwrap ok
                let sceneURL = Bundle.module.url(forResource: "GlassMaterial", withExtension: "usda")!
                material = try await ShaderGraphMaterial(named: "/Root/Glass", from: sceneURL)
                material!.faceCulling = .none
            }
            return material!
        }
    }
    
    private static let glassLoader = MaterialLoader()
    
    internal var cornerRadius: Float = 0.0
    required init() {}
    convenience init(width: Float, height: Float, cornerRadius: Float) async throws {
        self.init()
        self.components[ModelComponent.self] = .init(
            mesh: .generatePlane(width: width, height: height, cornerRadius: cornerRadius),
            materials: [try await Self.glassLoader.load()])
        self.cornerRadius = cornerRadius
    }
}
