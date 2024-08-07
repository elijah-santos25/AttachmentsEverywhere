//
//  Attachment.swift
//  AttachmentsEverywhere
//
//  Created by Elijah Santos on 8/7/24.
//

import Foundation
import SwiftUI

#if !os(visionOS)

internal let Attachment_padding: CGFloat = 20

public struct Attachment<Content: View>: Identifiable {
    public init(id: AnyHashable, @ViewBuilder _ content: () -> Content) {
        self.id = id
        self.content = content()
        self.configuration = .default
    }
    public let id: AnyHashable
    public let content: Content
    internal var configuration: AttachmentCustomization
    
    // the content that is actually rendered in AttachableRealityView
    internal var adaptedContent: some View {
        content
            .foregroundStyle(.white, .white.opacity(0.6), .white.opacity(0.475))
            .padding(Attachment_padding)
    }
}

#endif
