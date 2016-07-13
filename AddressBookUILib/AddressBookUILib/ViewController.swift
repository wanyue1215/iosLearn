//
//  ViewController.swift
//  AddressBookUILib
//
//  Created by 宛越 on 16/7/5.
//  Copyright © 2016年 yuewan. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    }
    

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @IBAction func touched(sender: AnyObject) {
        
        //createAContact()
        
        contactPicker();
        
    }
    
    func contactPicker(){
        let contactPicker = CNContactPickerViewController()
        presentViewController(contactPicker, animated: true, completion: nil)
        
        contactPicker.delegate = self;
    }
    
    
    func createAContact(){
        
        let con = CNMutableContact()
        con.givenName = "yue"
        con.familyName = "wan"
        
        let homeEmail = CNLabeledValue(label: CNLabelHome, value: "378128655@qq.com")
        let workEmail = CNLabeledValue(label: CNLabelWork, value: "wanyue@k12cloud.cn")
        con.emailAddresses = [homeEmail,workEmail];
        
        con.phoneNumbers = [
            CNLabeledValue(label: CNLabelPhoneNumberMobile, value: CNPhoneNumber(stringValue: "18225902132"))
        ]
        
        let homeAddress = CNMutablePostalAddress()
        homeAddress.city = "wuxi"
        homeAddress.street = "jinxilu100"
        homeAddress.street = "jiangsu"
        homeAddress.postalCode = "214000"
        con.postalAddresses = [
            CNLabeledValue(label: CNLabelHome, value: homeAddress)
        ]
        
        let birthday = NSDateComponents()
        birthday.day = 5;
        birthday.month = 7;
        birthday.year = 1993;
        con.birthday = birthday;
        
        let store = CNContactStore()
        let saveRequest = CNSaveRequest()
        saveRequest.addContact(con, toContainerWithIdentifier: nil)
        
        //        do {
        //            try store.executeSaveRequest(saveRequest)
        //        } catch let error as NSError {
        //            print(error.userInfo)
        //        }
        
        try! store.executeSaveRequest(saveRequest)
        
        let contact = CNContactViewController(forNewContact: con)
        
        presentViewController(contact, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


extension ViewController: CNContactPickerDelegate
{
    func contactPicker(picker: CNContactPickerViewController, didSelectContact contact: CNContact) {
        print(contact.givenName);
    }
    
    func contactPicker(picker: CNContactPickerViewController, didSelectContacts contacts: [CNContact]) {
        print(contacts.first!.givenName);
    }
}
