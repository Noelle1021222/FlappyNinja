//
//  RandomFunction.swift
//  FlappyNinja
//
//  Created by 許雅筑 on 2016/9/26.
//  Copyright © 2016年 hsu.ya.chu. All rights reserved.
//

import Foundation
import CoreGraphics
//使牆隨機生成高度 因為是32位元

public extension CGFloat{
    public static func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    public static func random(min min:CGFloat,max:CGFloat) -> CGFloat{
        return CGFloat.random() * (max - min) + min
    }
}
