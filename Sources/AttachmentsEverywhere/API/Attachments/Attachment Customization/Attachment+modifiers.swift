//
//  Attachment+modifiers.swift
//  AttachmentsEverywhere
//
//  Created by Elijah Santos on 8/11/24.
//

import Foundation
import SwiftUI

#if !os(visionOS)

extension Attachment {
    internal func withConfigurationValue<T>(
        _ kp: WritableKeyPath<AttachmentCustomization, T>,
        setTo newValue: T
    ) -> Attachment {
        var copy = self
        copy.configuration[keyPath: kp] = newValue
        return copy
    }
    
    public func glassBackgroundStyle(_ style: GlassBackgroundType) -> Self {
        self.withConfigurationValue(\.backgroundType, setTo: style)
    }
    
    public func onTapGesture(
        _ action: @MainActor @escaping (_ location: CGPoint) -> Void
    ) -> Self {
        let new: @MainActor (CGPoint) -> Void
        if let existing = configuration.tapResponder {
            new = {
                existing($0)
                action($0)
            }
        } else {
            new = action
        }
        return self.withConfigurationValue(\.tapResponder, setTo: new)
    }
}

#endif
