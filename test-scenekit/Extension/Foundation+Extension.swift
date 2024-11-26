//
//  Foundation+Extension.swift
//  test-scenekit
//
//  Created by Yahya Asaduddin on 04/11/24.
//

import Foundation

extension Float {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Float {
        let divisor: Float = pow(10.0, Float(places))
        return (self * divisor).rounded() / divisor
    }
}
