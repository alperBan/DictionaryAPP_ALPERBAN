//
//  CornerRadius.swift
//  Dic
//
//  Created by Alper Ban on 30.05.2023.
//

import UIKit
extension UIView{
    @IBInspectable var cornerRadius : CGFloat{
       get { return cornerRadius}
        set{
            self.layer.cornerRadius = newValue
        }
    }
}
