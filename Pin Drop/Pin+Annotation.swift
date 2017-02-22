//
//  Pin+Annotation.swift
//  Pin Drop
//
//  Created by Rohan Rk on 2/21/17.
//  Copyright © 2017 Rohan Rk. All rights reserved.
//

import Foundation
import MapKit

extension Pin: MKAnnotation {
    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.pinLat, longitude: self.pinLong)
    }
    
    public var title: String? {
        return self.pinName
    }
}
