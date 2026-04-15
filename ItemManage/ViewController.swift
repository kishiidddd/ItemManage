//
//  ViewController.swift
//  ItemManage
//
//  Created by xiny on 2025/12/13.
//
//
import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGrayBgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let mainTabBarController = FWMainTabViewController()
            mainTabBarController.modalPresentationStyle = .fullScreen
            self.present(mainTabBarController, animated: true, completion: nil)
        }
    }

}

