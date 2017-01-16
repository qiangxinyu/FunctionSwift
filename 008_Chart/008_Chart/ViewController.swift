//
//  ViewController.swift
//  008_Chart
//
//  Created by 强新宇 on 2017/1/12.
//  Copyright © 2017年 强新宇. All rights reserved.
//

import UIKit
import CoreGraphics




//extension Sequence.Type where Generator.Element == CGFloat {
//    func normailze() -> [CGFloat] {
//        let maxVal = self.reduce(0) { max($0,$1)}
//        return self.map { $0 / maxVal }
//    }
//}
//
//func barGraph(input: [(String, Double)]) -> Diagram {
//    let values: [CGFloat] = input.map { CGFloat($0.1) }
//    let nValues = values.normalize()
//    let bars = hcat(nValues.map { (x: CGFloat) -> Diagram in
//        return rect(width: 1, height: 3 * x) .  ll (. blackColor()).alignBottom() })
//    let labels = hcat(input.map { x in
//        return text(x.0, width: 1, height: 0.3).alignTop() })
//    return bars --- labels }
//
//
//let cities = [ ("Shanghai", 14.01), ("Istanbul", 13.3), ("Moscow", 10.56), ("New York", 8.33), ("Berlin", 3.43)
//]
//let example3 = barGraph(cities)



indirect enum Prim {
    case Ellipse
    case Rectangle
    case Text(String)
    case Prim(CGSize, Prim)
    case Beside(Diagram, Diagram)
    case Below(Diagram, Diagram)
    case Attributed(Attribute, Diagram)
    case Align(CGVector, Diagram)
}


indirect enum Diagram {
    case Prim(CGSize, Prim)
    case Beside(Diagram, Diagram)
    case Below(Diagram, Diagram)
    case Attributed(Attribute, Diagram)
    case Align(CGVector, Diagram)
}

enum Attribute {
    case FillColor(UIColor)
}


extension Diagram {
    var size: CGSize {
        switch self {
        case .Prim(let size, _):
            return size
        case .Attributed(_, let x):
            return x.size
        case .Beside(let l, let r):
            let sizeL = l.size
            let sizeR = r.size
            return CGSize(width: sizeL.width + sizeR.width, height: max(sizeR.height, sizeL.height))
        case .Below(let l, let r):
            return CGSize(width: max(l.size.width, r.size.width), height: l.size.height + r.size.height)
        case .Align(_, let r):
            return r.size
        }
    }
}


extension CGSize {
    func fit(vector: CGVector, rect: CGRect) -> CGRect {
        let scaleSize = rect.size / self
        let scale = min(scaleSize.width, scaleSize.height)
        let size = scale * self
        let space = vector.size * (size - rect.size)
        return CGRect(origin: rect.origin - space.point, size: size)
    }
}


func *(l: CGFloat,r: CGSize)->CGSize{
    return CGSize(width: l * r.width, height: l * r.height)
}
func /( l : CGSize, r: CGSize) -> CGSize {
    return CGSize(width:l.width/r.width,height: l.height / r.height) }
func *(l: CGSize,r: CGSize)->CGSize{
    return CGSize(width: l.width * r.width, height: l.height * r.height)
}
func -( l : CGSize, r: CGSize) -> CGSize {
    return CGSize(width:l.width-r.width,height: l.height-r.height) }
func -( l : CGPoint, r: CGPoint) -> CGPoint { return CGPoint(x: l.x - r.x, y: l.y - r.y)
}
extension CGSize {
    var point: CGPoint {
        return CGPoint(x: self.width, y: self.height) }
}
extension CGVector {
    var point: CGPoint { return CGPoint(x: dx, y: dy) }
    var size: CGSize { return CGSize(width: dx, height: dy) }
}


