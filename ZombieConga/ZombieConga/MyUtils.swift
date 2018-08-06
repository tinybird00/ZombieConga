//
//  MyUtils.swift
//  ZombieConga
//
//  Created by mark on 2018/7/3.
//  Copyright © 2018年 3dragons. All rights reserved.
//

import Foundation
import CoreGraphics
import AVFoundation

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint( x: left.x + right.x, y: left.y + right.y) }

func += ( left: inout CGPoint, right: CGPoint) {
    left = left + right
}
func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint( x: left.x - right.x, y: left.y - right.y)
    
}
func -= ( left: inout CGPoint, right: CGPoint) {
    left = left - right
}

func * (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint( x: left.x * right.x, y: left.y * right.y)
    
}
func *= ( left: inout CGPoint, right: CGPoint) {
    left = left * right
    
}
func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint( x: point.x * scalar, y: point.y * scalar)
    
}
func *= ( point: inout CGPoint, scalar: CGFloat) {
    point = point * scalar
    
}
func / (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint( x: left.x / right.x, y: left.y / right.y)
}
func /= ( left: inout CGPoint, right: CGPoint) {
    left = left / right
}
func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint( x: point.x / scalar, y: point.y / scalar)
    
}
func /= ( point: inout CGPoint, scalar: CGFloat) {
    point = point / scalar

}

let π = CGFloat(Double.pi)
//两个角度之间最小的夹角
func shortestAngleBetween( angle1: CGFloat, angle2: CGFloat) -> CGFloat {
    let twoπ = π * 2.0
    var angle = (angle2 - angle1).truncatingRemainder(dividingBy: twoπ)
    if (angle >= π) {
        angle = angle - twoπ
    }
    if (angle <= -π) {
        angle = angle + twoπ
    }
    return angle
}

extension CGFloat {
    //数字符号
    func sign() -> CGFloat {
        return (self >= 0.0) ? 1.0 : -1.0
    }
    //随机数
    static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UInt32.max))
    }
    //最大最小之间的随机数
    static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        assert( min < max)
        return CGFloat.random() * (max - min) + min
    }
    
}

//MARK:音乐

var backgroundMusicPlayer:AVAudioPlayer?

func playBackgroundMusic(fileName:String) {
    let resouceUrl = Bundle.main.url(forResource: fileName, withExtension: nil)
    guard let url = resouceUrl else {
        print("Could not find file:\(fileName)")
        return
    }
    do {
        try backgroundMusicPlayer = AVAudioPlayer.init(contentsOf: url)
        backgroundMusicPlayer?.numberOfLoops = -1
        backgroundMusicPlayer?.prepareToPlay()
        backgroundMusicPlayer?.play()
    } catch {
        print("Could not create audio player")
        return
    }
}

func stopPlayBackgroundMusic() {
    backgroundMusicPlayer?.stop()
}



