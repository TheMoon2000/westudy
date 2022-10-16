//
//  LoginViewController.swift
//  Room
//
//  Created by Jia Rui Shan on 2022/10/15.
//

import Cocoa
import CoreGraphics

class LoginViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }
    
    private func setupUI() {
        view.wantsLayer = true
        view.layer!.backgroundColor = Colors.theme.cgColor
        
//        Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: self.testDataGathering)
//        RunLoop.main.run()
//        KeyPressManager().addListener { scancode in
//            print(scancode)
//        }
        
    }
    
    private func testDataGathering(timer: Timer) {
        print(getMouseLocation())
    }
    
    override func viewDidAppear() {
        view.window!.isMovableByWindowBackground = true
    }

}

