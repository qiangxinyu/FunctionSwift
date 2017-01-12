//
//  ViewController.swift
//  005_LetAndVar
//
//  Created by 强新宇 on 2017/1/5.
//  Copyright © 2017年 强新宇. All rights reserved.
//

import UIKit


struct PointStruct {
    var x: Int
    var y: Int
}

class PointClass: NSObject {
    var x: Int
    var y: Int
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    override var description: String {
        return "PointClass : x => \(x), y => \(y)"
    }
    
    
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let structPoint = PointStruct(x: 5, y: 5)
        var sameStructPoint = structPoint
        sameStructPoint.x = 3
        
        print("structPoint => \(structPoint) , sameStructPoint => \(sameStructPoint)")
        
        
        
        var classPoinst = PointClass(x: 5, y: 5)
        var sameClassPoinst = classPoinst
        sameClassPoinst.x = 2
        
        print("classPoinst => \(classPoinst) , sameClassPoinst => \(sameClassPoinst)")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

