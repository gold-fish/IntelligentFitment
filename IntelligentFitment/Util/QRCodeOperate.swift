import UIKit
import AVFoundation

class QRCodeOperate: NSObject , AVCaptureMetadataOutputObjectsDelegate{
    var captrueSession:AVCaptureSession?
    var codeValue:String?
    var captureFlag:Bool = false
    
    init(myView:UIView) {
        super.init()
        
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
        layer.frame = CGRectMake(100, 200, 200, 200)
        myView.layer.addSublayer(layer)
        
        //开始采集视频数据
        captrueSession?.startRunning()
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!){
        if metadataObjects == nil || metadataObjects.count == 0{
            print("未捕获到二维码！")
        }
        else{
            let myMetadataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            
            if myMetadataObject.type == AVMetadataObjectTypeQRCode{
                if let value = myMetadataObject.stringValue{
                    codeValue = value
                    captureFlag = true
                    
                    captrueSession?.stopRunning()
                }
            }
        }
    }
}
