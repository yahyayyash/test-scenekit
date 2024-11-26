//
//  NodesData.swift
//  test-scenekit
//
//  Created by Yahya Asaduddin on 04/11/24.
//

import SceneKit

struct NodesData {
    let id: UUID = UUID()
    
    let name: String
    let desc: String?
    let type: NodesType
    let position: SCNVector3
    let level: Int
    
    enum NodesType: Int {
        case normal
        case warning
        case warp
    }
}
