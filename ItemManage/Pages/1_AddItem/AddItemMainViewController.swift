
//
//  AddItemMainViewController.swift
//  ItemManage
//
//  Created by a on 2026/3/17.
//

import UIKit
import SnapKit

class AddItemMainViewController: UIViewController {

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
    
    // MARK: - 三个添加方式的卡片
    private lazy var scanCard: AddMethodCard = {
        let card = AddMethodCard()
        card.configure(
            backgroundImage: "add_bg_picture",
            iconImage: "add_icon_picture",
            title: "拍照识别",
            subtitle: "拍摄物品智能识别",
            tag: 0
        )
        card.delegate = self
        return card
    }()
    
    private lazy var barcodeCard: AddMethodCard = {
        let card = AddMethodCard()
        card.configure(
            backgroundImage: "add_bg_scane",
            iconImage: "add_icon_scane",
            title: "扫描条码",
            subtitle: "扫描商品条形码添加",
            tag: 1
        )
        card.delegate = self
        return card
    }()
    
    private lazy var manualCard: AddMethodCard = {
        let card = AddMethodCard()
        card.configure(
            backgroundImage: "add_bg_hand",
            iconImage: "add_icon_hand",
            title: "手动输入",
            subtitle: "手动填写物品信息添加",
            tag: 2
        )
        card.delegate = self
        return card
    }()
    
    private lazy var cardsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(homeTopView)
        view.addSubview(grayBg)
        
        // 添加卡片到 grayBg
        grayBg.addSubview(cardsStackView)
        
        // 将三个卡片添加到 stackView
        cardsStackView.addArrangedSubview(scanCard)
        cardsStackView.addArrangedSubview(barcodeCard)
        cardsStackView.addArrangedSubview(manualCard)
    }
    
    private func setupConstraints() {
        homeTopView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(320)
        }
        
        grayBg.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(180)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(100)
        }

        cardsStackView.snp.makeConstraints { make in
            make.top.equalTo(grayBg.snp.top).offset(24)
            make.height.equalTo(344)//104*3+ 16*2
            make.left.equalTo(grayBg.snp.left).offset(12)
            make.right.equalTo(grayBg.snp.right).offset(-12)
            
        }
    }
}

// MARK: - AddMethodCardDelegate
extension AddItemMainViewController: AddMethodCardDelegate {
    func addMethodCardDidTapAdd(_ card: AddMethodCard, tag: Int) {
        switch tag {
        case 0:
            print("点击了拍照识别")
            showCustomAlert(
                title: "提示",
                subtitle: "确定要删除这个物品吗？\n此操作不可恢复。",
                cancelTitle: "再想想",
                confirmTitle: "确认删除",
                onCancel: {
                    print("用户取消了")
                },
                onConfirm: {
                    print("用户确认了")
                    // 执行删除操作
//                    self.deleteItem()
                }
            )
            // 跳转到拍照识别页面
//            let scanVC = ScanViewController() // 你需要创建这个控制器
//            navigationController?.pushViewController(scanVC, animated: true)
            
        case 1:
            print("点击了扫描条码")
            // 跳转到扫描条码页面
            let barcodeVC = AccManageViewController()//BarcodeScanViewController() // 你需要创建这个控制器
            navigationController?.pushViewController(barcodeVC, animated: true)
            
        case 2:
            print("点击了手动输入")
            // 跳转到手动输入页面（原来的添加物品页面）
            let addItemVC = LoginViewController()//AddItemViewController()
            navigationController?.pushViewController(addItemVC, animated: true)
            
        default:
            break
        }
    }
}

// MARK: - AddMethodCard 自定义卡片组件
protocol AddMethodCardDelegate: AnyObject {
    func addMethodCardDidTapAdd(_ card: AddMethodCard, tag: Int)
}

class AddMethodCard: UIView {
    
    weak var delegate: AddMethodCardDelegate?
    private var cardTag: Int = 0
    
    // MARK: - UI Elements
    private lazy var backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
        iv.backgroundColor = .systemGray6
        return iv
    }()
    
    private lazy var iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        return iv
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .text1Color
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .text2Color
        return label
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("去添加", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.backgroundColor = .text1Color
        button.layer.cornerRadius = 22
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var textStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 4
        sv.alignment = .leading
        return sv
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear
        
        isUserInteractionEnabled = true
        backgroundImageView.isUserInteractionEnabled = true
        
        addSubview(backgroundImageView)
        backgroundImageView.addSubview(iconImageView)
        backgroundImageView.addSubview(textStackView)
        backgroundImageView.addSubview(addButton)
        
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(subtitleLabel)
    }
    
    private func setupConstraints() {
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(104) // 固定卡片高度
        }
        
        iconImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(75)
        }
        
        textStackView.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(12)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualTo(addButton.snp.left).offset(-12)
        }
        
        addButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.width.equalTo(105)
            make.height.equalTo(45)
        }
    }
    
    // MARK: - Public Methods
    func configure(backgroundImage: String, iconImage: String, title: String, subtitle: String, tag: Int) {
        // 设置背景图片
        if let bgImage = UIImage(named: backgroundImage) {
            backgroundImageView.image = bgImage
        } else {
            // 如果没有找到图片，设置一个渐变色作为后备
            setGradientBackground()
        }
        
        // 设置图标
        iconImageView.image = UIImage(named: iconImage)?.withRenderingMode(.alwaysOriginal)
        
        titleLabel.text = title
        subtitleLabel.text = subtitle
        cardTag = tag
    }
    
    private func setGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [
            UIColor.systemBlue.cgColor,
            UIColor.systemPurple.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = 16
        
        backgroundImageView.layer.insertSublayer(gradientLayer, at: 0)
        backgroundImageView.backgroundColor = .clear
    }
    
    // MARK: - Actions
    @objc private func addButtonTapped() {
        delegate?.addMethodCardDidTapAdd(self, tag: cardTag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 更新渐变层的大小
        if let gradientLayer = backgroundImageView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = backgroundImageView.bounds
        }
    }
}

