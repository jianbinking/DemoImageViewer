//
//  ViewController.swift
//  Test_ImageViewer
//
//  Created by Doby on 2020/4/30.
//  Copyright © 2020 Doby. All rights reserved.
//

import UIKit
import SDWebImage

class ViewController: UIViewController {
    
    let imgStrs: [String] = [
        "https://img.buydeem.cn/adv_img/202005/1588753145483794829.jpg",
        "https://img.buydeem.cn//goods/202003/1585107262247201538.jpeg",
        "https://img.buydeem.cn//goods/202003/1585107263381300230.jpeg",
        "https://img.buydeem.cn//goods/202003/1585107262812752498.jpeg",
        "https://img.buydeem.cn//goods/201911/1574129820650017464.jpeg"
    ]
    
    lazy var imgInfos: [ImageInfo] = self.imgStrs.map {
        let info = ImageInfo()
        info.strImg = $0
        return info
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        var xoff = 50;
        var yoff = 100;
        
        for (idx, obj) in self.imgStrs.enumerated() {
            let btn1 = UIButton.init(type: .custom)
            btn1.frame = .init(x: xoff, y: yoff, width: 100, height: 100)
            btn1.tag = idx;
            btn1.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside);
            self.view.addSubview(btn1)
            
            let img1 = UIImageView.init(frame: btn1.frame);
            img1.sd_setImage(with: URL.init(string: self.convertImgUrl(imgStr: obj, width: 100, height: 100)), completed: {
                img, err, type, url in
                if let img = img {
                    self.imgInfos[idx].placeholder = img
                }
            })
            img1.tag = 100 + btn1.tag
            img1.contentMode = .scaleAspectFill;
            img1.clipsToBounds = true
            self.view.addSubview(img1);
            
            xoff += 150
            if xoff > Int(self.view.bounds.width - 100) {
                xoff = 50
                yoff += 150
            }
        }
    }
    
    //响应动画的image按钮
    weak var targetImg: UIImageView?
    @objc func buttonTapped(_ btn: UIButton) {
        self.targetImg = self.view.viewWithTag(100 + btn.tag) as? UIImageView
        let vc = LargeImagePageViewController.init(images: self.imgInfos, idx: btn.tag)
        self.present(vc, animated: true, completion: nil)
    }
    
    
    func convertImgUrl(imgStr: String, width: Int, height: Int) -> String {
        return String.init(format: "%@?x-oss-process=image/resize,m_mfit,w_%d,h_%d", imgStr, width, height)
    }

}

extension ViewController: TestTransitionDelegate {
    
    func targetView() -> UIView? {
        return self.targetImg
    }
    
    func targetImage() -> UIImage? {
        return self.targetImg?.image
    }
    
}

