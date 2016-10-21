//  ViewController.swift
//  2016-10-20

import UIKit
import AVFoundation

class ViewController: UIViewController , AVCaptureMetadataOutputObjectsDelegate{
    var archivePath = ""
    var captrueSession:AVCaptureSession?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let docPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        archivePath = docPath.stringByAppendingPathComponent("device.archive")
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
    
    @IBAction func QRCodeTapped(sender: AnyObject) {
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        //创建输入流
        let captureInput = try? AVCaptureDeviceInput(device: captureDevice)
        
        captrueSession = AVCaptureSession()
        
        if let captureInput = captureInput{
            captrueSession?.addInput(captureInput)
        }
        
        //创建输出流
        let captureOutput = AVCaptureMetadataOutput()
        
        if ((captrueSession?.canAddOutput(captureOutput)) != nil){
            captrueSession?.addOutput(captureOutput)
            
            captureOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            captureOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        }
        
        //设置采集视频区域
        let layer = AVCaptureVideoPreviewLayer.init(session: captrueSession)
        layer.videoGravity = AVLayerVideoGravityResizeAspectFill
        layer.frame = CGRectMake(100, 200, 300, 300)
        self.view.layer.addSublayer(layer)
        
        //开始采集视频数据
        captrueSession?.startRunning()
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!){
        if metadataObjects == nil || metadataObjects.count == 0{
            let alertController = UIAlertController(title: "二维码值为：", message: "暂未捕获到", preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "确定", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        else{
            let myMetadataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            
            if myMetadataObject.type == AVMetadataObjectTypeQRCode{
                if let value = myMetadataObject.stringValue{
                    let alertController = UIAlertController(title: "二维码值为：", message: value, preferredStyle: .Alert)
                    
                    let cancelAction = UIAlertAction(title: "确定", style: .Cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                    captrueSession?.stopRunning()
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
