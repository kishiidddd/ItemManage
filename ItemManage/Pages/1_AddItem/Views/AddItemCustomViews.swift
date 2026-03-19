
import UIKit
import Lottie
import SnapKit


// MARK: - Section View
class SectionView: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemGray
        return label
    }()
    
    private let footerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemGray2
        label.numberOfLines = 0
        return label
    }()
    
    let contentStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        sv.backgroundColor = .systemBackground
        sv.layer.cornerRadius = 10
        sv.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        sv.isLayoutMarginsRelativeArrangement = true
        return sv
    }()
    
    var footerText: String? {
        didSet {
            footerLabel.text = footerText
            footerLabel.isHidden = footerText == nil
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(title: String) {
        self.init(frame: .zero)
        titleLabel.text = title
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        addSubview(titleLabel)
        addSubview(contentStack)
        addSubview(footerLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        contentStack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
        }
        
        footerLabel.snp.makeConstraints { make in
            make.top.equalTo(contentStack.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview()
        }
    }
}

// MARK: - Custom TextField
class CustomTextField: UIView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        return label
    }()
    
    let textField: UITextField = {
        let tf = UITextField()
        tf.font = .systemFont(ofSize: 16)
        tf.textAlignment = .right
        tf.clearButtonMode = .whileEditing
        return tf
    }()
    
    private let requiredStar: UILabel = {
        let label = UILabel()
        label.text = "*"
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 16)
        label.isHidden = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        addSubview(titleLabel)
        addSubview(requiredStar)
        addSubview(textField)
        
        titleLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.leading.equalToSuperview()
        }
        
        requiredStar.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.leading.equalTo(titleLabel.snp.trailing).offset(2)
        }
        
        textField.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.leading.equalTo(requiredStar.snp.trailing).offset(8)
            make.trailing.equalToSuperview()
            make.width.greaterThanOrEqualTo(120)
        }
    }
    
    func configure(title: String, placeholder: String?, isRequired: Bool = false, keyboardType: UIKeyboardType = .default) {
        titleLabel.text = title
        textField.placeholder = placeholder
        textField.keyboardType = keyboardType
        requiredStar.isHidden = !isRequired
    }
    
    func setText(_ text: String) {
        textField.text = text
    }
    
    func getText() -> String {
        return textField.text ?? ""
    }
}

// MARK: - Custom Picker Field
class CustomPickerField: UIControl {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .systemGray
        label.textAlignment = .right
        return label
    }()
    
    private let requiredStar: UILabel = {
        let label = UILabel()
        label.text = "*"
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 16)
        label.isHidden = true
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "chevron.right")
        iv.tintColor = .systemGray3
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        addSubview(titleLabel)
        addSubview(requiredStar)
        addSubview(valueLabel)
        addSubview(arrowImageView)
        
        titleLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.leading.equalToSuperview()
        }
        
        requiredStar.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.leading.equalTo(titleLabel.snp.trailing).offset(2)
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        valueLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.leading.equalTo(requiredStar.snp.trailing).offset(8)
            make.trailing.equalTo(arrowImageView.snp.leading).offset(-8)
        }
    }
    
    func configure(title: String, placeholder: String, isRequired: Bool = false) {
        titleLabel.text = title
        valueLabel.text = placeholder
        valueLabel.textColor = .systemGray
        requiredStar.isHidden = !isRequired
    }
    
    func setValue(_ value: String) {
        valueLabel.text = value
        valueLabel.textColor = .label
    }
}

