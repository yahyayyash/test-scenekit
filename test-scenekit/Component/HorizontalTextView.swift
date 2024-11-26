//
//  HorizontalTextView.swift
//  test-scenekit
//
//  Created by Yahya Asaduddin on 04/11/24.
//

import SnapKit
import UIKit

final class HorizontalTextView: UIView {
    let leftLabel: UILabel = UILabel()
    let rightLabel: UILabel = UILabel()
    var spacing: CGFloat
    
    init(spacing: CGFloat = 8.0) {
        self.spacing = spacing
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with leftText: String?, rightText: String?) {
        leftLabel.text = leftText
        rightLabel.text = rightText
    }
}

extension HorizontalTextView {
    func setupViews() {
        leftLabel.font = .systemFont(ofSize: 12.0, weight: .semibold)
        rightLabel.font = .systemFont(ofSize: 16.0, weight: .bold)
        
        leftLabel.textColor = .white.withAlphaComponent(0.75)
        rightLabel.textColor = .white
        
        addSubview(leftLabel)
        addSubview(rightLabel)
        
        leftLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.verticalEdges.equalToSuperview()
        }
        
        rightLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.leading.equalTo(leftLabel.snp.trailing).offset(spacing)
            make.verticalEdges.equalToSuperview()
        }
    }
}
