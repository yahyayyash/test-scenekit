//
//  MapEditor3DViewController.swift
//  test-scenekit
//
//  Created by Yahya Asaduddin on 04/11/24.
//

import UIKit
import SceneKit
import SnapKit
import SpriteKit
import SwiftUI

final class MapEditor3DViewController: UIViewController {
    struct Constants {
        static let defaultInset: CGFloat = 16.0
        static let defaultCornerRadius: CGFloat = 16.0
        static let defaultButtonAnimationSpeed: CGFloat = 1.0
    }

    var is3DViewEnabled: Bool = true {
        didSet {
            resetCamera()
        }
    }

    var isDebugModeEnabled: Bool = false {
        didSet {
            if isDebugModeEnabled {
                sceneView.debugOptions = [.renderAsWireframe, .showBoundingBoxes]
                debugViewButton.configuration?.image = UIImage(systemName: "eye")
            }
            else {
                sceneView.debugOptions = []
                debugViewButton.configuration?.image = UIImage(systemName: "eye.slash")
            }
        }
    }

    var isLightningEnabled: Bool = false {
        didSet {
            sceneView.autoenablesDefaultLighting = isLightningEnabled
            lightningToggleButton.configuration?.image = isLightningEnabled ? UIImage(systemName: "lightbulb.fill") : UIImage(systemName: "lightbulb")
        }
    }

    var isLoaded: Bool = false
    var selectedNodes: Map3DNode?

    private lazy var topRightMenuStack: UIStackView = {
        let stackView: UIStackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8.0
        return stackView
    }()

    private lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.systemPink.cgColor, UIColor.systemPink.withAlphaComponent(0.75).cgColor]
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        return gradientLayer
    }()

    private lazy var levelButton: UIButton = {
        let button: UIButton = UIButton()
        var configuration: UIButton.Configuration = .filled()
        configuration.attributedTitle = AttributedString("All Level", attributes: AttributeContainer([
            .font : UIFont.boldSystemFont(ofSize: 14.0)
        ]))
        configuration.cornerStyle = .large
        configuration.imagePlacement = .leading
        configuration.image = UIImage(systemName: "chevron.down")?.applyingSymbolConfiguration(.init(pointSize: 8.0))
        configuration.imagePadding = 6.0
        configuration.contentInsets = .init(
            top: 8.0,
            leading: 8.0,
            bottom: 8.0,
            trailing: 12.0
        )
        configuration.baseBackgroundColor = .white
        configuration.baseForegroundColor = .black
        button.configuration = configuration
        button.showsMenuAsPrimaryAction = true
        return button
    }()

    private lazy var recenterSceneButton: UIButton = createIconButton(with: UIImage(systemName: "viewfinder.rectangular"))
    private lazy var sceneViewToggleButton: UIButton = createIconButton(with: UIImage(systemName: "move.3d"))
    private lazy var debugViewButton: UIButton = createIconButton(with: UIImage(systemName: "eye.slash"))
    private lazy var lightningToggleButton: UIButton = createIconButton(with: UIImage(systemName: "lightbulb"))
    private lazy var debugButton: UIButton = createIconButton(with: UIImage(systemName: "gearshape.fill"))

    private lazy var mapTitleLabel: UILabel = {
        let label: UILabel = UILabel()
        label.text = "South Quarter"
        label.font = UIFont.systemFont(ofSize: 32.0, weight: .heavy)
        label.textColor = .white
        return label
    }()

    private lazy var viewContainer: UIView = UIView()
    private lazy var scene: SCNScene = SCNScene()
    private lazy var sceneView: SCNView = SCNView()
    private lazy var annotationScene: SKScene = SKScene()
    private lazy var camera: SCNCamera = SCNCamera()
    private lazy var cameraNode: SCNNode = SCNNode()

    var annotationRootNode: SCNNode?
    var levelNodesDict: [Int: Map3DNode] = [:]
    var connectorDict: [UUID: Set<UUID>] = [:]

    let viewModel: MapEditor3DViewModelProtocol

    private lazy var xLabel: HorizontalTextView = HorizontalTextView(spacing: 4.0)
    private lazy var yLabel: HorizontalTextView = HorizontalTextView(spacing: 4.0)
    private lazy var zLabel: HorizontalTextView = HorizontalTextView(spacing: 4.0)
    private lazy var descLabel: HorizontalTextView = HorizontalTextView(spacing: 4.0)

    lazy var tapGesture: UITapGestureRecognizer = UITapGestureRecognizer()

    lazy var stackViewContainer: UIStackView = {
        let stackView: UIStackView = UIStackView()
        stackView.spacing = 8.0
        stackView.axis = .vertical
        stackView.layer.cornerRadius = 16.0
        return stackView
    }()

    init(viewModel: MapEditor3DViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.onViewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = sceneView.frame
    }

    @objc
    func resetCamera() {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        sceneView.defaultCameraController.stopInertia()

        if is3DViewEnabled {
            sceneViewToggleButton.configuration?.image = UIImage(systemName: "move.3d")
            sceneView.defaultCameraController.pointOfView?.eulerAngles = SCNVector3(-45.0 * .pi / 180, 45.0 * .pi / 180.0, .zero)
        }
        else {
            sceneViewToggleButton.configuration?.image = UIImage(systemName: "arrow.up.and.down.and.arrow.left.and.right")
            sceneView.defaultCameraController.pointOfView?.eulerAngles = SCNVector3(-90.0 * .pi / 180.0, .zero, .zero)
        }

        sceneView.defaultCameraController.frameNodes(annotationRootNode?.childNodes ?? [])

        SCNTransaction.commit()
    }

    @objc
    func zoomToFit() {

    }
}

