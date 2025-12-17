//
//  ContentListVC.swift
//  ItemManage
//
//  Created by a on 2025/12/17.
//

import UIKit
import JXSegmentedView

class ContentListVC: UIViewController,JXSegmentedListContainerViewListDelegate{
    func listView() -> UIView {
        return view
    }//?
    
    private let testLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32)
        return label
    }()
    
    init(title:String){
        super.init(nibName: nil, bundle: nil)
        self.testLabel.text = title
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(testLabel)
        testLabel.snp.makeConstraints{ make in
            make.centerX.centerY.equalToSuperview()
        }
        
    }
    
}
