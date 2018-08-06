//
//  CGPoint+Utils.swift
//  ZombieConga
//
//  Created by mark on 2018/7/3.
//  Copyright © 2018年 3dragons. All rights reserved.
//

import Foundation
import CoreGraphics

#if !(arch( x86_64) || arch( arm64))
func atan2( y: CGFloat, x: CGFloat) -> CGFloat {
    return CGFloat( atan2f( Float( y), Float( x))) }
func sqrt( a: CGFloat) -> CGFloat {
    return CGFloat( sqrtf( Float( a))) }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt( x*x + y*y)
        
    }
    func normalized() -> CGPoint {
        return self / length()
        
    }
    var angle: CGFloat {
        return atan2(y, x)
    }
}


