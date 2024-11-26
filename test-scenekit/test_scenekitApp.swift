//
//  test_scenekitApp.swift
//  test-scenekit
//
//  Created by Yahya Asaduddin on 04/11/24.
//

import SwiftUI

@main
struct test_scenekitApp: App {
    var body: some Scene {
        WindowGroup {
            MapEditorSwiftUIView()
        }
    }
}

struct MapEditorSwiftUIView: UIViewControllerRepresentable {
    typealias UIViewControllerType = MapEditor3DViewController
    
    func makeUIViewController(context: Context) -> MapEditor3DViewController {
        let vc = MapEditor3DViewController(viewModel: MapEditor3DViewModel())
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MapEditor3DViewController, context: Context) {
        // Updates the state of the specified view controller with new information from SwiftUI.
    }
}
