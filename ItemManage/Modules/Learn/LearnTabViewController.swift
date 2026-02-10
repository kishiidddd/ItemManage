//
//  File.swift
//  ItemManage
//
//  Created by xiny on 2025/12/13.
//

import Foundation
import UIKit
import SnapKit
import JXSegmentedView

class LearnTabViewController: UIViewController{
    let segmentedView = JXSegmentedView()
    var listContainer:JXSegmentedListContainerView!
    
    let titles = ["首页","消息息","我的","你好我的","手机","可以"]
    
    private let titleDataSource = JXSegmentedTitleDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white//AppStyle.Color.background
        setupSegmented()
        setupConstraints()
    }
        
    private func setupSegmented(){
        //配置segmented的数据源，标题数据源
        titleDataSource.titles = titles
        titleDataSource.titleNormalColor = UIColor.gray
        titleDataSource.titleSelectedColor = UIColor.black
        titleDataSource.titleNormalFont = UIFont.systemFont(ofSize: 18)
        titleDataSource.titleSelectedFont = UIFont.systemFont(ofSize: 18)
        titleDataSource.itemSpacing = 30
        titleDataSource.isTitleZoomEnabled = true
        segmentedView.dataSource = titleDataSource
        
        //添加指示器
        let lineView = JXSegmentedIndicatorLineView()
        lineView.indicatorWidth = 20
        lineView.indicatorColor = .black // 指示器颜色
        lineView.indicatorHeight = 2    // 指示器高度
        segmentedView.indicators = [lineView]
        
        //创建listContainer并关联segmentedView
        listContainer = JXSegmentedListContainerView(dataSource: self)
        
        view.addSubview(segmentedView)
        view.addSubview(listContainer)
        segmentedView.listContainer = listContainer
        segmentedView.backgroundColor = .blue
        
        segmentedView.backgroundColor = .lightGray.withAlphaComponent(0.3)
    }
    
    private func setupConstraints(){
        // 布局segmentedView：顶部距离安全区20pt，左右贴边，高度50
        segmentedView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        
        // 布局listContainer：在segmentedView下方，底部贴安全区，左右贴边
        listContainer.snp.makeConstraints { make in
            make.top.equalTo(segmentedView.snp.bottom).offset(0)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
    }
    
    private func setupUI(){
       
    }

}

extension LearnTabViewController:JXSegmentedListContainerViewDataSource{
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        return titles.count
    }
    
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> any JXSegmentedListContainerViewListDelegate {
        return LearnCollectionListVC(title: titles[index])
    }
}
