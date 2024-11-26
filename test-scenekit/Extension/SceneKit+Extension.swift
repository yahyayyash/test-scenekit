//
//  SceneKit+Extension.swift
//  test-scenekit
//
//  Created by Yahya Asaduddin on 04/11/24.
//

import Foundation
import SceneKit

extension SCNVector3 {
    init(_ value: Float) {
        self.init(value, value, value)
    }
    
    static var zero: SCNVector3 {
        return self.init(0.0)
    }
    
    static var one: SCNVector3 {
        return self.init(1.0)
    }
}

extension SCNNode {
    static func createBoxFromBoundingBox(minVec: SCNVector3, maxVec: SCNVector3, color: UIColor) -> SCNNode {
        let width: CGFloat = CGFloat(maxVec.x - minVec.x)
        let height: CGFloat = CGFloat(maxVec.y - minVec.y)
        let length: CGFloat = CGFloat(maxVec.z - minVec.z)
        
        let boxGeometry: SCNBox = SCNBox(width: width, height: height, length: length, chamferRadius: 0)
        boxGeometry.firstMaterial?.diffuse.contents = color.withAlphaComponent(0.2)
        
        let boxNode: SCNNode = SCNNode(geometry: boxGeometry)
        boxNode.position = SCNVector3(
            x: (minVec.x + maxVec.x) / 2,
            y: (minVec.y + maxVec.y) / 2,
            z: (minVec.z + maxVec.z) / 2
        )
        
        return boxNode
    }
}

extension SCNGeometry {
    static func cylinderLine(
        from: SCNVector3,
        to: SCNVector3,
        segments: Int = 5,
        radius: CGFloat = 0.25
    ) -> SCNNode {
        let x1: Float = from.x; let x2: Float = to.x
        let y1: Float = from.y; let y2: Float = to.y
        let z1: Float = from.z; let z2: Float = to.z
        
        let subExpr01: Float = Float((x2-x1) * (x2-x1))
        let subExpr02: Float = Float((y2-y1) * (y2-y1))
        let subExpr03: Float = Float((z2-z1) * (z2-z1))
        
        let distance: CGFloat = CGFloat(sqrtf(subExpr01 + subExpr02 + subExpr03))
        
        let cylinder: SCNCylinder = SCNCylinder(radius: radius, height: CGFloat(distance))
        cylinder.radialSegmentCount = segments
        
        let lineNode = SCNNode(geometry: cylinder)
        lineNode.position = SCNVector3((x1+x2)/2, (y1+y2)/2, (z1+z2)/2)
        
        lineNode.eulerAngles = SCNVector3(
            x: Float(CGFloat.pi) / 2,
            y: acos((to.z-from.z)/Float(CGFloat(distance))),
            z: atan2((to.y-from.y), (to.x-from.x))
        )
        return lineNode
    }
}
