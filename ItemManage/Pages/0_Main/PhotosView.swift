
//  PhotosView.swift
//  ItemManage
//
//  Created by a on 2026/3/17.
//

import UIKit
import SnapKit
import Kingfisher

protocol PhotosViewDelegate: AnyObject {
    func photosViewDidTapAdd(_ photosView: PhotosView)
    func photosView(_ photosView: PhotosView, didDeletePhotoAt index: Int)
    func photosView(_ photosView: PhotosView, didMovePhoto fromIndex: Int, toIndex: Int)
}

class PhotosView: UIView {
    
    // MARK: - Properties
    weak var delegate: PhotosViewDelegate?
    private var photos: [PhotoModel] = []
    private var canAddMore: Bool = true
    
    // 长按拖动相关
    private var longPressGesture: UILongPressGestureRecognizer?
    private var isReordering = false
    private var draggedView: UIView?
    private var dragIndexPath: IndexPath?
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "物品照片"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        cv.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.identifier)
        cv.register(AddPhotoCell.self, forCellWithReuseIdentifier: AddPhotoCell.identifier)
        return cv
    }()
    
    private let hintLabel: UILabel = {
        let label = UILabel()
        label.text = "长按照片可以拖动排序"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemGray2
        return label
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        setupLongPressGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear
        addSubview(titleLabel)
        addSubview(countLabel)
        addSubview(collectionView)
        addSubview(hintLabel)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview()
        }
        
        countLabel.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(100)
        }
        
        hintLabel.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(8)
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
        }
    }
    
    private func setupLongPressGesture() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 0.5
        collectionView.addGestureRecognizer(longPress)
        self.longPressGesture = longPress
    }
    
    // MARK: - Public Methods
    func configure(with photos: [PhotoModel], canAddMore: Bool) {
        self.photos = photos
        self.canAddMore = canAddMore
        countLabel.text = "\(photos.count)/3"
        collectionView.reloadData()
    }
    
    // MARK: - Actions
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: collectionView)
        
        switch gesture.state {
        case .began:
            guard let indexPath = collectionView.indexPathForItem(at: location),
                  indexPath.item < photos.count else {
                return
            }
            
            isReordering = true
            collectionView.beginInteractiveMovementForItem(at: indexPath)
            
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(location)
            
        case .ended:
            isReordering = false
            collectionView.endInteractiveMovement()
            
        default:
            isReordering = false
            collectionView.cancelInteractiveMovement()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension PhotosView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return canAddMore ? photos.count + 1 : photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if canAddMore && indexPath.item == photos.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddPhotoCell.identifier, for: indexPath) as! AddPhotoCell
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: indexPath) as! PhotoCell
        let photo = photos[indexPath.item]
        cell.configure(with: photo, index: indexPath.item)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return indexPath.item < photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard sourceIndexPath.item < photos.count,
              destinationIndexPath.item < photos.count else {
            return
        }
        
        delegate?.photosView(self, didMovePhoto: sourceIndexPath.item, toIndex: destinationIndexPath.item)
    }
}

// MARK: - UICollectionViewDelegate
extension PhotosView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if canAddMore && indexPath.item == photos.count {
            delegate?.photosViewDidTapAdd(self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        if proposedIndexPath.item >= photos.count {
            return IndexPath(item: photos.count - 1, section: 0)
        }
        return proposedIndexPath
    }
}

// MARK: - PhotoCellDelegate
extension PhotosView: PhotoCellDelegate {
    func photoCellDidTapDelete(_ cell: PhotoCell, at index: Int) {
        delegate?.photosView(self, didDeletePhotoAt: index)
    }
}

// MARK: - Photo Cell
protocol PhotoCellDelegate: AnyObject {
    func photoCellDidTapDelete(_ cell: PhotoCell, at index: Int)
}

class PhotoCell: UICollectionViewCell {
    
    static let identifier = "PhotoCell"
    
    weak var delegate: PhotoCellDelegate?
    private var index: Int = 0
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.backgroundColor = .systemGray6
        return iv
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .systemRed
        button.backgroundColor = .white
        button.layer.cornerRadius = 12
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(deleteButton)
        
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        deleteButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.trailing.equalToSuperview().offset(-4)
            make.width.height.equalTo(24)
        }
    }
    
    func configure(with photo: PhotoModel, index: Int) {
        self.index = index
        
        if let localPath = photo.localPath {
            imageView.image = UIImage(contentsOfFile: localPath)
        } else if !photo.url.isEmpty {
            imageView.kf.setImage(with: URL(string: photo.url), placeholder: UIImage(systemName: "photo"))
        }
    }
    
    @objc private func deleteButtonTapped() {
        delegate?.photoCellDidTapDelete(self, at: index)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        imageView.kf.cancelDownloadTask()
    }
}

// MARK: - Add Photo Cell
class AddPhotoCell: UICollectionViewCell {
    
    static let identifier = "AddPhotoCell"
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray4.cgColor
        return view
    }()
    
    private let plusImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "plus.circle")
        iv.tintColor = .systemGray3
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "添加照片"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemGray3
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(plusImageView)
        containerView.addSubview(label)
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        plusImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-10)
            make.width.height.equalTo(30)
        }
        
        label.snp.makeConstraints { make in
            make.top.equalTo(plusImageView.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
    }
}
