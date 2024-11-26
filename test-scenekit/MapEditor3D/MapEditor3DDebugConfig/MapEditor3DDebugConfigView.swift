//
//  MapEditor3DDebugConfigView.swift
//  test-scenekit-app
//
//  Created by Yahya Asaduddin on 09/11/24.
//

import SwiftUI

struct MapEditor3DDebugConfigView: View {
    private enum TextFieldState: Int, Hashable {
        case cameraX
        case cameraY
        case cameraZ
        case cameraZNear
        case cameraZFar
    }
    
    @ObservedObject
    var viewModel: MapEditor3DDebugConfigViewModel
    
    @FocusState
    private var focusedTextField: TextFieldState?
    
    var onApplied: (() -> Void)?
    
    init(viewModel: MapEditor3DDebugConfigViewModel, onApplied: (() -> Void)?) {
        self.viewModel = viewModel
        self.onApplied = onApplied
    }
    
    var body: some View {
        VStack {
            ScrollView {
                contentView
            }
            
            Button {
                onApplied?()
            } label: {
                Text("Apply")
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
            }
            .background(Color.black)
            .foregroundStyle(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16.0))
        }
        .padding(16.0)
    }
    
    var contentView: some View {
        VStack(spacing: 12.0) {
            VStack(alignment: .leading, spacing: 12.0) {
                Text("Camera Position")
                    .fontWeight(.bold)
                HStack {
                    createTextField(
                        title: "X",
                        value: $viewModel.xPosition,
                        state: .cameraX
                    )
                    createTextField(
                        title: "Y",
                        value: $viewModel.yPosition,
                        state: .cameraY
                    )
                    createTextField(
                        title: "Z",
                        value: $viewModel.zPosition,
                        state: .cameraZ
                    )
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 16.0).foregroundStyle(Color.gray.opacity(0.1)))
            
            VStack(alignment: .leading, spacing: 12.0) {
                Text("Camera Clipping")
                    .fontWeight(.bold)
                HStack {
                    createTextField(
                        title: "zNear",
                        value: $viewModel.zNear,
                        state: .cameraZNear
                    )
                    createTextField(
                        title: "zFar",
                        value: $viewModel.zFar,
                        state: .cameraZFar
                    )
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 16.0).foregroundStyle(Color.gray.opacity(0.1)))
        }
    }
    
    @ViewBuilder
    private func createTextField(
        title: String,
        value: Binding<Float>,
        state: TextFieldState
    ) -> some View {
        VStack(alignment: .leading, spacing: 4.0) {
            Text(title)
                .font(.caption)
                .foregroundStyle(Color.gray)
            
            TextField(title, value: value, formatter: createNumberFormatter())
                .padding(12.0)
                .focused($focusedTextField, equals: state)
                .background {
                    RoundedRectangle(cornerRadius: 8.0)
                        .foregroundStyle(Color.white)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 8.0)
                        .stroke(focusedTextField == state ? .black : .clear)
                }
                .onTapGesture {
                    focusedTextField = state
                }
                .animation(.easeInOut(duration: 0.2), value: focusedTextField)
            
        }
    }
    
    func createNumberFormatter() -> NumberFormatter {
        let numberFormatter: NumberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.decimalSeparator = "."
        return numberFormatter
    }
}

#Preview("Debug Config") {
    MapEditor3DDebugConfigView(
        viewModel: MapEditor3DDebugConfigViewModel(
            xPosition: .zero,
            yPosition: .zero,
            zPosition: .zero,
            zNear: .zero,
            zFar: .zero
        ),
        onApplied: nil
    )
}
