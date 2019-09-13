//
//  CommonUtils.swift
//  Human Translator
//
//  Created by Yin on 09/02/2018.
//  Copyright © 2018 Yin. All rights reserved.
//

import Foundation

class CommonUtils {
    
    static func isValidEmail(_ email: String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    static func getCallStatusAudioFileName(_ status: Int) -> String {
        var result = ""
        
        if status == R.Const.IS_CALLING {
            result = "videocall.mp3"
        }
        
        else if status == R.Const.IS_RECEIVING {
            result = "ring.mp3"
        }
        
        return result
    }
    
    class func getRandomRoomNumber() -> Int {
        
        return Int(arc4random_uniform(999999999)) + 1000000000
    }
}

var currentUser : UserModel? {
    didSet {
        if let user = currentUser {
            UserDefaults.standard.set(user.email, forKey: R.String.KEY_EMAIL)
            UserDefaults.standard.set(user.password, forKey: R.String.KEY_PASSWORD)
        }
    }
}

func resizeImage(srcImage: UIImage) -> UIImage {
    
    if (srcImage.size.width >= srcImage.size.height) {
        
        return srcImage.resizedImage(byMagick: "256")
    } else {
        
        return srcImage.resizedImage(byMagick: "x256")
    }
}



// save image to a file (Documents/SmarterApp/temp.png)
func saveToFile(image: UIImage!, filePath: String!, fileName: String) -> String! {
    
    let outputFileName = fileName
    
    let outputImage = resizeImage(srcImage: image)
    
    let fileManager = FileManager.default
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    var documentDirectory: NSString! = paths[0] as NSString!
    
    // current document directory
    fileManager.changeCurrentDirectoryPath(documentDirectory as String)
    
    do {
        try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
    } catch let error as NSError {
        print(error.localizedDescription)
    }
    
    documentDirectory = documentDirectory.appendingPathComponent(filePath) as NSString!
    let savedFilePath = documentDirectory.appendingPathComponent(outputFileName)
    
    // if the file exists already, delete and write, else if create filePath
    if (fileManager.fileExists(atPath: savedFilePath)) {
        do {
            try fileManager.removeItem(atPath: savedFilePath)
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    } else {
        fileManager.createFile(atPath: savedFilePath, contents: nil, attributes: nil)
    }
    
    if let data = UIImagePNGRepresentation(outputImage) {
        
        do {
            try data.write(to:URL(fileURLWithPath:savedFilePath), options:.atomic)
        } catch {
            print(error)
        }
    }
    return savedFilePath
}
