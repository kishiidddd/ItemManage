//
//  File.swift
//  ItemManage
//
//  Created by xiny on 2025/12/13.
//

import Foundation
import UIKit

class GuideTabViewController: UIViewController {
    private lazy var text:UILabel={
       let text = UILabel()
        text.text = "guide"
        return text
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI(){
        view.addSubview(text)
        
        text.snp.makeConstraints{ make in
            make.centerX.centerY.equalToSuperview()
        }
    }

}