private extension MapEditor3DViewController {
    func createIconButton(with icon: UIImage?) -> UIButton {
        let button: UIButton = UIButton()
        var configuration: UIButton.Configuration = .tinted()
        configuration.cornerStyle = .capsule
        configuration.image = icon
        configuration.baseForegroundColor = .white
        configuration.baseBackgroundColor = .white
        configuration.contentInsets = .init(
            top: 16.0,
            leading: 8.0,
            bottom: 16.0,
            trailing: 8.0
        )
        button.configuration = configuration
        return button
    }

    @objc
    func onSceneDidTapped() {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.2

        let hits = sceneView.hitTest(tapGesture.location(in: sceneView), options: [.searchMode: 1])
        if let first = hits.first(where: { $0.node.isMember(of: Map3DNode.self )}) {
            for value in levelNodesDict.values {
                value.childNodes.forEach {
                    $0.opacity = 0.05
                    $0.scale = .one
                    ($0 as? Map3DNode)?.overlayNode?.setScale(1.0)
                    ($0 as? Map3DNode)?.overlayNode?.alpha = 0.75
                }
            }

            first.node.opacity = 1.0
            first.node.scale = SCNVector3(1.1)
            (first.node as? Map3DNode)?.overlayNode?.alpha = 1.0
            (first.node as? Map3DNode)?.overlayNode?.setScale(1.1)

            if let from = selectedNodes, let to = first.node as? Map3DNode {
                addConnector(from: from, to: to)
                self.selectedNodes = nil
            }

            selectedNodes = (first.node as? Map3DNode)
        }
        else {
            for value in levelNodesDict.values {
                value.childNodes.forEach {
                    $0.opacity = 1.0
                    $0.scale = .one
                    ($0 as? Map3DNode)?.overlayNode?.setScale(1.0)
                    ($0 as? Map3DNode)?.overlayNode?.alpha = 1.0
                }
            }

            selectedNodes = nil
        }

        SCNTransaction.commit()
    }

    func setupViews() {
        sceneView.addGestureRecognizer(tapGesture)
        tapGesture.addTarget(self, action: #selector(onSceneDidTapped))

        setupScene()
        setupDebugViews()
        setupButtons()

        title = "3D Viewport"
        let menuItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), primaryAction: UIAction { [weak self] _ in
            self?.menuItemDidTapped()
        })

