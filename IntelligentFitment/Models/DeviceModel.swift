import UIKit

class DeviceModel: NSObject,NSCoding{
    var sno:String = ""
    var name:String = ""
    var date:String = ""
    
    init(sno:String,name:String,date:String) {
        super.init()
        
        self.sno = sno
        self.name = name
        self.date = date
    }
    
    //归档时自动调用
    func encodeWithCoder(aCoder: NSCoder){
        aCoder.encodeObject(self.sno, forKey: "sno")
        aCoder.encodeObject(self.name, forKey: "name")
        aCoder.encodeObject(self.date, forKey: "date")
    }
    
    //解档时自动调用
    required init(coder aDecoder: NSCoder) {
        super.init()
        
        self.sno = aDecoder.decodeObjectForKey("sno") as! String
        self.name = aDecoder.decodeObjectForKey("name") as! String
        self.date = aDecoder.decodeObjectForKey("date") as! String
    }
    
    class func save(model:DeviceModel,filePath:String) -> Bool{
        return NSKeyedArchiver.archiveRootObject(model, toFile: filePath)
    }
    
    class func get(filePath:String)-> DeviceModel{
        return NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as! DeviceModel
    }
}
