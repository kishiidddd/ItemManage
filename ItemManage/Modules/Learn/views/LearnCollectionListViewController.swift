////
////  ContentListVC.swift
////  ItemManage
////
////  Created by a on 2025/12/17.
////
//
//import UIKit
//import JXSegmentedView
//
//class LearnCollectionListVC: UIViewController,JXSegmentedListContainerViewListDelegate{
//    func listView() -> UIView {
//        return view
//    }//?
//    
//    private let testLabel : UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 32)
//        return label
//    }()
//    
//    private let learnCollectionView:UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .vertical
//        layout.minimumInteritemSpacing = 10
//        layout.minimumLineSpacing = 10
//        
//        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        cv.backgroundColor = AppStyle.Color.card
//        cv.register(LearnCollectionViewCell.self, forCellWithReuseIdentifier: LearnCollectionViewCell.identifier)
////        cv.delegate = self
////        cv.dataSource = self
//        return cv
//    }()
//    
//    init(title:String){
//        super.init(nibName: nil, bundle: nil)
//        self.testLabel.text = title
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError()
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        view.addSubview(testLabel)
//        testLabel.snp.makeConstraints{ make in
//            make.centerX.centerY.equalToSuperview()
//        }
//        
//    }
//    
//}
//
//extension LearnCollectionListVC:UICollectionViewDelegateFlowLayout,UICollectionViewDataSource{
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        <#code#>
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        <#code#>
//    }
//    
//    
//}

//
//  ContentListVC.swift
//  ItemManage
//
//  Created by a on 2025/12/17.
//

import UIKit
import JXSegmentedView

class LearnCollectionListVC: UIViewController, JXSegmentedListContainerViewListDelegate {
    
    func listView() -> UIView {
        return view
    }
    
    // MARK: - UI Components
    private let testLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    private let learnCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell") // 使用系统cell
        return cv
    }()
    
    // MARK: - 简单数据源
    private let itemTitles = ["项目1", "项目2", "项目3", "项目4", "项目5", "项目6", "项目7", "项目8"]
    
    // MARK: - Initialization
    init(title: String) {
        super.init(nibName: nil, bundle: nil)
        self.testLabel.text = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(testLabel)
        testLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        view.addSubview(learnCollectionView)
        learnCollectionView.snp.makeConstraints { make in
            make.top.equalTo(testLabel.snp.bottom).offset(20)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    private func setupCollectionView() {
        learnCollectionView.delegate = self
        learnCollectionView.dataSource = self
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension LearnCollectionListVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemTitles.count // 返回数组长度
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        // 清除之前的内容
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        // 设置cell样式
        cell.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        cell.layer.cornerRadius = 8
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.systemBlue.cgColor
        
        // 添加标签
        let label = UILabel()
        label.text = itemTitles[indexPath.item]
        label.textAlignment = .center
        label.textColor = .black
        cell.contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("点击了: \(itemTitles[indexPath.item])")
        
        // 简单的点击效果
        if let cell = collectionView.cellForItem(at: indexPath) {
            UIView.animate(withDuration: 0.2, animations: {
                cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }) { _ in
                UIView.animate(withDuration: 0.2) {
                    cell.transform = .identity
                }
            }
        }
    }
    
    // MARK: - Cell大小设置
    func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 每行显示2个cell
        let spacing: CGFloat = 20 // 左右边距各10
        let width = (collectionView.bounds.width - spacing * 3) / 2
        return CGSize(width: width, height: width) // 正方形cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
    }
}