        navigationItem.rightBarButtonItems = [menuItem]
    }

    @objc
    func menuItemDidTapped() {

    }

    func setupScene() {
        view.addSubview(viewContainer)
        view.backgroundColor = .white
        viewContainer.addSubview(sceneView)
        viewContainer.addSubview(mapTitleLabel)

        viewContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        sceneView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        mapTitleLabel.snp.makeConstraints { make in
            make.leading.top.equalTo(viewContainer.safeAreaLayoutGuide)
        }

        sceneView.scene = scene
        sceneView.delegate = self
        sceneView.overlaySKScene = annotationScene
        sceneView.backgroundColor = .clear
        sceneView.allowsCameraControl = true
        sceneView.isUserInteractionEnabled = true

        sceneView.defaultCameraController.delegate = self
        sceneView.defaultCameraController.automaticTarget = true
        sceneView.defaultCameraController.inertiaEnabled = false
        sceneView.defaultCameraController.interactionMode = .pan

        camera.usesOrthographicProjection = true
        camera.zNear = .zero
        cameraNode.position = SCNVector3(50.0)
        cameraNode.camera = camera
        cameraNode.eulerAngles = SCNVector3(-45.0 * .pi / 180, 45.0 * .pi / 180.0, .zero)
        sceneView.pointOfView = cameraNode
        sceneView.scene?.rootNode.addChildNode(cameraNode)

        viewContainer.clipsToBounds = true
        viewContainer.layer.cornerRadius = Constants.defaultCornerRadius
        viewContainer.layer.insertSublayer(gradientLayer, at: .zero)
    }

    func setupDebugViews() {
        view.addSubview(stackViewContainer)
        stackViewContainer.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(sceneView.safeAreaLayoutGuide).inset(16.0)
        }

        stackViewContainer.addArrangedSubview(xLabel)
        stackViewContainer.addArrangedSubview(yLabel)
        stackViewContainer.addArrangedSubview(zLabel)
        stackViewContainer.addArrangedSubview(descLabel)
    }

    func setupButtons() {
        view.addSubview(levelButton)
        levelButton.snp.makeConstraints { make in
            make.leading.top.equalTo(sceneView.safeAreaLayoutGuide).inset(Constants.defaultInset)
        }

        view.addSubview(topRightMenuStack)
        topRightMenuStack.snp.makeConstraints { make in
            make.trailing.top.equalTo(sceneView.safeAreaLayoutGuide).inset(Constants.defaultInset)
        }

        [
            recenterSceneButton,
            sceneViewToggleButton,
            lightningToggleButton,
            debugViewButton,
            debugButton
        ].forEach { topRightMenuStack.addArrangedSubview($0) }

        sceneViewToggleButton.addAction(UIAction { [weak self] _ in
            self?.is3DViewEnabled.toggle()
            self?.sceneViewToggleButton.imageView?.addSymbolEffect(.bounce, options: .speed(Constants.defaultButtonAnimationSpeed))
        }, for: .touchUpInside)

        lightningToggleButton.addAction(UIAction { [weak self] _ in
            self?.isLightningEnabled.toggle()
            self?.lightningToggleButton.imageView?.addSymbolEffect(.bounce, options: .speed(Constants.defaultButtonAnimationSpeed))
        }, for: .touchUpInside)

        debugViewButton.addAction(UIAction { [weak self] _ in
            self?.isDebugModeEnabled.toggle()
            self?.debugViewButton.imageView?.addSymbolEffect(.bounce, options: .speed(Constants.defaultButtonAnimationSpeed))
        }, for: .touchUpInside)

        debugButton.addAction(UIAction { [weak self] _ in
            self?.openDebugView()
            self?.debugButton.imageView?.addSymbolEffect(.bounce, options: .speed(Constants.defaultButtonAnimationSpeed))
        }, for: .touchUpInside)

        recenterSceneButton.addAction(UIAction { [weak self] _ in
            self?.resetCamera()
            self?.recenterSceneButton.imageView?.addSymbolEffect(.bounce, options: .speed(Constants.defaultButtonAnimationSpeed))
        }, for: .touchUpInside)

        levelButton.menu = viewModel.getLevelMenus()
    }

    func getLevelButtonAttributedText(with string: String?) -> AttributedString? {
        AttributedString(string ?? "", attributes: AttributeContainer([
                                                                          .font: UIFont.boldSystemFont(ofSize: 14.0)
                                                                      ]))
    }

    func openDebugView() {
        let position = sceneView.pointOfView?.position ?? .init(x: .zero, y: .zero, z: .zero)
        let vm: MapEditor3DDebugConfigViewModel = MapEditor3DDebugConfigViewModel(
            xPosition: position.x,
            yPosition: position.y,
            zPosition: position.z,
            zNear: Float(sceneView.pointOfView?.camera?.zNear ?? .zero),
            zFar: Float(sceneView.pointOfView?.camera?.zFar ?? .zero)
        )
        let mapEditorView: MapEditor3DDebugConfigView = MapEditor3DDebugConfigView(viewModel: vm) { [weak self] in
            print("UPDATE")
            self?.dismiss(animated: true)
            self?.updateValue(from: vm)
        }

        let vc: UIHostingController = UIHostingController(rootView: mapEditorView)
        vc.title = "Settings"
        navigationController?.present(vc, animated: true)
    }

    func updateValue(from vm: MapEditor3DDebugConfigViewModel) {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.0

        let newPosition: SCNVector3 = SCNVector3(vm.xPosition, vm.yPosition, vm.zPosition)
        sceneView.pointOfView?.position = newPosition
        sceneView.pointOfView?.camera?.zNear = Double(vm.zNear)
        sceneView.pointOfView?.camera?.zFar = Double(vm.zFar)

        SCNTransaction.commit()
    }
}

