//
//  Environment+.swift
//  AttachmentsEverywhere
//
//  Created by Elijah Santos on 8/9/24.
//

import Foundation
import SwiftUI

extension EnvironmentValues {
    @Entry internal var attachmentPointsPerMeter: Float = 300
}

extension View {
    /// Sets the number of points (in view scaling) per meter for all attachments in an ``AttachableRealityView-swift.struct``.
    public func attachmentScale(pointsPerMeter: Float) -> some View {
        self.environment(\.attachmentPointsPerMeter, pointsPerMeter)
    }
}
