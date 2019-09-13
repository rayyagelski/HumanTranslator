//
//  SelectLanguageViewController.swift
//  Human Translator
//
//  Created by Yin on 11/02/2018.
//  Copyright © 2018 Yin. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

class SelectLanguageViewController: UIViewController {
    
    @IBOutlet weak var tfMylanguage: UITextField!
    @IBOutlet weak var tfTransLanguage: UITextField!
    
    var selectedTF = UITextField()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tfMylanguage.text = languageArr[0].name
        tfTransLanguage.text = languageArr[0].name
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    

    @IBAction func onPicker(_ sender: Any) {
        
        var pickerArr = [String]()
        let btn = sender as! UIButton
        switch btn.tag {
        case 0:
            for name in languageArr {
                pickerArr.append(name.name/* + "," + name.nativeName*/)
            }
            selectedTF = tfMylanguage
            
        default:
            selectedTF = tfTransLanguage
            for name in languageArr {
                pickerArr.append(name.name/* + "," + name.nativeName*/)
            }
        }
        
        ActionSheetStringPicker.show(withTitle: R.String.SEL_LANGUAGE, rows: pickerArr, initialSelection: 0, doneBlock: {
            picker, value, index in
            
            print("value = \(value)")
            print("index = \(String(describing: index))")
            print("picker = \(String(describing: picker))")
            self.selectedTF.text = "\(index!)"
            
            return
        }, cancel: { ActionStringCancelBlock in return }, origin: sender)
    }
        
    @IBAction func onSearch(_ sender: Any) {
        
        let searchTransVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchTranslatorViewController") as! SearchTranslatorViewController
        searchTransVC.my_language = tfMylanguage.text!
        searchTransVC.trans_language = tfTransLanguage.text!
        self.navigationController?.pushViewController(searchTransVC, animated: true)
        
    }
}
