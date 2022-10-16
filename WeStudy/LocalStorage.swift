//
//  LocalStorage.swift
//  WeStudy
//
//  Created by Jia Rui Shan on 2022/10/16.
//

import Cocoa
import SwiftyJSON

let SAVE_PATH = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("storage")

class LocalStorage: Codable {
    static var current = LocalStorage()
    
    var token: String? { didSet { Self.save() }}
    var username: String? { didSet { Self.save() }}
    var affiliation: String? { didSet { Self.save() }}
    
    static func load() {
        do {
            let saveData = try Data.init(contentsOf: SAVE_PATH)
            self.current = try JSONDecoder().decode(LocalStorage.self, from: saveData)
        } catch (let err) {
            print(err)
        }
    }
    
    static func save() {
        try! JSONEncoder().encode(self.current).write(to: SAVE_PATH)
    }
}
