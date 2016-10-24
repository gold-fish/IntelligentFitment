//  ViewController.swift
//  2016-10-20

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate{
    @IBOutlet weak var imgQRCode: UIImageView!
    
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
    
    func createQRCode(content:String) -> UIImage{
        //创建滤镜对象
        let filter = CIFilter(name: "CIQRCodeGenerator")
        //恢复默认设置
        filter?.setDefaults()
        
        //设置二维码数据
        filter?.setValue(content.dataUsingEncoding(NSUTF8StringEncoding), forKey: "inputMessage")
        //设置二维码纠错级别(L:7% M:15% Q:25% H:30% 默认值是M)
        filter?.setValue("H", forKey: "inputCorrectionLevel")
        //输出图像(转换成UIImage类型即可使用，只是此时图像不清晰)
        let ciImage = filter?.outputImage
        
        //再创建一个CIFalseColor滤镜，用来伪造颜色，使二维码图像更清晰，它只有三个固定的属性inputImage，inputColor0，inputColor1
        let colorFilter = CIFilter(name: "CIFalseColor")!
        colorFilter.setValue(ciImage, forKey: "inputImage")
        
        //输入颜色             
        colorFilter.setValue(CIColor(red:0,green:0,blue:0),forKey:"inputColor0")
        colorFilter.setValue(CIColor(red:1,green:1,blue:1),forKey:"inputColor1")
        
        return UIImage(CIImage: colorFilter.outputImage!.imageByApplyingTransform(CGAffineTransformMakeScale(5,5)))
    }
    
    @IBAction func createQRCodeTapped(sender: AnyObject) {
        imgQRCode.image = createQRCode("软件部门的二维码")
    }
    
    @IBAction func QRCodeTapped(sender: AnyObject) {
        //设置捕捉设备
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        do{
            //创建输入流
            let captureInput = try AVCaptureDeviceInput(device: captureDevice)
            //创建输出流
            let captureOutput = AVCaptureMetadataOutput()
            captureOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            
            //设置会话
            captrueSession = AVCaptureSession()
            
            if ((captrueSession?.canAddInput(captureInput)) != nil){
                captrueSession?.addInput(captureInput)
            }
            
            if ((captrueSession?.canAddOutput(captureOutput)) != nil){
                captrueSession?.addOutput(captureOutput)
            }
            
            //设置扫描类型(二维码)
            captureOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            
            //设置采集视频区域
            let layer = AVCaptureVideoPreviewLayer.init(session: captrueSession)
            layer.videoGravity = AVLayerVideoGravityResizeAspectFill
            
            let width = UIScreen.mainScreen().bounds.size.width - 120
            
            layer.frame = CGRectMake(60, 200, width, 250)
            self.view.layer.addSublayer(layer)
            
            //设置提示文字
            let showLabel = UILabel(frame: CGRectMake(75,460,260,30))
            showLabel.text = "将二维码放入框内，即可自动扫描"
            self.view.addSubview(showLabel)
        }
        catch{
            let alertController = UIAlertController(title: "温馨提示：", message: "摄像头不可用，请在设置中开启此应用对相机的访问权限！", preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "确定", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
        //开始扫描
        captrueSession?.startRunning()
    }
    
    //处理扫描结果
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!){
        if metadataObjects != nil && metadataObjects.count > 0{
            let myMetadataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            
            if myMetadataObject.type == AVMetadataObjectTypeQRCode{
                if let value = myMetadataObject.stringValue{
                    captrueSession?.stopRunning()
                
                    //添加震动
                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                
                    let alertController = UIAlertController(title: "二维码值：", message: value, preferredStyle: .Alert)
                    
                    let cancelAction = UIAlertAction(title: "确定", style: .Cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
