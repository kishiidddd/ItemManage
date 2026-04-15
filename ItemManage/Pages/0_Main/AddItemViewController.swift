// AddItemViewController.swift — 单文件：界面 + 与 AddItemViewModel 的绑定（简单 MVVM）
import UIKit
import SnapKit
import Combine

class AddItemViewController: UIViewController {

    weak var delegate: AddItemViewControllerDelegate?
    private let viewModel: AddItemViewModel
    private let repository = ItemRepository.shared
    private var activeTextField: UITextField?
    private var cancellables = Set<AnyCancellable>()

    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = true
        sv.keyboardDismissMode = .interactive
        sv.backgroundColor = .lightGrayBgColor
        return sv
    }()

    private lazy var contentView = UIView()
    private lazy var stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 20
        sv.distribution = .fill
        sv.alignment = .fill
        return sv
    }()

    private lazy var basicSectionView = SectionView(title: "")
    private lazy var nameField: CustomTextField = {
        let field = CustomTextField()
        field.configure(title: "物品名称", placeholder: "请输入物品名称", isRequired: true)
        field.textField.delegate = self
        field.textField.addTarget(self, action: #selector(nameFieldChanged), for: .editingChanged)
        return field
    }()

    private lazy var categoryField: CustomPickerField = {
        let field = CustomPickerField()
        field.configure(title: "分类", placeholder: "请选择分类", isRequired: true)
        field.addTarget(self, action: #selector(categoryTapped), for: .touchUpInside)
        return field
    }()

    private lazy var primaryLocationField: CustomPickerField = {
        let field = CustomPickerField()
        field.configure(title: "存放位置", placeholder: "请选择位置", isRequired: false)
        field.addTarget(self, action: #selector(primaryLocationTapped), for: .touchUpInside)
        return field
    }()

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
        field.onValueChanged = { [weak self] value in self?.viewModel.quantity = value }
        return field
    }()

    private lazy var unitField: CustomPickerField = {
        let field = CustomPickerField()
        field.configure(title: "单位", placeholder: "选择单位")
        field.addTarget(self, action: #selector(unitTapped), for: .touchUpInside)
        return field
    }()

    private lazy var photosSectionView = SectionView(title: "")
    private lazy var photosView: PhotosView = {
        let v = PhotosView()
        v.delegate = self
        return v
    }()

    private lazy var timeSectionView = SectionView(title: "")
    private lazy var shelfLifeField: CustomTextField = {
        let field = CustomTextField()
        field.configure(title: "保质期", placeholder: "请输入天数", keyboardType: .numberPad)
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

    private lazy var remarksSectionView = SectionView(title: "")
    private lazy var remarksTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "备注"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        return label
    }()
    private lazy var remarksTextView: CustomTextView = {
        let tv = CustomTextView()
        tv.configure(placeholder: "请输入补充说明...", maxLength: 200)
        tv.onTextChanged = { [weak self] text in self?.viewModel.remarks = text }
        return tv
    }()

    private lazy var saveButton = UIBarButtonItem(
        title: viewModel.isEditing ? "保存" : "添加",
        style: .done,
        target: self,
        action: #selector(saveButtonTapped)
    )

    init(item: ItemModel? = nil) {
        viewModel = AddItemViewModel(item: item)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        viewModel = AddItemViewModel()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        navigationItem.rightBarButtonItem = saveButton
        saveButton.isEnabled = false
        setupKeyboardHandling()
        bindViewModel()
        viewModel.loadInitialData()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.reloadPickersFromRepository()
        refreshFormFromViewModel()
    }

    // MARK: - ViewModel 绑定（Combine）

    private func bindViewModel() {
        viewModel.$categories.combineLatest(viewModel.$units)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] c, u in
                if !c.isEmpty || !u.isEmpty { self?.refreshFormFromViewModel() }
            }
            .store(in: &cancellables)

        viewModel.$primaryLocations
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.refreshFormFromViewModel() }
            .store(in: &cancellables)

        viewModel.$isFormValid
            .receive(on: DispatchQueue.main)
            .sink { [weak self] valid in self?.saveButton.isEnabled = valid }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] msg in if let m = msg { self?.showError(m) } }
            .store(in: &cancellables)

        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.view.isUserInteractionEnabled = !$0 }
            .store(in: &cancellables)

        viewModel.$name.receive(on: DispatchQueue.main).sink { [weak self] in self?.nameField.setText($0) }.store(in: &cancellables)
        viewModel.$selectedCategory.receive(on: DispatchQueue.main).sink { [weak self] c in
            self?.categoryField.setValue(c?.name ?? "请选择")
        }.store(in: &cancellables)
        viewModel.$selectedPrimaryLocation.receive(on: DispatchQueue.main).sink { [weak self] p in
            self?.primaryLocationField.setValue(p?.name ?? "请选择")
        }.store(in: &cancellables)
        viewModel.$quantity.receive(on: DispatchQueue.main).sink { [weak self] in self?.quantityField.setValue($0) }.store(in: &cancellables)
        viewModel.$selectedUnit.receive(on: DispatchQueue.main).sink { [weak self] in
            self?.unitField.setValue($0?.name ?? "无")
        }.store(in: &cancellables)
        viewModel.$photos.receive(on: DispatchQueue.main).sink { [weak self] photos in
            guard let self = self else { return }
            self.photosView.configure(with: photos, canAddMore: self.viewModel.canAddMorePhotos)
        }.store(in: &cancellables)
        viewModel.$shelfLife.receive(on: DispatchQueue.main).sink { [weak self] days in
            if let d = days { self?.shelfLifeField.setText("\(d)") } else { self?.shelfLifeField.setText("") }
        }.store(in: &cancellables)
        viewModel.$productionDate.receive(on: DispatchQueue.main).sink { [weak self] d in
            if let d = d { self?.productionDateField.setDate(d) } else { self?.productionDateField.setPlaceholder("选择日期") }
        }.store(in: &cancellables)
        viewModel.$expiryDate.receive(on: DispatchQueue.main).sink { [weak self] d in
            if let d = d { self?.expiryDateField.setDate(d) } else { self?.expiryDateField.setPlaceholder("选择日期") }
        }.store(in: &cancellables)

        Publishers.CombineLatest3(viewModel.$selectedPrimaryLocation, viewModel.$selectedSecondaryLocation, viewModel.$primaryLocations)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _, _, _ in self?.syncSecondaryLocationUI() }
            .store(in: &cancellables)
    }

    private func syncSecondaryLocationUI() {
        let locs = viewModel.availableSecondaryLocations
        if locs.isEmpty {
            secondaryLocationField.isEnabled = false
            secondaryLocationField.setValue("暂无具体位置")
            return
        }
        secondaryLocationField.isEnabled = true
        secondaryLocationField.setValue(viewModel.selectedSecondaryLocation?.name ?? "请选择")
    }

    private func refreshFormFromViewModel() {
        nameField.setText(viewModel.name)
        categoryField.setValue(viewModel.selectedCategory?.name ?? "请选择")
        primaryLocationField.setValue(viewModel.selectedPrimaryLocation?.name ?? "请选择")
        syncSecondaryLocationUI()
        quantityField.setValue(viewModel.quantity)
        unitField.setValue(viewModel.selectedUnit?.name ?? "无")
        photosView.configure(with: viewModel.photos, canAddMore: viewModel.canAddMorePhotos)
        if let d = viewModel.productionDate { productionDateField.setDate(d) }
        if let days = viewModel.shelfLife { shelfLifeField.setText("\(days)") } else { shelfLifeField.setText("") }
        if let d = viewModel.expiryDate { expiryDateField.setDate(d) }
        remarksTextView.setText(viewModel.remarks)
    }

    // MARK: - UI

    private func setupUI() {
        view.backgroundColor = .lightGrayBgColor
        title = viewModel.isEditing ? "编辑物品" : "添加物品"
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        stackView.snp.makeConstraints { $0.edges.equalToSuperview().inset(16) }

        stackView.addArrangedSubview(basicSectionView)
        for row in [nameField, categoryField, primaryLocationField, secondaryLocationField, quantityField, unitField] as [UIView] {
            basicSectionView.contentStack.addArrangedSubview(row)
            basicSectionView.contentStack.addArrangedSubview(separator())
        }
        basicSectionView.contentStack.arrangedSubviews.last?.removeFromSuperview()

        stackView.addArrangedSubview(photosSectionView)
        photosSectionView.contentStack.addArrangedSubview(photosView)

        stackView.addArrangedSubview(timeSectionView)
        for row in [productionDateField, shelfLifeField, expiryDateField] as [UIView] {
            timeSectionView.contentStack.addArrangedSubview(row)
            timeSectionView.contentStack.addArrangedSubview(separator())
        }
        timeSectionView.contentStack.arrangedSubviews.last?.removeFromSuperview()

        stackView.addArrangedSubview(remarksSectionView)
        remarksSectionView.contentStack.addArrangedSubview(remarksTitleLabel)
        remarksSectionView.contentStack.addArrangedSubview(remarksTextView)

        let spacer = UIView()
        spacer.snp.makeConstraints { $0.height.equalTo(20) }
        stackView.addArrangedSubview(spacer)
    }

    private func separator() -> UIView {
        let line = UIView()
        line.backgroundColor = .systemGray5
        line.snp.makeConstraints { $0.height.equalTo(1) }
        return line
    }

    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    // MARK: - Actions

    @objc private func shelfLifeFieldChanged() {
        let text = shelfLifeField.getText()
        if let days = Int(text), days > 0 { viewModel.setShelfLife(days) }
        else if text.isEmpty { viewModel.setShelfLife(nil) }
    }

    @objc private func saveButtonTapped() {
        viewModel.saveItem { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let item):
                    if self.viewModel.isEditing { self.repository.updateItem(item) } else { self.repository.addItem(item) }
                    self.delegate?.addItemViewControllerDidSave(self, item: item)
                    self.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    self.showError(error.localizedDescription)
                }
            }
        }
    }

    @objc private func nameFieldChanged() { viewModel.name = nameField.getText() }
    @objc private func categoryTapped() { showCategoryPicker() }
    @objc private func primaryLocationTapped() { showPrimaryLocationPicker() }
    @objc private func secondaryLocationTapped() { showSecondaryLocationPicker() }
    @objc private func unitTapped() { showUnitPicker() }
    @objc private func productionDateTapped() { showDatePicker(for: .production) }
    @objc private func expiryDateTapped() { showDatePicker(for: .expiry) }

    @objc private func keyboardWillShow(_ n: Notification) {
        guard let rect = (n.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
              let tf = activeTextField else { return }
        scrollView.contentInset.bottom = rect.height
        scrollView.scrollIndicatorInsets.bottom = rect.height
        scrollView.scrollRectToVisible(tf.convert(tf.bounds, to: scrollView), animated: true)
    }

    @objc private func keyboardWillHide(_ n: Notification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }

    @objc private func dismissKeyboard() { view.endEditing(true) }

    private func showError(_ message: String) {
        showCustomAlert(
            title: "提示",
            subtitle: message,
            cancelTitle: nil,
            confirmTitle: "确定"
        )
    }

    // MARK: - 选择器

    private func showCategoryPicker() {
        let alert = UIAlertController(title: "选择分类", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "添加分类", style: .default) { [weak self] _ in
            let vc = CategoryManageViewController()
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: true)
        })
        viewModel.categories.forEach { c in
            alert.addAction(UIAlertAction(title: c.name, style: .default) { [weak self] _ in self?.viewModel.selectedCategory = c })
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.popoverPresentationController?.sourceView = categoryField
        alert.popoverPresentationController?.sourceRect = categoryField.bounds
        present(alert, animated: true)
    }

    private func showPrimaryLocationPicker() {
        let alert = UIAlertController(title: "选择存放位置", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "添加位置", style: .default) { [weak self] _ in
            let vc = LocationManagementViewController()
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: true)
        })
        viewModel.primaryLocations.forEach { loc in
            alert.addAction(UIAlertAction(title: loc.name, style: .default) { [weak self] _ in
                self?.viewModel.selectedPrimaryLocation = loc
                self?.viewModel.selectedSecondaryLocation = nil
            })
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.popoverPresentationController?.sourceView = primaryLocationField
        alert.popoverPresentationController?.sourceRect = primaryLocationField.bounds
        present(alert, animated: true)
    }

    private func showSecondaryLocationPicker() {
        guard viewModel.selectedPrimaryLocation != nil else {
            showError("暂无具体位置")
            return
        }
        let list = viewModel.availableSecondaryLocations
        guard !list.isEmpty else {
            showError("该位置下暂无具体位置")
            return
        }
        let alert = UIAlertController(title: "选择具体位置", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "添加位置", style: .default) { [weak self] _ in
            let vc = LocationManagementViewController()
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: true)
        })
        list.forEach { loc in
            alert.addAction(UIAlertAction(title: loc.name, style: .default) { [weak self] _ in
                self?.viewModel.selectedSecondaryLocation = loc
            })
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.popoverPresentationController?.sourceView = secondaryLocationField
        alert.popoverPresentationController?.sourceRect = secondaryLocationField.bounds
        present(alert, animated: true)
    }

    private func showUnitPicker() {
        let alert = UIAlertController(title: "选择单位", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "添加单位", style: .default) { [weak self] _ in
            let vc = UnitManageViewController()
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: true)
        })
        alert.addAction(UIAlertAction(title: "无", style: .default) { [weak self] _ in self?.viewModel.selectedUnit = nil })
        viewModel.units.forEach { u in
            alert.addAction(UIAlertAction(title: u.name, style: .default) { [weak self] _ in self?.viewModel.selectedUnit = u })
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.popoverPresentationController?.sourceView = unitField
        alert.popoverPresentationController?.sourceRect = unitField.bounds
        present(alert, animated: true)
    }

    private func showDatePicker(for field: AddItemViewModel.DateField) {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        dp.preferredDatePickerStyle = .wheels
        dp.locale = Locale(identifier: "zh_Hans_CN")
        dp.calendar = Calendar(identifier: .gregorian)
        let alert = UIAlertController(title: field == .production ? "选择生产日期" : "选择过期日期", message: nil, preferredStyle: .actionSheet)
        let holder = UIViewController()
        holder.view.addSubview(dp)
        dp.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
        holder.preferredContentSize = CGSize(width: 300, height: 200)
        alert.setValue(holder, forKey: "contentViewController")
        dp.date = (field == .production ? viewModel.productionDate : viewModel.expiryDate) ?? Date()
        alert.addAction(UIAlertAction(title: "确定", style: .default) { [weak self] _ in
            if field == .production { self?.viewModel.updateProductionDate(dp.date) } else { self?.viewModel.updateExpiryDate(dp.date) }
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        let src = field == .production ? productionDateField : expiryDateField
        alert.popoverPresentationController?.sourceView = src
        alert.popoverPresentationController?.sourceRect = src.bounds
        present(alert, animated: true)
    }
}

// MARK: - 照片

extension AddItemViewController: PhotosViewDelegate {
    func photosViewDidTapAdd(_ photosView: PhotosView) {
        let alert = UIAlertController(title: "选择照片", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "拍照", style: .default) { [weak self] _ in self?.openCamera() })
        alert.addAction(UIAlertAction(title: "从相册选择", style: .default) { [weak self] _ in self?.openPhotoLibrary() })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.popoverPresentationController?.sourceView = photosView
        alert.popoverPresentationController?.sourceRect = photosView.bounds
        present(alert, animated: true)
    }

    func photosView(_ photosView: PhotosView, didDeletePhotoAt index: Int) {
        viewModel.removePhoto(at: index)
    }

    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { showError("相机不可用"); return }
        let p = UIImagePickerController()
        p.sourceType = .camera
        p.delegate = self
        present(p, animated: true)
    }

    private func openPhotoLibrary() {
        let p = UIImagePickerController()
        p.sourceType = .photoLibrary
        p.delegate = self
        present(p, animated: true)
    }
}

extension AddItemViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            let name = "temp_\(Date().timeIntervalSince1970).jpg"
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(name)
            guard let data = image.jpegData(compressionQuality: 0.7) else { return }
            do {
                try data.write(to: url)
                DispatchQueue.main.async { [weak self] in self?.viewModel.addPhoto(localPath: url.path) }
            } catch { }
        }
    }
}

// MARK: - UITextFieldDelegate

extension AddItemViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) { activeTextField = textField }
    func textFieldDidEndEditing(_ textField: UITextField) { activeTextField = nil }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

protocol AddItemViewControllerDelegate: AnyObject {
    func addItemViewControllerDidSave(_ controller: AddItemViewController, item: ItemModel)
    func addItemViewControllerDidCancel(_ controller: AddItemViewController)
}
