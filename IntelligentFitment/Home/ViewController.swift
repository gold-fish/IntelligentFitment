//  ViewController.swift
//  2016-10-20

import UIKit

class ViewController: UIViewController {
    var archivePath = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let docPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        archivePath = docPath.stringByAppendingPathComponent("device.archive")
        
        print(archivePath)
    }

    @IBAction func archiveTapped(sender: AnyObject) {
        let model = DeviceModel(sno: "shuoren_001", name: "macbook",date:"2016-10-20")
        
        DeviceModel.save(model, filePath: archivePath)
    }
    
    @IBAction func unarchiveTapped(sender: AnyObject) {
        let model = DeviceModel.get(archivePath)
        
        print(model.sno)
        print(model.name)
        print(model.date)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
