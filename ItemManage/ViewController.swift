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
        view.backgroundColor = .red
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let mainTabBarController = MainTabBarController()
            mainTabBarController.modalPresentationStyle = .fullScreen
            self.present(mainTabBarController, animated: true, completion: nil)
        }
    }

}

