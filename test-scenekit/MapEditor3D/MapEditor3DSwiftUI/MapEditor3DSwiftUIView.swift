//
//  MapEditor3DSwiftUIView.swift
//  test-scenekit-app
//
//  Created by Yahya Asaduddin on 09/11/24.
//

import SceneKit
import SwiftUI

struct MapEditor3DSwiftUIView: View {
    @StateObject
    var coordinator: MapEditor3DSwiftUIViewCoordinator = MapEditor3DSwiftUIViewCoordinator()
    
    var body: some View {
        SceneView(
            scene: coordinator.scene,
            pointOfView: coordinator.cameraNode,
            options: [.allowsCameraControl, .rendersContinuously, .autoenablesDefaultLighting],
            delegate: coordinator
        )
    }
}

final class MapEditor3DSwiftUIViewCoordinator: NSObject, ObservableObject {
    var scene: SCNScene = SCNScene()
    var cameraNode: SCNNode = SCNNode()
    
    override init() {
        super.init()
        let boxSize: CGFloat = 1.0
        let box: SCNGeometry = SCNBox(
            width: boxSize,
            height: boxSize,
            length: boxSize,
            chamferRadius: boxSize * 0.1
        )
        
        box.materials.first?.diffuse.contents = UIColor.red
        
        scene.rootNode.addChildNode(SCNNode(geometry: box))
        scene.rootNode.addChildNode(cameraNode)
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0.0, 0.0, 5.0)
    }
}

extension MapEditor3DSwiftUIViewCoordinator: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
    }
}

#Preview("Map Editor") {
    MapEditor3DSwiftUIView()
}
