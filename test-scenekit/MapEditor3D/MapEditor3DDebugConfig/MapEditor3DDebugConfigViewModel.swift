//
//  MapEditor3DDebugConfigViewModel.swift
//  test-scenekit-app
//
//  Created by Yahya Asaduddin on 09/11/24.
//

import SwiftUI

final class MapEditor3DDebugConfigViewModel: ObservableObject {
    @Published
    var xPosition: Float
    @Published
    var yPosition: Float
    @Published
    var zPosition: Float
    @Published
    var zNear: Float
    @Published
    var zFar: Float
    
    init(xPosition: Float, yPosition: Float, zPosition: Float, zNear: Float, zFar: Float) {
        self.xPosition = xPosition
        self.yPosition = yPosition
        self.zPosition = zPosition
        self.zNear = zNear
        self.zFar = zFar
    }
}
