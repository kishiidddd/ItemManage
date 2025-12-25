
# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'   # 建议最低用 iOS 12 起，不要用 9.0 太老了

#source 'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'
#source 'https://github.com/CocoaPods/Specs.git'
source 'https://cdn.cocoapods.org/'

target 'ItemManage' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ItemManage

  pod 'JXSegmentedView'
  # 网络
  pod 'Alamofire'

  # JSON
  #pod 'HandyJSON'
  pod 'SwiftyJSON'

  # 图片加载
  pod 'Kingfisher'

  # UI 布局
  pod 'SnapKit'

  # 轮播图
  pod 'FSPagerView'

  # 动画
  pod 'lottie-ios'

  # 全屏返回
  pod 'FDFullscreenPopGesture'

  # 导航栏美化
  pod 'GKNavigationBarSwift'

  # 视频播放器
  pod 'SJVideoPlayer'

  # Swift 常用扩展
  pod 'SwifterSwift'

  # 加密工具
  pod 'CryptoSwift'

  #键盘
  pod 'IQKeyboardManagerSwift'

 # 指定HandyJSON版本以解决Release编译问题
#  pod 'HandyJSON', '5.0.2-beta'
  
#  pod 'HandyJSON', :git => 'https://github.com/Miles-Matheson/HandyJSON.git'


end


post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
#    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    config.build_settings['CODE_SIGN_IDENTITY'] = ''
  end
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "15.0"
        
        # 为HandyJSON添加编译优化设置
        if target.name == 'HandyJSON'
          config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
          config.build_settings['GCC_OPTIMIZATION_LEVEL'] = '0'
          config.build_settings['SWIFT_COMPILATION_MODE'] = 'wholemodule'
        end
      end
    end
end