//
//  MainViewController.swift
//  DBGorgeous-Swift
//
//  Created by 海啸 on 2016/12/11.
//  Copyright © 2016年 海啸. All rights reserved.
//

import UIKit
import SnapKit
import Alamofire
import Ji
import MJExtension
import MJRefresh
import SKPhotoBrowser
import PKHUD

fileprivate let buttonArray = ["所有", "大胸妹","美腿控","有颜值","黑丝袜","小翘臀","大杂烩"]
fileprivate let reuseIdentifier = "Cell"
class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    //MARK: Variable
    //Variable
    var gorgeousUrlsArray : Array<GoregeousUrl>? = [GoregeousUrl]()
    var type: Int = 0
    var page: Int = 1
    //MARK: UI
    //Scroll View
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = UIColor.white
        scrollView.contentSize.width = CGFloat(560)
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    //Set ScrollView 和 button
    func setScrollView() {
        for i in 1...7 {
            //设置button
            let button = UIButton.init(type: .custom)
            self.scrollView.addSubview(button)
            
            //Set button此时用Snapkit失效只能用苹果的api
            button.translatesAutoresizingMaskIntoConstraints = false
            button.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true
            button.leftAnchor.constraint(equalTo: self.scrollView.leftAnchor, constant:CGFloat((i-1)*80)).isActive = true
            button.widthAnchor.constraint(equalToConstant: 80).isActive = true
            button.heightAnchor.constraint(equalToConstant: 40).isActive = true
            button.backgroundColor = UIColor.white
            button.tag = i
            button.setTitle(buttonArray[i-1], for: .normal)
            button.setTitleColor(UIColor.gray, for: .normal)
            button.setTitleColor(UIColor.blue, for: .highlighted)
            button.addTarget(self, action: #selector(touch), for: .touchUpInside)
        }
        self.view.addSubview(self.scrollView)
        self.scrollView.snp.makeConstraints { (make) in
            make.left.width.equalToSuperview()
            make.top.equalToSuperview().offset(64)
            make.height.equalTo(40)
        }
    }
    
    func touch(sender: UIButton) {
        let tag = sender.tag
        
        self.navigationItem.title = buttonArray[tag-1]
        /*
         case All     = 0
         case DaXiong = 2
         case QiaoTun = 6
         case HeiSi   = 7
         case MeiTui  = 3
         case Yanzhi = 4
         case ZaHui   = 5
         */
        
        switch tag {
        case 1:
            self.type =  GorgeousCategory.All.rawValue
        case 2:
            self.type =  GorgeousCategory.DaXiong.rawValue
        case 3:
            self.type =  GorgeousCategory.MeiTui.rawValue
        case 4:
            self.type =  GorgeousCategory.YanZhi.rawValue
        case 5:
            self.type =  GorgeousCategory.HeiSi.rawValue
        case 6:
            self.type =  GorgeousCategory.QiaoTun.rawValue
        default:
            self.type = GorgeousCategory.ZaHui.rawValue
        }
        DispatchQueue(label: "removeGorgeousUrlsArray").sync {
            //需要reloaddata 要不报错 Out of  index
            self.gorgeousUrlsArray?.removeAll(keepingCapacity: false)
            self.collectionView?.reloadData()
            self.collectionView?.mj_header.beginRefreshing()
            self.loadGoregeous(GorgeousCategory: self.type)
        }
        
    }
    
    //CollectionView
    var collectionView: UICollectionView?
    //Set CollectionView
    func setCollectionView() {
        
        let flowLayout = UICollectionViewFlowLayout()
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        collectionView = UICollectionView(frame: frame, collectionViewLayout: flowLayout)
        collectionView?.contentInset = UIEdgeInsetsMake(35, 0, 0, 0)
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(GorgeousCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
        
        self.view.addSubview(self.collectionView!)
    }
    
    //MARK: LifeCycle
    //Set MJ_Refresh
    func setMjRefresh() {
        
        self.collectionView?.mj_header = MJRefreshNormalHeader {
            self.collectionView?.mj_footer.isAutomaticallyChangeAlpha = true
            self.loadGoregeous(GorgeousCategory: self.type)
        }
        
        self.collectionView?.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {
            self.collectionView?.mj_footer.beginRefreshing()
            self.collectionView?.mj_footer.isAutomaticallyChangeAlpha = true
            self.loadNextPage(GorgeousCategory: self.type)
        })
        
        self.collectionView?.mj_header.beginRefreshing()
    }
    
    //View LifeCycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //Set CollectionView
        setCollectionView()
        setScrollView()
        setMjRefresh()
        loadGoregeous(GorgeousCategory: 0)
        self.navigationItem.title = "所有"
        
    }
    
    //MARK:CollectionView delegate
    //CollectionView delegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let array = self.gorgeousUrlsArray {
            return array.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! GorgeousCollectionViewCell
        cell.gorgeousUrl = gorgeousUrlsArray![indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.bounds.size.width - 30)/2, height: (view.bounds.size.height - 30)/3)
    }
    //设置放大图
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! GorgeousCollectionViewCell
        
            var images = [SKPhoto]()
            for gorgeous in self.gorgeousUrlsArray! {
                let photo = SKPhoto.photoWithImageURL(gorgeous.src!)
                photo.caption = gorgeous.title
                images.append(photo)
            }
            
            let originImage = cell.imageView.image
            
            let browser = SKPhotoBrowser(originImage: originImage!, photos: images, animatedFromView: cell)
            browser.initializePageIndex(indexPath.row)
            SKPhotoBrowserOptions.displayAction = false
            DispatchQueue.main.async {
                self.present(browser, animated: true, completion: nil)
            }
    }
    
    //设置EdgeInsetsMake
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10.0, 10.0, 0, 10.0)
    }
    
    // MARK: Load Goregeous Data
    //Load Home Page
    func loadGoregeous(GorgeousCategory: Int) {
        
        Alamofire.request(String("http://www.dbmeinv.com/dbgroup/show.htm?cid=\(GorgeousCategory)&pager_offset=1")).responseString { (response) in
            
            if response.result.isSuccess{
                
                let jiDoc = Ji(htmlString: response.result.value!)
                //解析出li每个图的xPath
                let liElementArray = jiDoc?.xPath("//*[@id=\"main\"]/div[2]/div[2]/ul/li")
                for liElement in liElementArray! {
                    let elementDoc = Ji(htmlString: liElement.rawContent!)
                    let imgElement = elementDoc?.xPath("//div/div[1]/a/img")?.first
                    //用attributes解析其中的链接//转模型！！
                    let gorgeousUrl = GoregeousUrl.mj_object(withKeyValues: imgElement?.attributes)
                    self.gorgeousUrlsArray?.append(gorgeousUrl!)
                }
                self.page = 1
                self.collectionView?.reloadData()
                
                self.collectionView?.mj_header.endRefreshing()
            }else {
                HUD.flash(.error, delay: 1.5)
                
                self.collectionView?.mj_header.endRefreshing()
            }
        }
        
    }
    
    //Load Next Page
    func loadNextPage(GorgeousCategory:Int) {
        Alamofire.request(String("http://www.dbmeinv.com/dbgroup/show.htm?cid=\(GorgeousCategory)&pager_offset=\(self.page+1)")).responseString { (response) in
            
            if response.result.isSuccess{
                let jiDoc = Ji(htmlString: response.result.value!)
                //解析出li每个图的xPath
                let liElementArray = jiDoc?.xPath("//*[@id=\"main\"]/div[2]/div[2]/ul/li")
                for liElement in liElementArray! {
                    let elementDoc = Ji(htmlString: liElement.rawContent!)
                    let imgElement = elementDoc?.xPath("//div/div[1]/a/img")?.first
                    //用attributes解析其中的链接//转模型！！
                    let gorgeousUrl = GoregeousUrl.mj_object(withKeyValues: imgElement?.attributes)
                    self.gorgeousUrlsArray?.append(gorgeousUrl!)
                }
                self.page += 1
                self.collectionView?.reloadData()
                self.collectionView?.mj_footer.endRefreshing()
            }else {
                HUD.flash(.error, delay: 2)
                self.collectionView?.mj_footer.endRefreshing()
            }
        }
    }
}
