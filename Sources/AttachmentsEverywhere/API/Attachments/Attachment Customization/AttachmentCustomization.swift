//
//  AttachmentCustomization.swift
//  AttachmentsEverywhere
//
//  Created by Elijah Santos on 8/11/24.
//

import Foundation
import CoreGraphics

public struct AttachmentCustomization: Sendable {
    var backgroundType: GlassBackgroundType
    var tapResponder: (@MainActor (CGPoint) -> Void)?
    
    static let `default`: AttachmentCustomization = .init(
        backgroundType: .roundedRectangle(cornerRadius: 20),
        tapResponder: nil)
}
