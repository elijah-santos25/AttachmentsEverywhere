//
//  ImageGenerator.swift
//  IGS-RisingSeaLevels
//
//  Created by Elijah Santos on 8/5/24.
//

import Foundation
import SwiftUI
import Combine

let ImageGenerator_renderScale = 3 as Float

@MainActor
internal class ImageGenerator<Content: View> {
    private let renderer: ImageRenderer<Content>
    private var subscription: AnyCancellable? = nil
    private var onUpdate: (() -> Void)? = nil
    
    init(@ViewBuilder content: () -> Content) {
        self.renderer = ImageRenderer(content: content())
        renderer.scale = CGFloat(ImageGenerator_renderScale)
        renderer.isOpaque = false
        renderer.isObservationEnabled = true
    }
    
    func subscribe(onUpdate: @escaping () -> Void) {
        subscription = renderer.objectWillChange.sink {
            onUpdate()
        }
    }
    
    func cgImage() -> CGImage? {
        // TODO: subscribe to updates
        return renderer.cgImage
    }
}
