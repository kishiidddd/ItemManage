//
//  BaseViewController.swift
//  ItemManage
//
//  Created by xiny on 2025/12/14.
//
import UIKit

class BaseViewController : UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setLeftBtnItem(){
        let leftbtn = UIButton(type: .custom)
        leftbtn.setImage(UIImage(named: "left_back"), for: .normal)
        leftbtn.addTarget(self, action: #selector(leftBtnTapped), for: .touchUpInside)
        leftbtn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        let leftBtnItem = UIBarButtonItem(customView: leftbtn)
        self.navigationItem.leftBarButtonItem = leftBtnItem
    }
    
    func setBlueBgItem(){
        let bg = UIImageView()
        bg.image = UIImage(named: "bg_blue")
        bg.contentMode = .scaleAspectFill
        view.addSubview(bg)
        bg.snp.makeConstraints{ make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
        }
    }
    
    
    @objc func leftBtnTapped(){
        if let navigationController = self.navigationController {
            if navigationController.viewControllers.count > 1 {
                navigationController.popViewController(animated: false)
            } else {
                navigationController.dismiss(animated: false, completion: nil)
            }
        } else {
            self.dismiss(animated: false, completion: nil)
        }
    }
}
