//
//  LoginViewController.swift
//  Room
//
//  Created by Jia Rui Shan on 2022/10/15.
//

import Cocoa
import CoreGraphics
import SwiftyJSON

class LoginViewController: NSViewController {
    
    @IBOutlet weak var username: NSTextField!
    @IBOutlet weak var password: NSSecureTextField!

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
    
    @IBAction func login(sender: NSButton) {
        var urlRequest = URLRequest(url: URL.with(API_Name: "/accounts/login")!)
        let login = LoginCredentials(username: username.stringValue, password_hash: password.stringValue.sha1())
        urlRequest.httpBody = try! JSONEncoder().encode(login)
        urlRequest.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: urlRequest) {
            data, response, error in
            
            guard error == nil, let data = data else {
                print(error)
                return
            }
            
            let json = JSON(parseJSON: String(data: data, encoding: .utf8)!)
            if json["successful"].boolValue {
                LocalStorage.current.token = json["token"].string!
                DispatchQueue.main.async {
                    let mainWindow = self.storyboard!.instantiateController(withIdentifier: "main") as! MainWindowController
                    mainWindow.showWindow(mainWindow)
                }
            } else {
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.messageText = "Username or password is incorrect."
                    alert.informativeText = "Please try again."
                    alert.beginSheetModal(for: self.view.window!) { (_) in
                        self.password.stringValue = ""
                    }
                }
            }
        }
        
        task.resume()
    }

}

