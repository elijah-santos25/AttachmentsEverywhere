//
//  AttachmentContentBuilder.swift
//  AttachmentsEverywhere
//
//  Created by Elijah Santos on 8/7/24.
//

import Foundation
import SwiftUI

#if !os(visionOS)

public typealias AttachmentContent = [AnyHashable: (AnyView, AttachmentCustomization)]

@resultBuilder
public enum AttachmentContentBuilder {
    public static func buildExpression(_ expression: Attachment<some View>) -> AttachmentContent {
        return [expression.id: (AnyView(expression.adaptedContent), expression.configuration)]
    }
    
    public static func buildExpression(_ expression: AttachmentContent) -> AttachmentContent {
        expression
    }
    
    public static func buildBlock() -> AttachmentContent {
        // allows empty attachment blocks
        return [:]
    }
    
    public static func buildPartialBlock(first: AttachmentContent) -> AttachmentContent {
        first
    }
    
    public static func buildPartialBlock(accumulated: AttachmentContent, next: AttachmentContent) -> AttachmentContent {
        var res = accumulated
        for (key, value) in next {
            if accumulated.contains(where: { $0.key == key }) {
                print("[AttachmentsEverywhere] warning: duplicate key in attachment content: \(String(reflecting: key))")
            }
            res[key] = value
        }
        return res
    }
    
    public static func buildEither(first component: AttachmentContent) -> AttachmentContent {
        component
    }
    
    public static func buildEither(second component: AttachmentContent) -> AttachmentContent {
        component
    }
    
    public static func buildOptional(_ component: AttachmentContent?) -> AttachmentContent {
        component ?? [:]
    }
    
    public static func buildLimitedAvailability(_ component: AttachmentContent) -> AttachmentContent {
        component
    }
    
    public static func buildArray(_ components: [AttachmentContent]) -> AttachmentContent {
        var res = [:] as AttachmentContent
        for component in components {
            res = buildPartialBlock(accumulated: res, next: component)
        }
        return res
    }
}

#endif
