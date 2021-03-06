
import UIKit
import Alamofire
import CRRefresh

class CategoryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var categories = [Category]()
    private var categoryCollectionview: UICollectionView!
    private let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    private let columnLayout = ColumnFlowLayout(
        cellsPerRow: 4,
        minimumInteritemSpacing: 10,
        minimumLineSpacing: 10,
        sectionInset: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configView()
        
        loadData()
    }
    
    private func configView() {
        let layout: UICollectionViewFlowLayout = columnLayout
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
        layout.itemSize = CGSize(width: view.frame.width, height: 100)
        
        categoryCollectionview = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        categoryCollectionview.dataSource = self
        categoryCollectionview.delegate = self
        categoryCollectionview.register(UINib(nibName: "CategoryCell", bundle: nil), forCellWithReuseIdentifier: "category_cell")
        
        categoryCollectionview.contentInsetAdjustmentBehavior = .always
        categoryCollectionview.showsVerticalScrollIndicator = false
        categoryCollectionview.backgroundColor = UIColor.white
        
        self.view.addSubview(categoryCollectionview)
        
        categoryCollectionview.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            self!.loadData()
        }
    }
    
    private func loadData() {
        categories.removeAll()
        
        self.loadingIndicator.center = self.view.center
        self.loadingIndicator.hidesWhenStopped = true
        self.loadingIndicator.style = UIActivityIndicatorView.Style.gray
        self.view.addSubview(self.loadingIndicator)
        self.loadingIndicator.startAnimating()
        
        Alamofire.request(ADDR.CATEGORIES) .responseJSON { response in
            self.loadingIndicator.stopAnimating()
            
            if let json = response.result.value {
                let jsonData = json as! [String : Any]
                
                let message = jsonData["message"] as! String
                
                if message == "success" {
                    let temp = jsonData["data"] as! [String : Any]
                    let listJson = temp["list"] as! NSArray
                    
                    for postJson in listJson {
                        let postData = postJson as! [String : Any]
                        let name = postData["Name"] as! String
                
                        let category = Category()
                        category.name = name
                        self.categories.append(category)
                    }
                    
                    DispatchQueue.main.async {
                        self.loadingIndicator.stopAnimating()
                        self.categoryCollectionview.reloadData()
                        self.categoryCollectionview.cr.endHeaderRefresh()
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let categoryCell = categoryCollectionview.dequeueReusableCell(withReuseIdentifier: "category_cell", for: indexPath) as! CategoryCollectionViewCell
        
        categoryCell.nameLabel.text = categories[indexPath.row].name
        
        return categoryCell
    }
}
