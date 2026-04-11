

// Controllers/AddItemViewController.swift
import UIKit
import SnapKit
import Combine

class AddItemViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: AddItemViewControllerDelegate?
    private let viewModel: AddItemViewModel
    private let repository = ItemRepository.shared
    private var activeTextField: UITextField?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = true
        sv.keyboardDismissMode = .interactive
        sv.backgroundColor = .systemGroupedBackground
        return sv
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 20
        sv.distribution = .fill
        sv.alignment = .fill
        return sv
    }()
    
    // MARK: - 基本信息 Section
    private lazy var basicSectionView: SectionView = {
        let view = SectionView(title: "基本信息")
        return view
    }()
    
    private lazy var nameField: CustomTextField = {
        let field = CustomTextField()
        field.configure(
            title: "物品名称",
            placeholder: "请输入物品名称",
            isRequired: true
        )
        field.textField.delegate = self
        field.textField.addTarget(self, action: #selector(nameFieldChanged), for: .editingChanged)
        return field
    }()
    
    private lazy var categoryField: CustomPickerField = {
        let field = CustomPickerField()
        field.configure(title: "分类", placeholder: "请选择分类", isRequired: false)
        field.addTarget(self, action: #selector(categoryTapped), for: .touchUpInside)
        return field
    }()
    
    // 位置选择器 - 一级位置（下拉列表）
    private lazy var primaryLocationField: CustomPickerField = {
        let field = CustomPickerField()
        field.configure(title: "存放位置", placeholder: "请选择位置", isRequired: false)
        field.addTarget(self, action: #selector(primaryLocationTapped), for: .touchUpInside)
        return field
    }()
    
    // 位置选择器 - 二级位置（下拉列表，依赖于一级位置）
    private lazy var secondaryLocationField: CustomPickerField = {
        let field = CustomPickerField()
        field.configure(title: "具体位置", placeholder: "请选择具体位置", isRequired: false)
        field.addTarget(self, action: #selector(secondaryLocationTapped), for: .touchUpInside)
        field.isEnabled = false
        return field
    }()
    
    private lazy var quantityField: CustomStepperField = {
        let field = CustomStepperField()
        field.configure(title: "数量", value: 1, minValue: 1, maxValue: 9999)
        field.onValueChanged = { [weak self] value in
            self?.viewModel.quantity = value
        }
        return field
    }()
    
    private lazy var priceField: CustomTextField = {
        let field = CustomTextField()
        field.configure(
            title: "总价",
            placeholder: "选填",
            keyboardType: .decimalPad
        )
        field.textField.delegate = self
        field.textField.addTarget(self, action: #selector(priceFieldChanged), for: .editingChanged)
        return field
    }()
    
    private lazy var unitField: CustomPickerField = {
        let field = CustomPickerField()
        field.configure(title: "单位", placeholder: "选择单位")
        field.addTarget(self, action: #selector(unitTapped), for: .touchUpInside)
        return field
    }()
    
    // MARK: - 照片 Section
    private lazy var photosSectionView: SectionView = {
        let view = SectionView(title: "物品照片")
        view.footerText = "最多可上传3张照片"
        return view
    }()
    
    private lazy var photosView: PhotosView = {
        let view = PhotosView()
        view.delegate = self
        return view
    }()
    
    // MARK: - 时效信息 Section
    private lazy var timeSectionView: SectionView = {
        let view = SectionView(title: "时效信息")
        return view
    }()
    
    private lazy var shelfLifeField: CustomTextField = {
        let field = CustomTextField()
        field.configure(
            title: "保质期",
            placeholder: "请输入天数（选填）",
            keyboardType: .numberPad
        )
        field.textField.delegate = self
        field.textField.addTarget(self, action: #selector(shelfLifeFieldChanged), for: .editingChanged)
        return field
    }()
    
    private lazy var productionDateField: CustomDateField = {
        let field = CustomDateField()
        field.configure(title: "生产日期", placeholder: "选择日期")
        field.addTarget(self, action: #selector(productionDateTapped), for: .touchUpInside)
        return field
    }()
    
    private lazy var expiryDateField: CustomDateField = {
        let field = CustomDateField()
        field.configure(title: "过期日期", placeholder: "选择日期")
        field.addTarget(self, action: #selector(expiryDateTapped), for: .touchUpInside)
        return field
    }()
    
    // MARK: - 备注 Section
    private lazy var remarksSectionView: SectionView = {
        let view = SectionView(title: "备注信息")
        view.footerText = "最多200字"
        return view
    }()
    
    private lazy var remarksTextView: CustomTextView = {
        let tv = CustomTextView()
        tv.configure(placeholder: "请输入补充说明...", maxLength: 200)
        tv.onTextChanged = { [weak self] text in
            self?.viewModel.remarks = text
        }
        return tv
    }()
    
    // MARK: - Navigation Buttons
    private lazy var saveButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            title: "保存",
            style: .done,
            target: self,
            action: #selector(saveButtonTapped)
        )
        return button
    }()
    
    private lazy var cancelButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            title: "取消",
            style: .plain,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        return button
    }()
    
    // MARK: - Init
    init(item: ItemModel? = nil) {
        self.viewModel = AddItemViewModel(item: item)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = AddItemViewModel()
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupKeyboardHandling()
        setupViewModelObservers()
        viewModel.loadInitialData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.reloadPickersFromRepository()
        updateUI()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = viewModel.isEditing ? "编辑物品" : "添加物品"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        setupStackViewContent()
    }
    
    private func setupStackViewContent() {
        // 基本信息 Section
        stackView.addArrangedSubview(basicSectionView)
        basicSectionView.contentStack.addArrangedSubview(nameField)
        basicSectionView.contentStack.addArrangedSubview(createSeparator())
        basicSectionView.contentStack.addArrangedSubview(categoryField)
        basicSectionView.contentStack.addArrangedSubview(createSeparator())
        basicSectionView.contentStack.addArrangedSubview(primaryLocationField)
        basicSectionView.contentStack.addArrangedSubview(createSeparator())
        basicSectionView.contentStack.addArrangedSubview(secondaryLocationField)
        basicSectionView.contentStack.addArrangedSubview(createSeparator())
        basicSectionView.contentStack.addArrangedSubview(quantityField)
        basicSectionView.contentStack.addArrangedSubview(createSeparator())
        basicSectionView.contentStack.addArrangedSubview(priceField)
        basicSectionView.contentStack.addArrangedSubview(createSeparator())
        basicSectionView.contentStack.addArrangedSubview(unitField)
        
        // 照片 Section
        stackView.addArrangedSubview(photosSectionView)
        photosSectionView.contentStack.addArrangedSubview(photosView)
        
        // 时效信息 Section
        stackView.addArrangedSubview(timeSectionView)
        timeSectionView.contentStack.addArrangedSubview(productionDateField)
        timeSectionView.contentStack.addArrangedSubview(createSeparator())
        timeSectionView.contentStack.addArrangedSubview(shelfLifeField)
        timeSectionView.contentStack.addArrangedSubview(createSeparator())
        timeSectionView.contentStack.addArrangedSubview(expiryDateField)
        
        // 备注 Section
        stackView.addArrangedSubview(remarksSectionView)
        remarksSectionView.contentStack.addArrangedSubview(remarksTextView)
        
        // 添加底部留白
        let bottomSpacer = UIView()
        bottomSpacer.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
        stackView.addArrangedSubview(bottomSpacer)
    }
    
    private func createSeparator() -> UIView {
        let line = UIView()
        line.backgroundColor = .systemGray5
        line.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
        return line
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = saveButton
        saveButton.isEnabled = false
    }
    
    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func shelfLifeFieldChanged() {
        let text = shelfLifeField.getText()
        if let days = Int(text), days > 0 {
            viewModel.setShelfLife(days)
        } else if text.isEmpty {
            viewModel.setShelfLife(nil)
        }
    }
    
    // MARK: - Setup ViewModel Observers
    private func setupViewModelObservers() {
        // 监听数据加载完成
        viewModel.$categories
            .combineLatest(viewModel.$units)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] categories, units in
                if !categories.isEmpty || !units.isEmpty {
                    self?.updateUI()
                }
            }
            .store(in: &cancellables)
        
        // 监听一级位置数据
        viewModel.$primaryLocations
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateUI()
            }
            .store(in: &cancellables)
        
        // 二级位置列表来自计算属性，无 $publisher；随一级位置或位置数据源变化刷新
        Publishers.CombineLatest(viewModel.$selectedPrimaryLocation, viewModel.$primaryLocations)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _, _ in
                guard let self = self else { return }
                self.updateSecondaryLocationFieldState(self.viewModel.availableSecondaryLocations)
            }
            .store(in: &cancellables)
        
        // 监听表单验证状态
        viewModel.$isFormValid
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isValid in
                self?.saveButton.isEnabled = isValid
            }
            .store(in: &cancellables)
        
        // 监听错误消息
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                if let message = message {
                    self?.showError(message)
                }
            }
            .store(in: &cancellables)
        
        // 监听加载状态
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    // 显示加载指示器
                    self?.view.isUserInteractionEnabled = false
                } else {
                    self?.view.isUserInteractionEnabled = true
                }
            }
            .store(in: &cancellables)
        
        setupDataBindings()
    }
    
    private func setupDataBindings() {
        // 监听名称变化
        viewModel.$name
            .receive(on: DispatchQueue.main)
            .sink { [weak self] name in
                self?.nameField.setText(name)
            }
            .store(in: &cancellables)
        
        // 监听分类变化
        viewModel.$selectedCategory
            .receive(on: DispatchQueue.main)
            .sink { [weak self] category in
                if let category = category {
                    self?.categoryField.setValue("\(category.icon) \(category.name)")
                } else {
                    self?.categoryField.setValue("请选择")
                }
            }
            .store(in: &cancellables)
        
        // 监听一级位置变化
        viewModel.$selectedPrimaryLocation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                if let location = location {
                    self?.primaryLocationField.setValue(location.name)
                } else {
                    self?.primaryLocationField.setValue("请选择")
                }
            }
            .store(in: &cancellables)
        
        // 监听二级位置变化
        viewModel.$selectedSecondaryLocation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                if let location = location {
                    self?.secondaryLocationField.setValue(location.name)
                } else {
                    self?.secondaryLocationField.setValue("请选择")
                }
            }
            .store(in: &cancellables)
        
        // 监听数量变化
        viewModel.$quantity
            .receive(on: DispatchQueue.main)
            .sink { [weak self] quantity in
                self?.quantityField.setValue(quantity)
            }
            .store(in: &cancellables)
        
        // 监听价格变化
        viewModel.$totalPrice
            .receive(on: DispatchQueue.main)
            .sink { [weak self] price in
                self?.priceField.setText(price)
            }
            .store(in: &cancellables)
        
        // 监听单位变化
        viewModel.$selectedUnit
            .receive(on: DispatchQueue.main)
            .sink { [weak self] unit in
                self?.unitField.setValue(unit?.name ?? "无")
            }
            .store(in: &cancellables)
        
        // 监听照片变化
        viewModel.$photos
            .receive(on: DispatchQueue.main)
            .sink { [weak self] photos in
                self?.photosView.configure(with: photos, canAddMore: self?.viewModel.canAddMorePhotos ?? true)
            }
            .store(in: &cancellables)
        
        // 监听保质期变化
        viewModel.$shelfLife
            .receive(on: DispatchQueue.main)
            .sink { [weak self] days in
                if let days = days {
                    self?.shelfLifeField.setText("\(days)")
                } else {
                    self?.shelfLifeField.setText("")
                }
            }
            .store(in: &cancellables)
        
        // 监听生产日期变化
        viewModel.$productionDate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] date in
                if let date = date {
                    self?.productionDateField.setDate(date)
                } else {
                    self?.productionDateField.setPlaceholder("选择日期")
                }
            }
            .store(in: &cancellables)
        
        // 监听过期日期
        viewModel.$expiryDate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] date in
                if let date = date {
                    self?.expiryDateField.setDate(date)
                } else {
                    self?.expiryDateField.setPlaceholder("选择日期")
                }
            }
            .store(in: &cancellables)
        
        // 监听备注
        viewModel.$remarks
            .receive(on: DispatchQueue.main)
            .sink { [weak self] remarks in
                self?.remarksTextView.setText(remarks)
            }
            .store(in: &cancellables)
    }
    
    private func updateSecondaryLocationFieldState(_ locations: [SecondaryLocationModel]) {
        if locations.isEmpty {
            secondaryLocationField.isEnabled = false
            secondaryLocationField.setValue("暂无具体位置")
        } else {
            secondaryLocationField.isEnabled = true
            if viewModel.selectedSecondaryLocation == nil {
                secondaryLocationField.setValue("请选择")
            }
        }
    }
    
    @objc private func saveButtonTapped() {
        viewModel.saveItem { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let item):
                    if self.viewModel.isEditing {
                        self.repository.updateItem(item)
                    } else {
                        self.repository.addItem(item)
                    }
                    self.delegate?.addItemViewControllerDidSave(self, item: item)
                    self.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    self.showError(error.localizedDescription)
                }
            }
        }
    }
    
    private func updateUI() {
        nameField.setText(viewModel.name)
        
        if let category = viewModel.selectedCategory {
            categoryField.setValue("\(category.icon) \(category.name)")
        }
        
        if let primaryLocation = viewModel.selectedPrimaryLocation {
            primaryLocationField.setValue(primaryLocation.name)
        }
        
        if let secondaryLocation = viewModel.selectedSecondaryLocation {
            secondaryLocationField.setValue(secondaryLocation.name)
        }
        
        quantityField.setValue(viewModel.quantity)
        priceField.setText(viewModel.totalPrice)
        unitField.setValue(viewModel.selectedUnit?.name ?? "无")
        photosView.configure(with: viewModel.photos, canAddMore: viewModel.canAddMorePhotos)
        
        if let date = viewModel.productionDate {
            productionDateField.setDate(date)
        }
        
        if let days = viewModel.shelfLife {
            shelfLifeField.setText("\(days)")
        } else {
            shelfLifeField.setText("")
        }
        
        if let date = viewModel.expiryDate {
            expiryDateField.setDate(date)
        }
        
        remarksTextView.setText(viewModel.remarks)
    }
    
    @objc private func cancelButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func nameFieldChanged() {
        viewModel.name = nameField.getText()
    }
    
    @objc private func priceFieldChanged() {
        viewModel.totalPrice = priceField.getText()
    }
    
    @objc private func categoryTapped() {
        showCategoryPicker()
    }
    
    @objc private func primaryLocationTapped() {
        showPrimaryLocationPicker()
    }
    
    @objc private func secondaryLocationTapped() {
        showSecondaryLocationPicker()
    }
    
    @objc private func unitTapped() {
        showUnitPicker()
    }
    
    @objc private func productionDateTapped() {
        showDatePicker(for: .production)
    }
    
    @objc private func expiryDateTapped() {
        showDatePicker(for: .expiry)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
              let activeTextField = activeTextField else { return }
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        let activeRect = activeTextField.convert(activeTextField.bounds, to: scrollView)
        scrollView.scrollRectToVisible(activeRect, animated: true)
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    private func showCategoryPicker() {
        let alert = UIAlertController(title: "选择分类", message: nil, preferredStyle: .actionSheet)
        
        for category in viewModel.categories {
            alert.addAction(UIAlertAction(title: "\(category.icon) \(category.name)", style: .default) { [weak self] _ in
                self?.viewModel.selectedCategory = category
            })
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = categoryField
            popover.sourceRect = categoryField.bounds
        }
        
        present(alert, animated: true)
    }
    
    private func showPrimaryLocationPicker() {
        let alert = UIAlertController(title: "选择存放位置", message: nil, preferredStyle: .actionSheet)
        
        for location in viewModel.primaryLocations {
            alert.addAction(UIAlertAction(title: "\(location.icon) \(location.name)", style: .default) { [weak self] _ in
                self?.viewModel.selectedPrimaryLocation = location
                self?.viewModel.selectedSecondaryLocation = nil
            })
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = primaryLocationField
            popover.sourceRect = primaryLocationField.bounds
        }
        
        present(alert, animated: true)
    }
    
    private func showSecondaryLocationPicker() {
        guard let primaryLocation = viewModel.selectedPrimaryLocation else {
            showError("请先选择存放位置")
            return
        }
        
        let secondaryLocations = viewModel.availableSecondaryLocations
        
        guard !secondaryLocations.isEmpty else {
            showError("该位置下暂无具体位置")
            return
        }
        
        let alert = UIAlertController(title: "选择具体位置", message: nil, preferredStyle: .actionSheet)
        
        for location in secondaryLocations {
            alert.addAction(UIAlertAction(title: "\(location.icon) \(location.name)", style: .default) { [weak self] _ in
                self?.viewModel.selectedSecondaryLocation = location
            })
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = secondaryLocationField
            popover.sourceRect = secondaryLocationField.bounds
        }
        
        present(alert, animated: true)
    }
    
    private func showUnitPicker() {
        let alert = UIAlertController(title: "选择单位", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "无", style: .default) { [weak self] _ in
            self?.viewModel.selectedUnit = nil
        })
        
        for unit in viewModel.units {
            alert.addAction(UIAlertAction(title: unit.name, style: .default) { [weak self] _ in
                self?.viewModel.selectedUnit = unit
            })
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = unitField
            popover.sourceRect = unitField.bounds
        }
        
        present(alert, animated: true)
    }
    
    private func showDatePicker(for field: AddItemViewModel.DateField) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        
        let alert = UIAlertController(title: field == .production ? "选择生产日期" : "选择过期日期", message: nil, preferredStyle: .actionSheet)
        
        let datePickerVC = UIViewController()
        datePickerVC.view.addSubview(datePicker)
        datePicker.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
        datePickerVC.preferredContentSize = CGSize(width: 300, height: 200)
        alert.setValue(datePickerVC, forKey: "contentViewController")
        
        if field == .production {
            datePicker.date = viewModel.productionDate ?? Date()
        } else {
            datePicker.date = viewModel.expiryDate ?? Date()
        }
        
        alert.addAction(UIAlertAction(title: "确定", style: .default) { [weak self] _ in
            let selectedDate = datePicker.date
            if field == .production {
                self?.viewModel.updateProductionDate(selectedDate)
            } else {
                self?.viewModel.updateExpiryDate(selectedDate)
            }
        })
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = field == .production ? productionDateField : expiryDateField
            popover.sourceRect = (field == .production ? productionDateField : expiryDateField).bounds
        }
        
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension AddItemViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - PhotosViewDelegate
extension AddItemViewController: PhotosViewDelegate {
    
