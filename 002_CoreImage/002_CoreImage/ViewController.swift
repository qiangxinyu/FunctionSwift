//
//  ViewController.swift
//  002_CoreImage
//
//  Created by 强新宇 on 2016/12/29.
//  Copyright © 2016年 强新宇. All rights reserved.
//

import UIKit

typealias Filter = (CIImage) -> CIImage

func blur(radius: Double) -> Filter {
    return { image in
        let parameters: [String : Any] = [
            kCIInputRadiusKey: radius,
            kCIInputImageKey:  image
        ]
        
        guard let filter = CIFilter(name: "CIGaussianBlur", withInputParameters: parameters) else {
            fatalError()
        }
        
        guard let outputImage = filter.outputImage else {
            fatalError()
        }
        
        return outputImage
    }
}


func colorGenerator(color: UIColor) -> Filter {
    return { _ in
        let c = CIColor(color: color)
        let parameters = [kCIInputColorKey: c]
        guard let filter = CIFilter(name: "CIConstantColorGenerator",
                                    withInputParameters: parameters) else { fatalError() }
        guard let outputImage = filter.outputImage else { fatalError() }
        return outputImage
    }
}

func compositeSourceOver(overlay: CIImage) -> Filter {
    return { image in
        let parameters = [
            kCIInputBackgroundImageKey: image,
            kCIInputImageKey:   overlay
        ]
        
        guard let filter = CIFilter(name: "CISourceOverCompositing", withInputParameters: parameters) else {
            fatalError()
        }
        guard let outputImage = filter.outputImage else {
            fatalError()
        }
        let cropRect = image.extent
        return outputImage.cropping(to: cropRect)
    }
}


func colorOverlay(color: UIColor) -> Filter {
    return { image in
        let overlay = colorGenerator(color: color)
        return compositeSourceOver(overlay: overlay(image))(image)
    }
}


precedencegroup ComparativePrecedence {
    associativity: left
    higherThan: LogicalConjunctionPrecedence
}
infix operator + : ComparativePrecedence

func +(filter1: @escaping Filter, filter2:@escaping Filter) -> Filter {
    return { image in
        filter2(filter1(image))
    }
}


class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func clickBlurBtn(_ sender: Any) {
        let filterBlur = blur(radius: 10)
        settingImageWithFilter(filter: filterBlur)
    }
    
    @IBAction func clickColorBtn(_ sender: Any) {
        let filterBlur = colorOverlay(color: UIColor(red: 0, green: 0, blue: 1, alpha: 0.5))
        settingImageWithFilter(filter: filterBlur)
    }
    
    @IBAction func clickOverlayBtn(_ sender: Any) {
        let filter = blur(radius: 10) + colorOverlay(color: UIColor.red.withAlphaComponent(0.2))
        settingImageWithFilter(filter: filter)
    }
    
    func settingImageWithFilter(filter: @escaping Filter) {
        
        print("click Btn \(Thread.current)")
        weak var weakSelf = self
        DispatchQueue.global().async{
            if var path =  Bundle.main.path(forResource: "IMG_5505.JPG", ofType: "") {
                path = "file://" + path
                if let url = URL(string: path) {
                    if let ciImage = CIImage(contentsOf: url) {
                        print("begain bulr\(Thread.current)")
                        let outputCiImage = filter(ciImage)
                        let outputImage = UIImage(ciImage: outputCiImage)
                        print("finsh output\(Thread.current)")
                        
                        DispatchQueue.main.async{
                            weakSelf!.imageView.image = outputImage
                            print("setting image\(Thread.current) outputImage--- \(outputImage)")
                            
                            //public func +(time: DispatchTime, seconds: Double) -> DispatchTime
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5){
                                weakSelf!.imageView.image = nil
                                print("setting nil\(Thread.current)")
                            }
                        }
                    }
                }
            }
        }
        print("end action \(Thread.current)")

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

