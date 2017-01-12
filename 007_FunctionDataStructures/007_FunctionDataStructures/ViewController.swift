//
//  ViewController.swift
//  007_FunctionDataStructures
//
//  Created by 强新宇 on 2017/1/6.
//  Copyright © 2017年 强新宇. All rights reserved.
//

import UIKit


indirect enum BinarySearchTree<Element: Comparable> {
    case Leaf
    case Node(BinarySearchTree<Element>,Element,BinarySearchTree<Element>)
}


extension BinarySearchTree {
    init() {
        self = .Leaf
    }
    
    init(value: Element) {
        self = .Node(.Leaf, value, .Leaf)
    }
}

extension BinarySearchTree {
    var count: Int {
        switch self {
        case .Leaf:
            return 0
        case let .Node(leaf, _, right):
            return 1 + leaf.count + right.count
        }
    }
    
    var elements: [Element] {
        switch self {
        case .Leaf:
            return []
        case let .Node(leaf, x, right):
            return leaf.elements + [x] + right.elements
        }
    }
    
    var isEmpty: Bool {
        if case .Leaf = self {
            return true
        }
        return false
    }
    
    
    func contains(x: Element) -> Bool {
        switch self {
        case .Leaf:
            return false
        case let .Node(_, y, _) where x == y:
            return true
        case let .Node(_, y , right) where x > y:
            return right.contains(x: x)
        case let .Node(left, y, _) where x < y:
            return left.contains(x: x)
        default:
            fatalError("The impossible occurred")
        }
    }
    
    mutating func insert(x: Element) {
        switch self {
        case .Leaf:
            self = BinarySearchTree(value: x)
        case .Node(var left, let y, var right):
            if x < y {
                left.insert(x: x)
            }
            if x > y {
                right.insert(x: x)
            }
            self = .Node(left,y,right)
        }
    }
    
    mutating func delete(x: Element) {
        switch self {
        case .Leaf:
            print("value is nil")
        case .Node(var left, let y, var right):
            if x > y {
                right.delete(x: x)
                self = .Node(left,y,right)
            }
            
            if x < y {
                left.delete(x: x)
                self = .Node(left,y,right)
            }
            
            
            if x == y {
                switch right {
                case .Leaf:
                    if case .Leaf = left {
                        self = BinarySearchTree()
                    } else {
                        self = left
                    }
                
                case .Node(var right_left, let right_y, let right_right):
                    if case .Leaf = left {
                        self = right
                    } else {
                        aaa(left: left, x: &right_left, y: right_y, right: right_right)
                        self = right_left
                    }
                }
            }
        }
    }
    
    func aaa(left:BinarySearchTree<Element>, x: inout BinarySearchTree<Element>, y: Element, right: BinarySearchTree<Element>) {
        switch x {
        case .Leaf:
            x = .Node(left, y, right)
        case .Node(var right_left_left,let right_left_y,let right_left_right):
            aaa(left: left, x: &right_left_left, y: right_left_y, right: right_left_right)
            x = .Node(right_left_left, y, right)
        }
    }
}


class ViewController: UIViewController {
    
    func logData(x: BinarySearchTree<Int>)  {
        switch x {
        case .Leaf:
            print("no value \n")
        case let .Node(left, y , right):
            print("left => \(left),\n y => \(y),\n right => \(right)\n")
            logData(x: left)
            logData(x: right)
            print("\n\n\n\n")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        let leaf: BinarySearchTree<Int> = .Leaf
//        let five: BinarySearchTree<Int> = .Node(leaf,5,leaf)
//
//        var arr = BinarySearchTree<Int>()
//        
//        let list = [100,50,120,30,80,10,40,60,90,55,52]
//        
//        for x in list {
//            arr.insert(x: x)
//            print("insert => \(x) \n arr => \(arr)\n\n")
//        }
//        
//        for x in list {
//            arr.delete(x: x)
//            print("delete => \(x) \n arr => \(arr)\n\n")
//        }
//        
//        
        
        
        
        
        
//        let trie = Trie(key: ["qiangxinyu","enhe","wanghaobin"])
//        let trie1 = trie.insert(key: ["q","e"])
//        print(trie)
//        print(trie1)
//        
//        print(trie1.elements)
//        
//        print(trie1.withPrefix(prefix: ["q"]) ?? "aa")
        
        let contents = ["cat", "car", "cart", "dog"]
        let trieOfWords = buildStringTrie(words: contents)
        let newArr = autocompleteString(knowWords: trieOfWords, word: "car")
        
        print(trieOfWords)
        print("\n")
        print(newArr)
    }
    
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

  
}



struct Trie<Element: Hashable> {
    let isELement: Bool
    let children: [Element : Trie<Element>]
}



extension Trie {
    init() {
        isELement = false
        children = [:]
    }
    
    init(key: [Element]) {
        if let (head, tail) = key.decompose {
            let children = [head: Trie(key: tail)]
            self = Trie(isELement: false, children: children)
        } else {
            self = Trie(isELement: true, children: [:])
        }
    }
    
    var elements: [[Element]] {
        var result: [[Element]] = isELement ? [[]] : []
        for (key, value) in children {
            result += value.elements.map{ [key] + $0}
        }
        return result
    }
}


extension Array {
    var decompose: (Element, [Element])? {
        return isEmpty ? nil : (self.first!, Array(self.dropFirst()))
    }
}

func sum(xs: [Int]) -> Int {
    guard let (head, tail) = xs.decompose else {
        return 0
    }
    return head + sum(xs: tail)
}


extension Trie {
    func lookup(key: [Element]) -> Bool {
        guard let (head, tail) = key.decompose else {
            return isELement
        }
        guard let subtrie = children[head] else {
            return false
        }
        return subtrie.lookup(key: tail)
    }
    
    
    func withPrefix(prefix: [Element]) -> Trie<Element>? {
        guard let (head, tail) = prefix.decompose else {
            return self
        }
        guard let remainder = children[head] else {
            return nil
        }
        return remainder.withPrefix(prefix: tail)
    }
    
    func autocomplete(key: [Element]) -> [[Element]] {
        return withPrefix(prefix: key)?.elements ?? []
    }
}



extension Trie {
    func insert(key: [Element]) -> Trie<Element> {
        guard let (head, tail) = key.decompose else {
            return Trie(isELement: true, children: children)
        }
        
        var newChildren = children
        if let nextTrie = children[head] {
            newChildren[head] = nextTrie.insert(key: tail)
        } else {
            newChildren[head] = Trie(key: tail)
        }
        return Trie(isELement: isELement, children: newChildren)
    }
}


func buildStringTrie(words: [String]) -> Trie<Character> {
    let emptyTrie = Trie<Character>()
    return words.reduce(emptyTrie, { (trie, word) in
        trie.insert(key: Array(word.characters))
    })
}

func autocompleteString(knowWords: Trie<Character>, word: String) -> [String] {
    let chars = Array(word.characters)
    let completed = knowWords.autocomplete(key: chars)
    return completed.map({ (chars) in
        word + String(chars)
    })
}
