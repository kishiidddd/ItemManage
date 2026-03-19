//
//  MainViewController.swift
//  ItemManage
//
//  Created by a on 2026/3/17.
//

import UIKit
import SnapKit
import Kingfisher
import Foundation

class MainViewController: UIViewController {

    private lazy var homeTopView: HomeTopView = {
        let view = HomeTopView()
        view.isUserInteractionEnabled = true
        return view
    }()

    private lazy var grayBg : UIView = {
        let bg = UIView()
        bg.backgroundColor = .lightGrayBgColor
        bg.layer.cornerRadius = 20
        bg.layer.masksToBounds = true
        return bg
    }()

    private lazy var messageScrollView = HomeMessageScrollView()
    private lazy var searchView = HomeSearchView()
    private lazy var itemsView = HomeItemsView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupTapBack()
    }
    
    private func setupTapBack(){
        homeTopView.onAddTapped = {
            let vc = AddItemViewController()
            self.navigateToViewController(vc)
        }
    }

    private func setupUI(){
        view.addSubview(homeTopView)
        view.addSubview(grayBg)
        view.addSubview(messageScrollView)
        view.addSubview(searchView)
        view.addSubview(itemsView)
    }

    private func setupConstraints(){

        homeTopView.snp.makeConstraints{ make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(320)
        }

        grayBg.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(180)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(100)
        }

        messageScrollView.snp.makeConstraints { make in
            make.top.equalTo(grayBg.snp.top).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(104)
        }

        searchView.snp.makeConstraints { make in
            make.top.equalTo(messageScrollView.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(48)
        }

        itemsView.snp.makeConstraints { make in
            make.top.equalTo(searchView.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview()
        }



    }

}

