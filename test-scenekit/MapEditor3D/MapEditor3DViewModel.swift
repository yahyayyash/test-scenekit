//
//  MapEditor3DViewModel.swift
//  test-scenekit
//
//  Created by Yahya Asaduddin on 04/11/24.
//

import Foundation
import SceneKit
import UIKit

// MARK: - Contracts
protocol MapEditor3DViewModelDelegate: AnyObject {
    func loadAnnotations(with nodes: [NodesData])
    func updateMenus()
}

protocol MapEditor3DViewModelProtocol: AnyObject {
    var delegate: MapEditor3DViewModelDelegate? { get set }
    var nodes: [NodesData] { get }
    var selectedLevel: Set<Int> { get }
    
    func onViewDidLoad()
    func getLevelMenus() -> UIMenu
}

// MARK: - Implementation
final class MapEditor3DViewModel: MapEditor3DViewModelProtocol {
    private struct Constants {
        /* Development Purposes */
        static let numOfLevels: Int = 3
    }
    
    weak var delegate: MapEditor3DViewModelDelegate?
    
    lazy var nodes: [NodesData] = createDummyNodes()
    var selectedLevel: Set<Int> = Set()
    
    func onViewDidLoad() {
        selectedLevel = getLevelData()
        delegate?.loadAnnotations(with: nodes)
    }
    
    func getLevelMenus() -> UIMenu {
        let isAllSelected: Bool = selectedLevel == getLevelData()
        let selectedImage: UIImage? = UIImage(systemName: "eye.fill")
        
        let all: UIAction = UIAction(
            title: "All Level",
            image: isAllSelected ? selectedImage : nil
        ) { [weak self] _ in
            self?.onLevelSelected(at: nil)
        }
        
        let levels: [UIAction] = getLevelData().sorted().map { level in
            let isSelected: Bool = selectedLevel.count == 1 && selectedLevel.contains(level)
            return UIAction(
                title: "Level \(level)",
                image: isSelected ? selectedImage : nil
            ) { [weak self] _ in
                self?.onLevelSelected(at: level)
            }
        }
        
        return UIMenu(children: getLevelData().count > 1 ? [all] + levels : levels)
    }
    
    func onLevelSelected(at level: Int?) {
        if let level {
            selectedLevel = Set([level])
        }
        else {
            selectedLevel = getLevelData()
        }
        
        delegate?.updateMenus()
    }
}

private extension MapEditor3DViewModel {
    func createDummyNodes() -> [NodesData] {
        var nodes: [NodesData] = []
        for i in 1...Constants.numOfLevels {
            nodes.append(
                contentsOf: [
                    NodesData(name: "1", desc: nil, type: .normal, position: SCNVector3(x: .zero, y: .zero, z: .zero), level: i),
                    NodesData(name: "2", desc: nil, type: .normal, position: SCNVector3(x: 5.0, y: .zero, z: .zero), level: i),
                    NodesData(name: "3", desc: nil, type: .normal, position: SCNVector3(x: 10.0, y: .zero, z: .zero), level: i),
                    NodesData(name: "4", desc: nil, type: .normal, position: SCNVector3(x: 10.0, y: .zero, z: 5.0), level: i)
                ]
            )
        }
        return nodes
    }
    
    func getLevelData() -> Set<Int> {
        return Set(nodes.map { $0.level })
    }
}
