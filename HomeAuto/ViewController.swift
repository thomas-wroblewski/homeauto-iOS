//
//  ViewController.swift
//  helloworld
//
//  Created by Tom Wroblewski on 12/7/16.
//  Copyright © 2016 Tom Wroblewski. All rights reserved.
//

import UIKit
import SwiftyJSON

class ViewController: UIViewController {

    

    @IBOutlet weak var status: UIActivityIndicatorView!
    
    @IBOutlet weak var label1: UILabel!

    @IBOutlet weak var label2: UILabel!
    
    @IBOutlet weak var label3: UILabel!
    
    @IBOutlet weak var label4: UILabel!
    
    @IBOutlet weak var label5: UILabel!
    
    @IBOutlet weak var switch1: UISwitch!
    
    @IBOutlet weak var switch2: UISwitch!
    
    @IBOutlet weak var switch3: UISwitch!
    
    @IBOutlet weak var switch4: UISwitch!
    
    @IBOutlet weak var switch5: UISwitch!
    
    @IBOutlet weak var allOff: UIButton!
    
    @IBOutlet weak var allOn: UIButton!
    
    
    var outletList = [String: Outlet]()
    
    override func viewDidLoad() {
                // Do any additional setup after loading the view, typically from a nib.
        
        self.status.startAnimating()
        retrieveOutlets()
        
        _ = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(ViewController.retrieveOutlets), userInfo: nil, repeats: true)
        
        super.viewDidLoad()
        
        
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func toggleSwitch(_ sender: UISwitch) {
           
        
        if(sender.tag == 1){
            flipOutlet(name: label1.text!)
        }else if(sender.tag == 2){
            flipOutlet(name: label2.text!)
        }else if(sender.tag == 3){
            flipOutlet(name: label3.text!)
        }else if(sender.tag == 4){
            flipOutlet(name: label4.text!)
        }else if(sender.tag == 5){
            flipOutlet(name: label5.text!)
        }
        
        
        
        
    }
    
    func retrieveOutlets(){
        var request = URLRequest(url: URL(string: "http://192.168.0.10:8081/homeauto/rfoutlet")!)
        print("Update...")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")  // the request is JSON
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")        // the expected response is
        
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 { // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            //let responseString = String(data: data, encoding: .utf8)
            //print("responseString = \(responseString)")
            
            let json = JSON(data: data)
            var counter:Int = 0;
            //print(json)
            for (_,json):(String, JSON) in json {
                //Do something you want
                //print(json)
                for (_,subJson):(String, JSON) in json {
                    //Do something you want
                    //print(subJson)
                    counter += 1
                    let id = subJson["id"].string
                    let onCode = subJson["on"].int32
                    let offCode = subJson["off"].int32
                    let name = subJson["name"].string
                    let running = subJson["running"].bool
                    let pulse = subJson["pulse"].int16
                    self.outletList[id!] = Outlet(id: id!, onCode: onCode!, offCode: offCode!, pulse: pulse!, name: name!, running: running!)
                    if(running == true){
                        //self.view.tag
                        if(counter == 1){
                            self.label1.text = name!
                            self.switch1.setOn(true, animated: true)
                        }else if(counter == 2){
                            self.label2.text = name!
                            self.switch2.setOn(true, animated: true)
                        }else if(counter == 3){
                            self.label3.text = name!
                            self.switch3.setOn(true, animated: true)
                        }else if(counter == 4){
                            self.label4.text = name!
                            self.switch4.setOn(true, animated: true)
                        }else if(counter == 5){
                            self.label5.text = name!
                            self.switch5.setOn(true, animated: true)
                        }
                    }else{
                        if(counter == 1){
                            self.label1.text = name!
                            self.switch1.setOn(false, animated: true)
                        }else if(counter == 2){
                            self.label2.text = name!
                            self.switch2.setOn(false, animated: true)
                        }else if(counter == 3){
                            self.label3.text = name!
                            self.switch3.setOn(false, animated: true)
                        }else if(counter == 4){
                            self.label4.text = name!
                            self.switch4.setOn(false, animated: true)
                        }else if(counter == 5){
                            self.label5.text = name!
                            self.switch5.setOn(false, animated: true)
                        }
                    }   
                }
            }
            self.status.stopAnimating()
        }
        task.resume()
        
        //self.status.stopAnimating()
    }
    
    
    func flipOutlet(name:String){
        var request = URLRequest(url: URL(string: "http://192.168.0.10:8081/homeauto/rfoutlet")!)
        
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")  // the request is JSON
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")        // the expected response is
        
        request.httpMethod = "POST"
        var postString = ""
        //let postString = "{ 'id': '5798388d87f2f7a7e3f47e7d', 'code': 4218115, 'pulse': 188}"
        var outlet:Outlet?
        for(_, value) in outletList{
            if(value.name == name){
                outlet = value
            }
        }
        
        if outlet?.running == true{
            //let o = outletList[id]!
            let id:String = outlet!.id
            let code:int_least32_t! = outlet?.offCode
            let pulse:int_fast16_t! = outlet?.pulse
            
            postString = "{ 'id': '\(id)', 'code': \(code!) , 'pulse': \(pulse!) }"
        }else{
            let id:String = outlet!.id
            let code:int_least32_t! = outlet?.onCode
            let pulse:int_fast16_t! = outlet?.pulse
            
            postString = "{ 'id': '\(id)', 'code': \(code!) , 'pulse': \(pulse!) }"
        }
        
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
                            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
            
            if outlet!.running == true{
                print("flip to false")
                outlet!.running = false;
            }else{
                print("flip to true")
                outlet!.running = true;
            }
            
        }
        task.resume()

        
    }
    
    @IBAction func flipAll(_ sender: UIButton) {
        
        if(sender.tag == 0){
            
        }else if(sender.tag == 1){
            
        }
        
        
    }
    
    
    
}

class Outlet{
    let id: String
    let onCode: int_least32_t
    let offCode: int_least32_t
    let pulse: int_fast16_t
    let name: String
    var running: Bool
    
    init(id:String, onCode:int_least32_t, offCode:int_least32_t, pulse:int_fast16_t, name:String, running:Bool){
        self.id = id
        self.onCode = onCode
        self.offCode = offCode
        self.pulse = pulse
        self.name = name
        self.running = running
    }
}