extension MapEditor3DViewController: MapEditor3DViewModelDelegate {
    func updateMenus() {
        levelButton.menu = viewModel.getLevelMenus()
        let selectionString: String? = viewModel.getLevelMenus().children.first { $0.image != nil }?.title
        levelButton.configuration?.attributedTitle = getLevelButtonAttributedText(with: selectionString)

        for key in levelNodesDict.keys {
            let isSelected: Bool = viewModel.selectedLevel.contains(key)
            levelNodesDict[key]?.opacity = isSelected ? 1.0 : 0.1
        }

        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        sceneView.defaultCameraController.stopInertia()
        sceneView.defaultCameraController.frameNodes(annotationRootNode?.childNodes.filter { $0.opacity == 1.0 } ?? [])
        SCNTransaction.commit()
    }

    func loadAnnotations(with nodes: [NodesData]) {
        annotationRootNode = SCNNode()

        for node in nodes {
            let child: Map3DNode = Map3DNode()
            child.geometry = SCNSphere(radius: 1.0)
            child.name = node.name
            child.position = node.position
            child.position.y = Float(node.level) * 5.0

            let label: String = "\(node.level).\(node.name)"
            let textSprite: SKLabelNode = SKLabelNode()
            textSprite.attributedText = NSAttributedString(
                string: label,
                attributes: [
                    .font : UIFont.systemFont(ofSize: 12.0, weight: .black),
                    .foregroundColor : UIColor.darkGray
                ]
            )

            child.overlayNode = textSprite

            if levelNodesDict[node.level] == nil {
                let currLevelNode: Map3DNode = Map3DNode()
                currLevelNode.addChildNode(child)
                levelNodesDict[node.level] = currLevelNode
            }
            else {
                levelNodesDict[node.level]?.addChildNode(child)
            }
        }

        for node in levelNodesDict.values {
            annotationRootNode?.addChildNode(node)

            for child in node.childNodes {
                if let overlayNode = (child as? Map3DNode)?.overlayNode {
                    annotationScene.addChild(overlayNode)
                }
            }
        }

        if let annotationRootNode {
            scene.rootNode.addChildNode(annotationRootNode)
            scene.rootNode.worldPosition = .zero
        }

//        setupConnectorNodes()
//        setupLevelBoundaries()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.resetCamera()
        }
    }

    // Mock: Development Purposes
    func setupConnectorNodes() {
        let node: SCNNode = SCNGeometry.cylinderLine(from: .init(x: .zero, y: .zero, z: .zero), to: .init(x: 5.0, y: .zero, z: .zero))
        node.position.y = 5.0
        node.opacity = 0.25
        annotationRootNode?.addChildNode(node)

        let connector: SCNNode = SCNGeometry.cylinderLine(
            from: .init(x: 10.0, y: .zero, z: 5.0),
            to: .init(x: 10.0, y: 5.0, z: 5.0),
            segments: 10,
            radius: 0.75
        )

        connector.position.y = 7.5
        connector.opacity = 0.25
        connector.geometry?.firstMaterial?.diffuse.contents = UIColor.systemYellow
        annotationRootNode?.addChildNode(connector)
    }

    func addConnector(from nodeA: Map3DNode, to nodeB: Map3DNode) {
        guard connectorDict[nodeA.id]?.contains(nodeB.id) ?? false == false,
              connectorDict[nodeB.id]?.contains(nodeA.id) ?? false == false
        else { return }
        let node: SCNNode = SCNGeometry.cylinderLine(from: nodeA.position, to: nodeB.position)
        node.opacity = 0.25
        annotationRootNode?.addChildNode(node)

        connectorDict[nodeA.id, default: Set()].insert(nodeB.id)
        connectorDict[nodeB.id, default: Set()].insert(nodeA.id)
    }

    // Mock: Development Purposes
    func setupLevelBoundaries() {
        for level in levelNodesDict.values {
            let boundingBox: (min: SCNVector3, max: SCNVector3) = level.boundingBox
            let boundingBoxNode: SCNNode = SCNNode.createBoxFromBoundingBox(minVec: boundingBox.min, maxVec: boundingBox.max, color: .systemTeal)
            level.addChildNode(boundingBoxNode)
        }
    }
}

