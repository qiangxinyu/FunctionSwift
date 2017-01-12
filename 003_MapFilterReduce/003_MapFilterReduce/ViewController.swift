//
//  ViewController.swift
//  003_MapFilterReduce
//
//  Created by 强新宇 on 2016/12/29.
//  Copyright © 2016年 强新宇. All rights reserved.
//

import UIKit


extension Array {
    func qmap<T>(_ transform: (Element) -> T) -> [T]{
        var newArr = [T]()
        for num in self {
            newArr.append(transform(num))
        }
        return newArr
    }
    
    public func qFilter(_ transform: (Element) throws -> Bool) rethrows -> [Element] {
        var newArr = [Element]()
        for x in self where try! transform(x) {
            newArr.append(x)
        }
        return newArr
    }
    
    func qReduce<T>(inital: T, combine: (T, Element) -> T) -> T {
        var result = inital
        for x in self {
            result = combine(result,x)
        }
        return result
    }
}






class ViewController: UIViewController {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let arr: [Any] = [1,2,3,4,"a"]
        
        
        let transform = { (a: Any) -> Any in
            if let x = a as? Int {
                return x * x
            }
            return a
        }
        
        let newArr = arr.qmap(transform)
        print(newArr)
        
        let newArr1 = arr.map(transform)
        print(newArr1)
        
        
        ////////////////////////////////////////////////////////////////////////
        
        let newArr2 = arr.filter {$0 is Int}
        print(newArr2)
        
        
        let newArr3 = arr.qFilter { (a) -> Bool in
            a is Int
        }
        print(newArr3)
        
        
        ////////////////////////////////////////////////////////////////////////
        
        let num = 10
        let combin = { (x: Any, y: Any) -> Any in
            if let a = x as? Int, let b = y as? Int {
                return a + b
            }
            return x
        }
        
        let newArr4 = arr.reduce(num, combin)
        print(newArr4)
        
        
        let newArr5 = arr.qReduce(inital: num, combine: combin)
        
        print( newArr5)
        
        
        
        
        
        let newArr11 = cities.qmap { (city) -> City in
            city.CityByScalingPopulation()
            }.qFilter { (city) -> Bool in
                city.population > 1000000
            }.qReduce(inital: "") { (x, city) -> String in
                x + city.name + ": \(city.population)\n"
        }
        
        
        let newArr12 = cities.qReduce(inital: [String: Any]()) { ( x, city) -> [String: Any] in
            var a = x
            a.updateValue(city.population, forKey: city.name)
            return a
        }
        
        
        let abc = cities.qReduce(inital: []) { (x, city) -> [Any] in
            var a = x
            a.append(city)
            return a
        }
        
        let ab = cities.reduce([]) { (x, city) in
            return x + [city]
        }
        
        print("abc => \(abc)")
        
        print("\n")
        print("ab => \(ab)")
        
        print(newArr11)
        print(newArr12)
        
        
        
        let dic = ["a":2]
        
        
        //“Swift 标准库中的定义通过使用 Swift 的 autoclosure 类型标签来避开创建显式闭包的需求。它会在所需要的闭包中隐式地将参数封装到 ?? 运算符。”
        
        let dic_a =  dic["a"] ?? 3  //3 是默认值
        print(dic_a)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}




struct City {
    let name: String
    let population: Int
}


let paris = City(name: "Paris", population: 2241)
let madrid = City(name: "Madrid", population: 3165)
let amsterdam = City(name: "Amsterdam", population: 827)
let berlin = City(name: "Berlin", population: 3562)
let cities = [paris, madrid, amsterdam, berlin]

extension City {
    func CityByScalingPopulation() -> City {
        return City(name: name, population: 1000 * population)
    }
}



