//
//  ViewAttachmentComponent.swift
//  AttachmentsEverywhere
//
//  Created by Elijah Santos on 8/9/24.
//

import Foundation
import SwiftUI
import RealityKit

#if !os(visionOS)

public struct ViewAttachmentComponent: TransientComponent, Identifiable {
    internal init(
        id: AnyHashable,
        bounds: BoundingBox,
        tapResponder: (@MainActor (CGPoint) -> Void)?
    ) {
        ViewAttachmentComponent.registration
        
        self.id = id
        self.bounds = bounds
        self.tapResponder = tapResponder
    }
    
    public internal(set) var id: AnyHashable
    public internal(set) var bounds: BoundingBox
    internal var tapResponder: (@MainActor (CGPoint) -> Void)?
    
    private static let registration: Void = {
        Self.registerComponent()
    }()
}

#endif
