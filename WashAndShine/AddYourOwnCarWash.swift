//
//  AddYourOwnCarWash.swift
//  WashAndShine
//
//  Created by Sharifah Nazreen Ashraff ali on 28/01/2016.
//  Copyright © 2016 Syed Mohamed Ariff. All rights reserved.
//

import UIKit
import Parse
import CoreLocation
class AddYourOwnCarWash : UIViewController,UITextFieldDelegate
{
    var servicedownpicker : DownPicker!
    var ratingdownpicker : DownPicker!
    var carGeoPoint = PFGeoPoint()
    let cashDelegate = CashTextFieldDelegate()
    var coordinates:CLLocationCoordinate2D!
    @IBOutlet weak var cartextfield: UITextField!
    @IBOutlet weak var ratingtextfield: UITextField!
    @IBOutlet weak var servicestextfield: UITextField!
    @IBOutlet weak var pricingtextfield: UITextField!
    @IBOutlet weak var addresstextfield: UITextField!
    @IBOutlet weak var nametextfield: UITextField!
    let pickerData = ["Foaming","Polishing","Engine Wash"]
     var applicationDelegate: AppDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
          let services: NSMutableArray = ["Regular wash","Wash and Vacuum", "AMC(Advanced Micro Chemical","Meguiars Wax Wash","Water wax wash","Nano mist","Interior Detailing","Ion coat waxing","Rim Coating","Head lamp dirt removal","Engine bay detailing","Undercarriage wash(engine)"]
        let rating:NSMutableArray = ["1","2","3","4","5","6","7","8","9","10"]
        self.pricingtextfield.delegate = cashDelegate
        self.servicedownpicker = DownPicker(textField: servicestextfield, withData: services as [AnyObject])
        self.ratingdownpicker = DownPicker(textField: ratingtextfield, withData: rating as [AnyObject])
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        
    }
    
    override func viewWillDisappear(animated:Bool){
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func subscribeToKeyboardNotifications() {
        // notification posted immediately prior to the display of the keyboard
        NSNotificationCenter .defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        // notification posted immediately prior to the dismissal of the keyboard
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    func unsubscribeFromKeyboardNotifications() {
        // remove all observers from self
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    func keyboardWillShow(notification:NSNotification) {
        
       
            view.frame.origin.y = -getKeyboardHeight(notification)
        
    }
    
    func keyboardWillHide(notification:NSNotification) {
        
            view.frame.origin.y = 0
        
    }
    
    // calculate the height of the Keyboard
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }

    @IBAction func addcarwash(sender: AnyObject)
    {
        var carwashobject = PFObject(className: "CarWash")
        let locManager = CLLocationManager()
       print(nametextfield.text)
        print(addresstextfield.text)
        print(cartextfield.text)
        print(pricingtextfield.text)
        print(servicestextfield.text)
        print(ratingtextfield.text)
        locManager.requestWhenInUseAuthorization()
        carwashobject["name"] = nametextfield.text
        carwashobject["address"] = addresstextfield.text
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addresstextfield.text!){
            placemark, error in
            if let error = error {
                self.showAlert("ERROR", message: error.localizedDescription)
                return
            }
            //self.activityIndicator.startAnimating()
            if let  placemark = placemark{
                if placemark.count > 0 {
                    let placemark = placemark.first!
                    let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                    if let country = placemark.country, state = placemark.administrativeArea{
                        if let city = placemark.locality{
                            carwashobject["address"] = "\(city), \(state), \(country)"
                            print(coordinates.latitude)
                            print(coordinates.longitude)
                            
                            self.carGeoPoint.latitude = coordinates.latitude
                            self.carGeoPoint.longitude = coordinates.longitude
                            print("***********************")
                            print(self.carGeoPoint.latitude)
                            print(self.carGeoPoint.longitude)
                            carwashobject["coor"] = self.carGeoPoint
                            
                            //self.stopActivityIndicator()
                        }else {
                            carwashobject["address"] = "\(state), \(country)"
                            carwashobject["coor"] = self.carGeoPoint
                            //self.stopActivityIndicator()
                        }
                    } else {
                        self.showAlert("ERROR", message:"Be more specific in location")
                    }
                } else {
                    self.showAlert("ERROR", message:"Unable to find location")
                }
            } else {
                self.showAlert("ERROR", message: "Unable to find location")
            }
        }
        carwashobject["car"] = cartextfield.text
        carwashobject["price"] = Double(pricingtextfield.text!)
        carwashobject["service"] = servicestextfield.text
        carwashobject["rating"] = Double(ratingtextfield.text!)
        
        carwashobject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            print("Object has been saved.")
            
        }
       

         performSegueWithIdentifier("backtomain", sender: self)
    }
    func showAlert(title: String? , message: String?) {
        dispatch_async(dispatch_get_main_queue()){
            if title != nil && message != nil {
                let errorAlert =
                UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
                errorAlert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(errorAlert, animated: true, completion: nil)
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if "backtomain" == segue.identifier {
           
            var wash = CarWash(title: self.nametextfield.text!, subtitle: self.addresstextfield.text!, coordinate: self.coordinates, car: self.cartextfield.text!, price: Double(self.pricingtextfield.text!)!, services: self.servicestextfield.text!, rating: Int(self.ratingtextfield.text!)!)
            let destination = segue.destinationViewController as! MainViewController
           destination.pin = wash
            
        }
    }
    @IBAction func closebutton(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
   
}

