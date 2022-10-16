//
//  Utils.swift
//  WeStudy
//
//  Created by Jia Rui Shan on 2022/10/15.
//

import Cocoa

func getMouseLocation() -> (Int, Int) {
    return (Int(round(NSEvent.mouseLocation.x)), Int(round(NSEvent.mouseLocation.y)))
}
