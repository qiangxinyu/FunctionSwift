//
//  ViewController.swift
//  001_Battleshid
//
//  Created by 强新宇 on 2016/12/28.
//  Copyright © 2016年 强新宇. All rights reserved.
//

import UIKit


typealias Distance = Double

struct Position {
    var x: Double
    var y: Double
}


//判断是否在范围内
typealias Region = (Position) -> Bool

func circle(radius: Distance) -> Region {
    return { point in
        point.length <= radius
    }
}



//func clcle2(radius: Distance, center: Position) -> Region {
//    return { point in
//        point.minus(p: center).length <= radius
//    }
//}

//“一个圆心为 (5, 5) 半径为 10 的圆”
//shift(region: cicle(radius: 10), offset: Position(x: 5, y: 5))


//偏移 圆心
func shift(region: @escaping Region, offset: Position) -> Region {
    return { point in
        region(point.minus(p: offset))
    }
}

//反转
func invert(region: @escaping Region) -> Region {
    return { point in
        !region(point)
    }
}

//交集
func intersection(region1:  @escaping Region, _ region2:@escaping Region) -> Region {
    return { point in
        region1(point) && region2(point)
    }
}

//并集
func union(region1:  @escaping Region, _ region2:@escaping Region) -> Region {
    return { point in
        region1(point) || region2(point)
    }
}

//在 region 不在 minus 中的
func difference(region: @escaping Region, minus: @escaping Region) -> Region {
    return intersection(region1: region, invert(region: minus))
}

extension Position {
    func inRange(range: Distance) -> Bool {
        return sqrt(x * x + y * y) <= range
    }
    
    func minus(p: Position) -> Position {
        return Position(x: x - p.x, y: y - p.y)
    }
    
    var length: Double {
        return sqrt(x * x + y * y)
    }
}


struct Ship {
    var position: Position
    var firingRange: Distance
    var unsafeRange: Distance
}

extension Ship {
    
    func canEngageShip(target: Ship, friendly: Ship) -> Bool {
        
        let rangeRegion = difference(region: circle(radius: firingRange), minus: circle(radius: unsafeRange))
        
        let firingRegion = shift(region: rangeRegion, offset: position)
        let friendlyRegion = shift(region: circle(radius: unsafeRange), offset: friendly.position)
        
        let resultRegion = difference(region: firingRegion, minus: friendlyRegion)
        return resultRegion(target.position)
        
    }
}




class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let region0: Region = {point in false}
        print(region0(Position(x: 5, y: 5)))
        
        
        let region = circle(radius: 10)
        print(region(Position(x: 10, y: 0)))
        
        
        let region1 = shift(region: circle(radius: 10), offset: Position(x: 5, y: 5))
        print(region1(Position(x: 10, y: 10)))

        
         
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

