//
//  PieChartView.swift
//  GEUK_T1
//
//  Created by Mary Forde on 29/11/2016.
//  Copyright © 2016 Mary Forde. All rights reserved.
//

import UIKit

struct Segment {
    var color : UIColor
    var value : CGFloat
}

class PieChartView: UIView {
    
    var segments = [Segment]() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {

        let context = UIGraphicsGetCurrentContext()

        let valueTotal = segments.reduce(0) {$0 + $1.value}
        let radius = min(frame.size.width, frame.size.height) / 2
        let viewCenter = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
        
        var startAngle = -CGFloat(Double.pi/2)
        
        for segment in segments {
            context?.setFillColor(segment.color.cgColor)
            
            let endAngle = startAngle + CGFloat(Double.pi*2) * (segment.value/valueTotal)
            
            context?.move(to: CGPoint(x: viewCenter.x, y: viewCenter.y))
            context?.addArc(center: CGPoint(x: viewCenter.x, y: viewCenter.y), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            context?.fillPath()

            startAngle = endAngle
        }
    }
}
