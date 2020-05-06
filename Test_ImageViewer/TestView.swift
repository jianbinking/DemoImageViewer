//
//  TestView.swift
//  Test_ImageViewer
//
//  Created by Doby on 2020/5/6.
//  Copyright © 2020 Doby. All rights reserved.
//

import UIKit

class TestView: UIView {

    let text: String
    lazy var lbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.textAlignment = .center
        self.addSubview(lbl)
        return lbl
    }()
    
    init(text: String, frame: CGRect) {
        self.text = text
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        print("\(text) before pointinside \(String.init(format: "x:%.2f,y:%.2f", point.x, point.y))")
        let sup = super.point(inside: point, with: event)
        print("\(text) after pointinside  sup: \(sup)")
        return sup
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        print("\(text) before hittest \(String.init(format: "x:%.2f,y:%.2f", point.x, point.y))")
        let sup = super.hitTest(point, with: event)
        var desc = "nil"
        if let v = sup as? TestView {
            desc = v.text
        }
        else if let v = sup {
            desc = "\(type(of: v))"
        }
        print("\(text) after hittest  super:\(desc)")
        
        return self 
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("\(text) before touches began count:\(touches.count)")
        super.touchesBegan(touches, with: event)
        print("\(text) after touches began")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1
        self.lbl.text = self.text
        self.lbl.frame = self.bounds
    }
    
}
