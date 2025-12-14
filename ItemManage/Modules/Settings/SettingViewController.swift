//
//  SettingViewController.swift
//  ItemManage
//
//  Created by xiny on 2025/12/14.
//

import UIKit

struct settingItem{
    let iconImageName:String
    let title:String
}

class SettingViewController: BaseViewController {

    var settingItems:[settingItem] = [
        settingItem(iconImageName: "setting_1", title: "用户协议"),
        settingItem(iconImageName: "setting_2", title: "隐私政策"),
        settingItem(iconImageName: "setting_3", title: "使用说明"),
        settingItem(iconImageName: "setting_4", title: "版本号")
    ]
    
    private lazy var settingTableView:UITableView = {
        let table = UITableView()
        table.layer.cornerRadius = AppStyle.Size.cornerCard
        table.tintColor = AppStyle.Color.card
        table.register(SettingTableViewCell.self, forCellReuseIdentifier: "SettingTableViewCell")
        table.separatorStyle = .none
        table.dataSource = self
        table.delegate = self
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "设置"
        self.setLeftBtnItem()
        self.setBlueBgItem()
        setupUI()
        setupContraints()
    }
    
    private func setupUI(){
        view.addSubview(settingTableView)
    }
    
    private func setupContraints(){
        settingTableView.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(360)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(settingItems.count * 56)
        }
    }
}

extension SettingViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingItems.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = settingItems[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            print("点击用户协议")
        case 1:
            print("点击隐私政策")
        case 2:
            print("点击使用说明")
        case 3:
            print("点击版本号：\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "1.0.0")")
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingTableViewCell", for: indexPath) as? SettingTableViewCell else{
            return UITableViewCell()
        }
        
        let item = settingItems[indexPath.row]
        cell.configure(with: item)
        return cell
    }

}
