//
//  File.swift
//  ItemManage
//
//  Created by xiny on 2025/12/13.
//

import Foundation
import UIKit
import SnapKit

class HomeTabViewController: UIViewController {

    private lazy var text:UILabel={
       let text = UILabel()
        text.text = "home"
        return text
    }()
    
    private lazy var settingBtn:UIButton = {
       let btn = UIButton()
        btn.setImage(UIImage(named: "icon_setting"), for: .normal)
        btn.contentMode = .scaleAspectFit
        btn.addTarget(self, action: #selector(settingBtnTapped), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    private func setupUI(){
        view.addSubview(text)
        view.addSubview(settingBtn)
        
        
    }
    
    private func setupConstraints(){
        text.snp.makeConstraints{ make in
            make.centerX.centerY.equalToSuperview()
        }
        
        settingBtn.snp.makeConstraints{ make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.left.equalToSuperview().offset(16)
            make.height.width.equalTo(44)
        }
    }

    @objc func settingBtnTapped(){
        let vc = SettingViewController()
        self.navigationController?.pushViewController(vc, animated: false)
    }

}
