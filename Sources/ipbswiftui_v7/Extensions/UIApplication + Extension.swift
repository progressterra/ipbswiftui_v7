//
//  UIApplication + Extension.swift
//  
//
//  Created by Artemy Volkov on 29.08.2023.
//

import UIKit

extension UIApplication {
    func hideKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
