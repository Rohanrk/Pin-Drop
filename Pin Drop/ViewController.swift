//
//  ViewController.swift
//  Pin Drop
//
//  Created by Rohan Rk on 2/21/17.
//  Copyright © 2017 Rohan Rk. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController, UIGestureRecognizerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        recognizer.minimumPressDuration = 0.5
        recognizer.delaysTouchesBegan = true
        recognizer.delegate = self
        mapView.addGestureRecognizer(recognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest : NSFetchRequest<Pin> = Pin.fetchRequest()
        
        do {
            let pins = try managedContext.fetch(fetchRequest)
            
            mapView.addAnnotations(pins)
        } catch let error as NSError {
            print("Could not fetch: \(error.localizedDescription)")
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
            
            let button = UIButton(type: .detailDisclosure)
            annotationView!.rightCalloutAccessoryView = button
        } else {
            annotationView!.annotation = annotation
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let pin = view.annotation as! Pin
        let name = pin.pinName
        let description = pin.pinDescription
        
        let alert = UIAlertController(title: name, message: description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .default))
        present(alert, animated: true)
    }

    func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state != UIGestureRecognizerState.ended {
            return
        }
        
        let location = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        let alert = UIAlertController(title: "Add a new Pin", message: nil, preferredStyle:.alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Pin Name"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Pin Description"
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            let nameTextField = alert.textFields![0]
            let descriptionTextField = alert.textFields![1]
            let name = nameTextField.text ?? "Pin Name"
            let description = descriptionTextField.text ?? "Pin Description"
            
            if let pin = self.savePin(name: name, description: description, location: coordinate) {
                self.mapView.addAnnotation(pin)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func savePin(name: String, description: String, location: CLLocationCoordinate2D) -> Pin? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let pin = Pin(context: managedContext)
        pin.pinName = name
        pin.pinDescription = description
        pin.pinLat = location.latitude
        pin.pinLong = location.longitude
        
        do {
            try managedContext.save()
            return pin
        } catch let error as NSError {
            print("Could not save: \(error.localizedDescription)")
            return nil
        }
    }
}

