//
//  GlassBackgroundType.swift
//  AttachmentsEverywhere
//
//  Created by Elijah Santos on 8/11/24.
//

import Foundation

/// Describes the type of glass background placed behind an attachment.
///
/// - SeeAlso: `Attachment.glassBackgroundStyle(_:)`
public enum GlassBackgroundType: Hashable, Sendable {
    /// A capsule (flat top and bottom edges, circular left and right).
    case capsule
    
    /// A rounded rectangle.
    ///
    /// `cornerRadius` is defined in points.
    case roundedRectangle(cornerRadius: Double)
    
    /// No glass background.
    case none
}
