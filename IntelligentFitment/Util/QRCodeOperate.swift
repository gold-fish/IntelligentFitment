import UIKit
import AVFoundation

class QRCodeOperate: NSObject , AVCaptureMetadataOutputObjectsDelegate{
    var captrueSession:AVCaptureSession?
    
    init(myView:UIView,myViewController:UIViewController) {
        super.init()
    
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
            myView.layer.addSublayer(layer)
            
            //设置提示文字
            let showLabel = UILabel(frame: CGRectMake(75,460,260,30))
            showLabel.text = "将二维码放入框内，即可自动扫描"
            myView.addSubview(showLabel)
        }
        catch{
            let alertController = UIAlertController(title: "温馨提示：", message: "摄像头不可用，请在设置中开启此应用对相机的访问权限！", preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "确定", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            myViewController.presentViewController(alertController, animated: true, completion: nil)
        }
        
        //开始扫描
        captrueSession?.startRunning()
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!){
        if metadataObjects != nil && metadataObjects.count > 0{
            let myMetadataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            
            if myMetadataObject.type == AVMetadataObjectTypeQRCode{
                if let value = myMetadataObject.stringValue{
                    captrueSession?.stopRunning()
                    
                    //添加震动
                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                    //发送通知
                    NSNotificationCenter.defaultCenter().postNotificationName("scan", object: nil, userInfo: ["codeValue":value])
                }
            }
        }
    }
}
