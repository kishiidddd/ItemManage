//
//  ContentListVC.swift
//  ItemManage
//
//  Created by a on 2025/12/17.
//

import UIKit
import JXSegmentedView

class LearnCollectionListVC: UIViewController,JXSegmentedListContainerViewListDelegate{
    func listView() -> UIView {
        return view
    }//?
    
    private let testLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32)
        return label
    }()
    
    private let learnCollectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = AppStyle.Color.card
        cv.register(LearnCollectionViewCell.self, forCellWithReuseIdentifier: LearnCollectionViewCell.identifier)
//        cv.delegate = self
//        cv.dataSource = self
        return cv
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

extension LearnCollectionListVC:UICollectionViewDelegateFlowLayout,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        <#code#>
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        <#code#>
    }
    
    
}
