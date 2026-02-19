//
//  testWebViewController.swift
//  ItemManage
//
//  Created by xiny on 2026/2/12.
//
import UIKit

class testWebViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 直接测试网络请求
        testAPI()
    }
    
    func testAPI() {
        // 替换成你的IP！
        let url = URL(string: "http://127.0.0.1:3000/api/guides")!
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ 请求失败:", error.localizedDescription)
                return
            }
            
            guard let data = data else {
                print("❌ 没有数据")
                return
            }
            
            // 打印原始JSON看看
            if let jsonString = String(data: data, encoding: .utf8) {
                print("✅ 收到数据:", jsonString)
            }
            
            // 尝试解析
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("✅ 解析成功:", json)
                }
            } catch {
                print("❌ 解析失败:", error)
            }
        }
        
        task.resume()
    }
}