extension MapEditor3DViewController: SCNCameraControllerDelegate {

}

extension MapEditor3DViewController: SCNNodeRendererDelegate {

}

extension MapEditor3DViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let position = sceneView.pointOfView?.position ?? .init(x: .zero, y: .zero, z: .zero)
            xLabel.configure(with: "x", rightText: String(position.x.rounded(toPlaces: 2)))
            yLabel.configure(with: "y", rightText: String(position.y.rounded(toPlaces: 2)))
            zLabel.configure(with: "z", rightText: String(position.z.rounded(toPlaces: 2)))

            let sceneViewSize: CGSize = self.sceneView.bounds.size
            self.annotationScene.size = sceneViewSize

            for parent in levelNodesDict.values {
                for child in parent.childNodes {
                    if let overlayNode = (child as? Map3DNode)?.overlayNode {
                        let point: SCNVector3 = self.sceneView.projectPoint(child.position)
                        overlayNode.position = CGPoint(x: CGFloat(point.x), y: sceneViewSize.height - CGFloat(point.y) + 32.0)
                    }
                }
            }
        }
    }
}

#Preview("3D Editor") {
    let vc = MapEditor3DViewController(viewModel: MapEditor3DViewModel())
    let navigationController = UINavigationController(rootViewController: vc)
    return navigationController
}

struct MapEditor3DOverlayView: View {
    private enum ActionButtons: Int, CaseIterable {
        case menu
        case recenter
        case viewMode
        case wireframeMode
        case lightning
        case setting
        
        var imageName: String {
            switch self {
            case .menu:
                return "ellipsis"
            case .recenter:
                return "viewfinder.rectangular"
            case .viewMode:
                return "move.3d"
            case .wireframeMode:
                return "eye.slash"
            case .lightning:
                return "lightbulb"
            case .setting:
                return "gearshape.fill"
            }
        }
    }
    
    @State
    var isMenuShowing: Bool = true

    var body: some View {
        GeometryReader { proxy in
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8.0) {
                    Text("Taman Ismail Marzuki")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .lineLimit(2)

                    levelSelectionButton
                }

                Spacer()

                sideMenu
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var levelSelectionButton: some View {
        Button {
            isMenuShowing.toggle()
        } label: {
            HStack(spacing: 8.0) {
                Text("All Level")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundStyle(.black)

                Image(systemName: "chevron.down")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.gray)
                    .frame(width: 12.0, height: 12.0)
            }
        }
        .padding(.vertical, 8.0)
        .padding(.horizontal, 12.0)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12.0, style: .continuous))
    }

    var sideMenu: some View {
        VStack {
            ForEach(ActionButtons.allCases, id: \.rawValue) { action in
              createButton(with: action)
            }
        }
    }

    private func createButton(with action: ActionButtons) -> some View {
        Button {
            handleActions(for: action)
        } label: {
            Image(systemName: action.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 24.0, height: 24.0)
                .padding(12.0)
                .foregroundStyle(.white)
        }
        .background(
            Circle()
                .foregroundStyle(.white)
                .opacity(0.3)
        )
        .opacity(isMenuShowing ? 1.0 : 0.0)
        .offset(x: isMenuShowing ? .zero : 96.0, y: isMenuShowing ? .zero : -4.0)
        .scaleEffect(isMenuShowing ? CGSize(width: 1.0, height: 1.0) : CGSize(width: 0.7, height: 0.7))
        .animation(.easeInOut.delay(Double(action.rawValue) * 0.04), value: isMenuShowing)
    }
    
    private func handleActions(for action: ActionButtons) {
        switch action {
        case .menu:
            print("Menu")
        case .recenter:
            print("Recenter")
        case .viewMode:
            print("View Mode")
        case .wireframeMode:
            print("Wireframe Mode")
        case .lightning:
            print("Lightning")
        case .setting:
            print("Setting")
        }
    }
}

#Preview("Overlay View") {
    MapEditor3DOverlayView()
        .background(.pink)
}
