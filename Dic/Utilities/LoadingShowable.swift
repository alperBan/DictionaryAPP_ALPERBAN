//
//  LoadingShowable.swift
//  Dic
//
//  Created by Alper Ban on 30.05.2023.
//


import UIKit

protocol LoadingShowable where Self: UIViewController {
    func showLoading ()
    func hideLoading ()
}

extension LoadingShowable {
    func showLoading() {
        LoadingView.shared.startLoading()
    }
    
    func hideLoading() {
        LoadingView.shared.hideLoading()
    }
}