extension CGContext {
    func draw(bounds: CGRect, diagram: Diagram) {
        switch diagram {
        case .Prim(let size, .Ellipse):
            let frame = size.fit(vector: CGVector(dx: 0.5, dy: 0.5), rect: bounds)
            self.fillEllipse(in: frame)
            
        case .Prim(let size, .Rectangle):
            let frame = size.fit(vector: CGVector(dx: 0.5, dy: 0.5), rect: bounds)
            self.fillEllipse(in: frame)
            
        case .Prim(let size, .Text(let text )):
            let frame = size.fit(vector: CGVector(dx: 0.5, dy: 0.5), rect: bounds)
            let font = UIFont.systemFont(ofSize: 12)
            let attributes = [NSFontAttributeName: font]
            let attributedText = NSAttributedString(string: text, attributes: attributes)
            attributedText.draw(in: frame)
            
        case .Attributed(.FillColor(let color), let d):
            self.saveGState()
            color.set()
            draw(bounds: bounds, diagram: d)
            self.restoreGState()
            
        case .Beside(let left, let right):
            let (lFrame, rFrame) = bounds.split(
                ratio: left .size.width/diagram.size.width, edge: .minXEdge)
            draw(bounds: lFrame, diagram: left)
            draw(bounds: rFrame, diagram: right)

        case .Below(let top, let bottom):
            let (lFrame, rFrame) = bounds.split(
                ratio: bottom.size.height/diagram.size.height, edge: .minYEdge)
            draw(bounds: lFrame, diagram: bottom)
            draw(bounds: rFrame, diagram: top)

        case .Align(let vec, let diagram):
            let frame = diagram.size.fit(vector: vec, rect: bounds)
            draw(bounds: frame, diagram: diagram)

        default: print("")
        
        }
    }
}

extension CGRect {
    func split(ratio: CGFloat,edge:CGRectEdge)->(CGRect,CGRect){
    let length = edge.isHorizontal ? width : height
    return divided(atDistance: length * ratio , from: edge) }
}
extension CGRectEdge { var isHorizontal: Bool {
    return self == .maxXEdge || self == .minXEdge; }
}

class Draw: UIView {
    let diagram: Diagram
    
    init(frame: CGRect, diagram: Diagram) {
        self.diagram = diagram
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        context.draw(bounds: self.bounds, diagram: diagram)
    }
    
    func data() -> Data {
        return Data()
    }
}


extension Diagram {
    func pdf(width: CGFloat) -> Data {
        let height = width * (size.height / size.width)
        let v = Draw(frame: CGRect(x: 0, y: 0, width: width, height: height), diagram: self)
        return v.data()
    }
}
func rect(width: CGFloat, height: CGFloat) -> Diagram {
    return .Prim(CGSize(width: width, height: height), .Rectangle)
}
func circle( diameter: CGFloat) -> Diagram {
    return .Prim(CGSize(width: diameter, height: diameter), .Ellipse)
}
func text(theText: String, width: CGFloat, height: CGFloat) -> Diagram {
    return .Prim(CGSize(width: width, height: height), .Text(theText))
}
func square(side: CGFloat) -> Diagram {
    return rect(width: side, height: side)
}


infix operator |||
func ||| ( l : Diagram, r: Diagram) -> Diagram {
    return Diagram.Beside(l, r)
}

infix operator ---
func --- (l: Diagram,r:Diagram)->Diagram{
    return Diagram.Below(l, r)
}


extension Diagram {
    func fill (color: UIColor) -> Diagram {
        return .Attributed(.FillColor(color), self) }
    func alignTop() -> Diagram {
        return .Align(CGVector(dx: 0.5, dy: 1), self)
    }
    func alignBottom() -> Diagram {
        return .Align(CGVector(dx: 0.5, dy: 0), self)
    }
}

let empty: Diagram = rect(width: 0, height: 0)
func hcat(diagrams: [Diagram]) -> Diagram {
    return diagrams.reduce(empty, |||)
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        Diagram.Align(CGVector(dx: 0.5, dy: 1), blueSquare) ||| redSquare
        
        
        
        let blueSquare = square(side:1).fill(color: .blue)
        let redSquare = square(side:2).fill(color: .red)
        let greenCircle = circle(diameter: 1).fill (color: .green)
        
        _ = (blueSquare ||| redSquare) ||| greenCircle
        
        
        
        
        
        let myView = MyView(frame: view.frame)
        view.addSubview(myView)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}

class MyView: UIView {
    override func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
//            UIColor.blue.setFill()
//            context.fill(CGRect(x: 0, y: 37, width: 75, height: 75))
//            
//            UIColor.red.setFill()
//            context.fill(CGRect(x: 75, y: 0, width:150, height: 150))
//            
//            UIColor.green.setFill()
//            context.fillEllipse(in: CGRect(x: 225, y: 37, width: 75, height: 75))
            let blueSquare = square(side:1).fill(color: .blue)
            let redSquare = square(side:2).fill(color: .red)
            let greenCircle = circle(diameter: 1).fill (color: .green)
            
            let x = (blueSquare ||| redSquare) ||| greenCircle
            
            context.draw(bounds: self.bounds, diagram: x)
            
        }
    }
}

