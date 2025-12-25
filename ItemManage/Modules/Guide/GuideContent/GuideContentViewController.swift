
import UIKit
import JXSegmentedView

class GuideContentViewController: UIViewController,JXSegmentedListContainerViewListDelegate{
    
    private var guideItems:[guideItemModel] = []
    
    func listView() -> UIView {
        return view
    }
    
    private let collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.width-32)/2, height: 200)
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(GuideCollectionViewCell.self, forCellWithReuseIdentifier: "GuideCollectionViewCell")
        return view
    }()

    
    init(){
        super.init(nibName: nil, bundle: nil)
        guideItems = [guideItemModel(title: "第一个标题", imageName: "test"),
                      guideItemModel(title: "第22222222222222222222222个标题", imageName: "test"),
                      guideItemModel(title: "第3个标题", imageName: "test"),
                      guideItemModel(title: "第44444个标题", imageName: "test"),
                      guideItemModel(title: "第5个标题", imageName: "test"),
                      guideItemModel(title: "第6个标题", imageName: "test"),
                      guideItemModel(title: "第7个标题", imageName: "test"),
                      guideItemModel(title: "第8个标题", imageName: "test")
        ]
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
    func setupUI(){
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

extension GuideContentViewController: UICollectionViewDataSource,UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return guideItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GuideCollectionViewCell", for: indexPath) as! GuideCollectionViewCell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = guideDetailViewController(item: guideItems[indexPath.item])
        navigationController?.pushViewController(vc, animated: false)
    }
}