// MARK: - Custom Stepper Field
class CustomStepperField: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        label.textAlignment = .center
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let stepper: UIStepper = {
        let stepper = UIStepper()
        stepper.stepValue = 1
        return stepper
    }()
    
    var onValueChanged: ((Int) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        addSubview(titleLabel)
        addSubview(valueLabel)
        addSubview(stepper)
        
        titleLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.leading.equalToSuperview()
        }
        
        stepper.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        valueLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(stepper.snp.leading).offset(-12)
            make.width.greaterThanOrEqualTo(50)
        }
        
        stepper.addTarget(self, action: #selector(stepperValueChanged), for: .valueChanged)
    }
    
    func configure(title: String, value: Int, minValue: Int, maxValue: Int) {
        titleLabel.text = title
        stepper.minimumValue = Double(minValue)
        stepper.maximumValue = Double(maxValue)
        setValue(value)
    }
    
    func setValue(_ value: Int) {
        stepper.value = Double(value)
        valueLabel.text = "\(value)"
    }
    
    @objc private func stepperValueChanged() {
        let value = Int(stepper.value)
        valueLabel.text = "\(value)"
        onValueChanged?(value)
    }
}

//
//  CustomDateField.swift
//  ItemManage
//
//  Created by a on 2026/3/17.
//

import UIKit
import SnapKit

class CustomDateField: UIControl {
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .systemGray
        label.textAlignment = .right
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "calendar")
        iv.tintColor = .systemGray3
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private var selectedDate: Date?
    
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
        
        addSubview(titleLabel)
        addSubview(valueLabel)
        addSubview(arrowImageView)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.leading.equalToSuperview()
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        valueLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.trailing.equalTo(arrowImageView.snp.leading).offset(-8)
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(16)
        }
    }
    
    // MARK: - Public Methods
    func configure(title: String, placeholder: String) {
        titleLabel.text = title
        valueLabel.text = placeholder
        valueLabel.textColor = .systemGray
    }
    
    func setDate(_ date: Date) {
        selectedDate = date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        valueLabel.text = formatter.string(from: date)
        valueLabel.textColor = .label
    }
    
    func setPlaceholder(_ placeholder: String) {
        valueLabel.text = placeholder
        valueLabel.textColor = .systemGray
        selectedDate = nil
    }
    
    func getDate() -> Date? {
        return selectedDate
    }
}

//
//  CustomTextView.swift
//  ItemManage
//
//  Created by a on 2026/3/17.
//

import UIKit
import SnapKit

class CustomTextView: UIView {
    
    // MARK: - Properties
    private var maxLength: Int = 200
    var onTextChanged: ((String) -> Void)?
    
    // MARK: - UI Elements
    private let textView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 16)
        tv.layer.cornerRadius = 8
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.systemGray5.cgColor
        tv.isScrollEnabled = true
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        return tv
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray3
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemGray2
        label.textAlignment = .right
        return label
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        setupTextView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupConstraints()
        setupTextView()
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear
        addSubview(textView)
        addSubview(placeholderLabel)
        addSubview(countLabel)
    }
    
    private func setupConstraints() {
        textView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.greaterThanOrEqualTo(120)
        }
        
        placeholderLabel.snp.makeConstraints { make in
            make.top.equalTo(textView).offset(16)
            make.leading.equalTo(textView).offset(16)
            make.trailing.equalTo(textView).offset(-16)
        }
        
        countLabel.snp.makeConstraints { make in
            make.top.equalTo(textView.snp.bottom).offset(6)
            make.trailing.equalTo(textView)
            make.bottom.equalToSuperview()
            make.height.equalTo(20)
        }
    }
    
    private func setupTextView() {
        textView.delegate = self
    }
    
    // MARK: - Public Methods
    func configure(placeholder: String, maxLength: Int = 200) {
        self.placeholderLabel.text = placeholder
        self.maxLength = maxLength
        updateCountLabel()
    }
    
    func setText(_ text: String) {
        textView.text = text
        placeholderLabel.isHidden = !text.isEmpty
        updateCountLabel()
        onTextChanged?(text)
    }
    
    func getText() -> String {
        return textView.text
    }
    
    private func updateCountLabel() {
        let count = textView.text.count
        countLabel.text = "\(count)/\(maxLength)"
        countLabel.textColor = count > maxLength ? .systemRed : .systemGray2
    }
}

// MARK: - UITextViewDelegate
extension CustomTextView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        updateCountLabel()
        onTextChanged?(textView.text)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        // 允许删除操作（当新文本为空时）
        if updatedText.isEmpty {
            return true
        }
        
        return updatedText.count <= maxLength
    }
}
