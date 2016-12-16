//
//  GorgeousCollectionViewCell.swift
//  DBGorgeous-Swift
//
//  Created by 海啸 on 2016/12/11.
//  Copyright © 2016年 海啸. All rights reserved.
//

import UIKit
import Alamofire
import Ji
import SDWebImage
import SnapKit


class GorgeousCollectionViewCell: UICollectionViewCell {

    //ImageView
    let imageView : UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    //Set ImageView
    func setImageView() {
        self.addSubview(self.imageView)
        self.imageView.snp.makeConstraints { (make) in
            make.width.height.left.top.equalToSuperview()
        }
        
    }
    //variable
    var gorgeousUrl: GoregeousUrl? {
        didSet{
            let url = URL(string: gorgeousUrl!.src!)
            
            self.imageView.sd_setImage(with: url, placeholderImage: nil)
        }
    }
    //init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.gray
        setImageView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
