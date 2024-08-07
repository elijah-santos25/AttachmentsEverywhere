//
//  RealityViewAttachments.swift
//  AttachmentsEverywhere
//
//  Created by Elijah Santos on 8/13/24.
//

import Foundation
import RealityKit

#if !os(visionOS)

@MainActor
public struct RealityViewAttachments {
    let entities: [AnyHashable: ViewAttachmentEntity]
    
    public func entity(for id: some Hashable) -> ViewAttachmentEntity? {
        return entities[id]
    }
}

#endif
