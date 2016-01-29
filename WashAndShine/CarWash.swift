//
//  CarWash.swift
//  WashAndShine
//
//  Created by Sharifah Nazreen Ashraff ali on 28/01/2016.
//  Copyright © 2016 Syed Mohamed Ariff. All rights reserved.
//

import Foundation
import MapKit
class CarWash : NSObject,MKAnnotation
{
    var title : String? = nil
    //var subtitle : String? = nil
    var coordinate:CLLocationCoordinate2D
    var price : Double?
    var services : String? = nil
    var rating : Int?
    var car : String? = nil
    
    init(title : String,subtitle:String,coordinate:CLLocationCoordinate2D,car:String,price:Double,services:String,rating:Int)
    {
        self.title = title
       // self.subtitle = subtitle
        self.coordinate = coordinate
        self.car = car
        self.price = price
        self.services = services
        self.rating = rating
    }
    
    
}