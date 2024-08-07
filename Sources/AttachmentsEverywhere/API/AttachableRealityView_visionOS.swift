//
//  AttachableRealityView_visionOS.swift
//  AttachmentsEverywhere
//
//  Created by Elijah Santos on 8/7/24.
//

#if os(visionOS)
import SwiftUI
import RealityKit

// since visionOS has attachments, no custom implementation is needed; only a typealias
public typealias AttachableRealityView = RealityView
#endif
