//
//  MapNode.swift
//  test-scenekit
//
//  Created by Yahya Asaduddin on 04/11/24.
//

import SceneKit
import SpriteKit
import UIKit

final class MapOverlayNode: SKSpriteNode {
    weak var parentNode: Map3DNode?
    
    lazy var labelNode: SKLabelNode = SKLabelNode()
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        setupSprites()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with text: String) {
        labelNode.text = text
    }
    
    private func setupSprites() {
        addChild(labelNode)
        labelNode.position = .zero
    }
}

final class Map3DNode: SCNNode {
    let id: UUID
    var overlayNode: SKNode?
    
    init(id: UUID = UUID(), overlayNode: SKNode? = nil) {
        self.id = id
        self.overlayNode = overlayNode
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
