//
//  ViewController.swift
//  004_QuickCheck
//
//  Created by 强新宇 on 2016/12/30.
//  Copyright © 2016年 强新宇. All rights reserved.
//

import UIKit


func pluslsCommutative(x: Int, y: Int) -> Bool {
    return x + y == y + x
}


protocol Arbirary: Smaller {
    static func arbirary() -> Self
}

protocol Smaller {
    func smaller() -> Self?
}


extension Int: Arbirary, Smaller {
    static func arbirary() -> Int {
        return Int(arc4random())
    }
    static func random(form: Int, to: Int) -> Int {
        return form + (Int(arc4random()) % (to - form))
    }
    
    
    func smaller() -> Int? {
        return self == 0 ? nil : self / 2
    }
}

extension CGFloat: Arbirary {
    func smaller() -> CGFloat? {
        return self == 0.0 ? nil : self / 2.0
    }
    static func arbirary() -> CGFloat {
        return CGFloat(arc4random())/10000000 * (Int.random(form: 0, to: 2) == 0 ? -1 : 1)
    }
}

extension Character: Arbirary {
    static func arbirary() -> Character {
        return Character(UnicodeScalar(Int.random(form: 65, to: 90))!)
    }
    
    func smaller() -> Character? {
        return self
    }
}

func tabulate<T>(times: Int, transform: (Int) -> T) -> [T] {
    return (0..<times).map(transform)
}

extension String: Arbirary, Smaller {
    static func arbirary() -> String {
        let randomLength = Int.random(form: 0, to: 40)
        let randomCharacters = tabulate(times: randomLength) { _ in
            Character.arbirary()
        }
        return String(randomCharacters)
    }
    
    func smaller() -> String? {
        return isEmpty ? nil : String(characters.dropFirst())
    }
}

extension CGSize {
    var area: CGFloat {
        return width * height
    }
}

extension CGSize: Arbirary {
    static func arbirary() -> CGSize {
        return CGSize(width: CGFloat.arbirary(), height: CGFloat.arbirary())
    }
    func smaller() -> CGSize? {
        return CGSize(width: width / 2, height: height / 2)
    }
}



func check1<T: Arbirary>(message: String, property: (T) -> Bool) -> () {
    let number = 100
    for _ in 0..<number {
        let value = T.arbirary()
        print("value => \(value)")
        guard property(value) else {
            print("\"\(message)\"doesn't hold: \(value)")
            return
        }
    }
    print("\"\(message)\"passed  \(number) tests")
}


func iteraterWhile<T>(condition: (T) -> Bool, initail: T, next: (T) -> T?) -> T {
    if let x = next(initail) , condition(x) {
        return iteraterWhile(condition: condition, initail: x, next: next)
    }
    return initail
}


func check2<T: Arbirary>(message: String, property: (T) -> Bool) -> () {
    let number = 100
    for _ in 0..<number {
        let value = T.arbirary()
        print("value => \(value)")
        guard property(value) else {
            let smallerValue = iteraterWhile(condition: {!property($0)}, initail: value, next: {$0.smaller()})
            print("\"\(message)\"doesn't hold: \(smallerValue)")
            return
        }
    }
    print("\"\(message)\"passed  \(number) tests")

}


func qsort(array: [Int]) -> [Int] {
    
    var array = array
    
    if array.isEmpty {
        return []
    }
    
    let pivot = array.remove(at: 0)
    let lesser = array.filter{$0 < pivot}
    let greater = array.filter{$0 >= pivot}
    return qsort(array: lesser) + [pivot] as [Int] + qsort(array: greater)
    
}

extension Array : Arbirary {
    static func arbirary() -> [Element] {
        var array = [Element]()
        for _ in 0...10 {
            array.append(Int.arbirary() as! Element)
        }
        return array
        
    }
    
    
    
    func smaller() -> [Element]? {
        guard !isEmpty else {
            return nil
        }
        return Array(dropFirst())
    }
}



struct ArbitraryInstance<T> {
    let arbitrary: () -> T
    let smaller: (T) -> T?
}

func checkHelper<T>(arbitraryInstance: ArbitraryInstance<T>, property:(T) -> Bool, message: String) -> () {
    let number = 100
    for _ in 0..<number {
        let value = arbitraryInstance.arbitrary()
        print("value => \(value)")
        guard property(value) else {
            let smallerValue = iteraterWhile(condition: {!property($0)}, initail: value, next: arbitraryInstance.smaller)
            print("\"\(message)\"doesn't hold: \(smallerValue)")
            return
        }
    }
    print("\"\(message)\"passed  \(number) tests")
}


//func check<T: Arbirary>(message: String, property: (T) -> Bool) -> () {
//    let instance = ArbitraryInstance(arbitrary: T.arbirary, smaller: {$0.smaller()})
//    checkHelper(arbitraryInstance: instance, property: property, message: message)
//}
func check<X: Arbirary>(message: String, property: ([X]) -> Bool) -> () {
    let instance = ArbitraryInstance(arbitrary: Array.arbirary, smaller: { (x: [X]) in x.smaller() })

    checkHelper(arbitraryInstance: instance, property: property, message: message)

}



class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        check2(message: "Area should be at least 0") { (size: CGSize) in size.area >= 0 }
        
        
        check(message: "qsort should behave like sort") {(x: [Int]) in
            qsort(array: x) == x.sorted(by: <)
        }
        
    }
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

