//
//  ViewController.swift
//  009_GeneratorAndSequence
//
//  Created by 强新宇 on 2017/1/16.
//  Copyright © 2017年 强新宇. All rights reserved.
//

import UIKit

protocol GeneratorType {
    associatedtype Element
    func next() -> Element?
}

class CountdownGenerator: GeneratorType {
    typealias Element = Int

    var element: Int
    init<T>(array: [T]) {
        self.element = array.count
    }
    
    
    func next() -> CountdownGenerator.Element? {
        element -= 1
        return element < 0 ? nil : element
    }
}

//x => 1842755090244893238399196572748178169520000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000


class PowerGenerator: GeneratorType {
    typealias Element = NSDecimalNumber
    
    var power: NSDecimalNumber = 1
    let two: NSDecimalNumber = 2
    
    func next() -> NSDecimalNumber? {
        power = power.multiplying(by: two)
        
        
        switch power.compare(NSDecimalNumber.maximum) {
        case .orderedAscending:
            return power
        case .orderedSame:
            return power
        case .orderedDescending:
            return nil
        }
    }
    
    
    func findPower(predicate: (NSDecimalNumber) -> Bool) -> NSDecimalNumber {
        while let x = next() {
            if predicate(x) {
                return x
            }
        }
        return 0
    }
    
    
}

class FilelLinesGenerator: GeneratorType {
    typealias Element = String
    
    var lines: [String] = []
    init(filename: String) throws {
        let content: String = try String(contentsOfFile: filename)
        let newLine = NSCharacterSet.newlines
        lines = content.components(separatedBy: newLine)
    }
    
    func next() -> String? {
        guard !lines.isEmpty else {
            return nil
        }
        let nextLine = lines.removeFirst()
        return nextLine
    }
}


extension GeneratorType {
    mutating func find(predicate: (Element) -> Bool) -> Element? {
        while let x = next() {
            if predicate(x) {
                return x
            }
        }
        return nil
    }
}


class LimitGenerator<G: GeneratorType>: GeneratorType {
    
    var limit = 0
    var generator: G
    
    init(limit: Int, generator: G) {
        self.limit = limit
        self.generator = generator
    }
    
    func next() -> G.Element? {
        guard limit >= 0 else {
            return nil
        }
        limit -= 1
        return generator.next()
    }
}



class AnyGenerator<Element>: GeneratorType  {
    
    var n: () -> Element?
    
    init(n: @escaping () -> Element?) {
        self.n = n
    }
    
    func next() -> Element? {
        return n()
    }
    
}


extension Int {
    func countDown() -> AnyGenerator<Int> {
        var i = self
        return AnyGenerator(n: { () -> Int? in
            if i < 0 {
                return nil
            }
            i -= 1
            return i
        })
    }
}

func +<G: GeneratorType, H: GeneratorType>( first: G, second: H) -> AnyGenerator<G.Element> where G.Element == H.Element {
    return AnyGenerator{ first.next() ?? second.next()}
}


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let arr = [1,2,3,45,6,7,8]
        
        let gen = CountdownGenerator(array: arr)
        
        for _ in 1...10 {
            print(gen.next() ?? "no value ")
        }
        
        print("\n\n\n")
        
        
        let gen1 = CountdownGenerator(array: arr)

        while let i = gen1.next() {
            print("i => \(i)")
        }
//
//        
//        print("\n\n\n\n")
//
//        let power = PowerGenerator()
//        
//        power.findPower {$0.intValue > 1000}
//        
//        while let x = power.next() {
//            print("x => \(x)")
//        }
        
        
        print("\n\n\n\n")

        let gen2 = CountdownGenerator(array: arr)

        let limit = LimitGenerator(limit: 3, generator: gen2)
        
        
        while let x = limit.next() {
            print("x => \(x)")
        }
        
        
        print("\n\n\n\n")

        
        let gen3 = CountdownGenerator(array: arr)
        let gen4 = CountdownGenerator(array: arr)

        let gen5 = gen3 + gen4
        
        while let x = gen5.next() {
            print("gen5 ==> x => \(x)")
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

