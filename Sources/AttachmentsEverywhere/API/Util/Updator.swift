//
//  Updator.swift
//  AttachmentsEverywhere
//
//  Created by Elijah Santos on 8/13/24.
//

import Foundation
import Combine

internal class Updator: ObservableObject {
    private(set) var updateCount = 0
    
    internal func forceViewUpdate() {
        self.objectWillChange.send()
        updateCount += 1
    }
}
