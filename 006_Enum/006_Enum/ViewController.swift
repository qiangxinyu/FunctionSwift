//
//  ViewController.swift
//  006_Enum
//
//  Created by 强新宇 on 2017/1/5.
//  Copyright © 2017年 强新宇. All rights reserved.
//


import UIKit


enum Encoding {
    case ASCII
    case NEXTSTEP
    case JapaneseEUC
    case UTF8
}


private var xoAssociationKey: UInt8 = 0

extension UIButton {
    var t: (UIButton) -> () {
        get {
            return (objc_getAssociatedObject(self, &xoAssociationKey) as? (UIButton) -> ())!
        }
        set(newValue) {
            objc_setAssociatedObject(self, &xoAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    convenience init(frame: CGRect, target:@escaping (UIButton) -> ()) {
        self.init()
        self.frame = frame
        t = target
        addTarget(self, action: #selector(a), for: .touchUpInside)
    }
    
    func a(btn: UIButton) -> () {
        t(btn)
    }
}

extension Encoding {
    var nsStringEncoding: String.Encoding {
        switch self {
            case .ASCII:        return .ascii
            case .NEXTSTEP:     return .nextstep
            case .JapaneseEUC:  return .japaneseEUC
            case .UTF8:         return .utf8
        }
    }
    
    init?(enc: String.Encoding) {
        switch enc {
            case String.Encoding.ascii:         self = .ASCII
            case String.Encoding.nextstep:      self = .NEXTSTEP
            case String.Encoding.japaneseEUC:   self = .JapaneseEUC
            case String.Encoding.utf8:          self = .UTF8
            default: return nil
        }
    }
}
func localizedEncodingName(encoding: Encoding) -> String {
    return .localizedName(of: encoding.nsStringEncoding)
}




enum LookuoError: Error {
    case CapitalNotFound
    case PopulationNotFound
}

enum Result<T> {
    case Success(T)
    case Error(LookuoError)
}

struct City {
    let name: String
    let population: Int?
}


let paris = City(name: "Paris", population: 2241)
let madrid = City(name: "Madrid", population: 3165)
let amsterdam = City(name: "Amsterdam", population: 827)
let berlin = City(name: "Berlin", population: 3562)
let cities = [paris, madrid, amsterdam, berlin]


let capitals = [
    "France": paris,
    "Spain": madrid,
    "The Netherlands": amsterdam,
    "Belgium": berlin
]

func populationOfCapital(county: String) -> Result<Int> {
    guard let capital = capitals[county] else {
        return .Error(.CapitalNotFound)
    }
    
    guard let population = capital.population , population > 0 else {
        return .Error(.PopulationNotFound)
    }
    return .Success(population)
}

let mayors = [
    "Paris": "Hidalgo",
    "Madrid": "Carmena", "Amsterdam": "van der Laan", "Berlin": "Müller"
]

func mayorOfCapital(country: String) -> Result<String> {
    guard let mayor = mayors[country] else {
        return .Error(.CapitalNotFound)
    }
    return .Success(mayor)
}





enum Add<T, U> {
    case InLeft(T)
    case InRight(U)
}

enum Zero {
    
}






class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
        switch populationOfCapital(county: "Spain1") {
        case let .Success(p) :
            print("spain population => \(p)")
        case let .Error(error) :
            print("spain error => \(error)")
        }
        
        
        
        let btn = UIButton(frame: CGRect(x: 1.0, y: 1.0, width: 100.0, height: 100.0)) { (btn) in
            btn.frame = CGRect(x: 11.0, y: 11.0, width: 100.0, height: 100.0)
            print("click Btn")
        }
        btn.setTitle("aaaa", for: .normal)
        btn.backgroundColor = UIColor.purple
        view.addSubview(btn)
        
        
        print(btn)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