    func photosViewDidTapAdd(_ photosView: PhotosView) {
        showImagePicker()
    }
    
    func photosView(_ photosView: PhotosView, didDeletePhotoAt index: Int) {
        viewModel.removePhoto(at: index)
        photosView.configure(with: viewModel.photos, canAddMore: viewModel.canAddMorePhotos)
    }
    
    func photosView(_ photosView: PhotosView, didMovePhoto fromIndex: Int, toIndex: Int) {
        viewModel.movePhoto(from: fromIndex, to: toIndex)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension AddItemViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private func showImagePicker() {
        let alert = UIAlertController(title: "选择照片", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "拍照", style: .default) { [weak self] _ in
            self?.openCamera()
        })
        
        alert.addAction(UIAlertAction(title: "从相册选择", style: .default) { [weak self] _ in
            self?.openPhotoLibrary()
        })
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = photosView
            popover.sourceRect = photosView.bounds
        }
        
        present(alert, animated: true)
    }
    
    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showError("相机不可用")
            return
        }
        
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func openPhotoLibrary() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.originalImage] as? UIImage else { return }
        
        saveImageToTempDirectory(image) { [weak self] localPath in
            guard let self = self, let path = localPath else { return }
            
            DispatchQueue.main.async {
                self.viewModel.addPhoto(localPath: path)
                self.photosView.configure(with: self.viewModel.photos, canAddMore: self.viewModel.canAddMorePhotos)
            }
        }
    }
    
    private func saveImageToTempDirectory(_ image: UIImage, completion: @escaping (String?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let fileName = "temp_\(Date().timeIntervalSince1970).jpg"
            let tempDir = FileManager.default.temporaryDirectory
            let fileURL = tempDir.appendingPathComponent(fileName)
            
            guard let data = image.jpegData(compressionQuality: 0.7) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            do {
                try data.write(to: fileURL)
                DispatchQueue.main.async {
                    completion(fileURL.path)
                }
            } catch {
                print("保存图片失败: \(error)")
                DispatchQueue.main.async { completion(nil) }
            }
        }
    }
}

// MARK: - Protocol
protocol AddItemViewControllerDelegate: AnyObject {
    func addItemViewControllerDidSave(_ controller: AddItemViewController, item: ItemModel)
    func addItemViewControllerDidCancel(_ controller: AddItemViewController)
}
