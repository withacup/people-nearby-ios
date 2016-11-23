//
//  MapVC.swift
//  PeopleNearBy
//
//  Created by Tianxiao Yang on 11/22/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class MapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    var hasCentered = false
    var geoFireInstance: GeoFire!
    var geoFireRef: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // geature recognizer 
        // https://github.com/azavea/ios-draggable-annotations-demo/blob/master/FinalCustomDraggableAnnotationDemo/FinalCustomDraggableAnnotationDemo/AZViewController.m
        
        mapView.delegate = self
        mapView.userTrackingMode = MKUserTrackingMode.follow
        
        attempToAuthLocation()
        
        geoFireRef = FIRDatabase.database().reference()
        geoFireInstance = GeoFire(firebaseRef: geoFireRef)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {

    }
    
    func attempToAuthLocation() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            
            mapView.showsUserLocation = true
        
            // Add recognier if user has authorized using location
            let singleTapRecognier: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap))
            
            singleTapRecognier.numberOfTapsRequired = 1
            singleTapRecognier.numberOfTouchesRequired = 1
            mapView.addGestureRecognizer(singleTapRecognier)
            
        } else {
            
            locationManager.requestWhenInUseAuthorization()
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            mapView.showsUserLocation = false
        }
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if let newLocation = userLocation.location, !hasCentered {
            
            self.hasCentered = true
            centerMapOnLocation(location: newLocation)
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        
        let coord = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500)
        
        mapView.setRegion(coord, animated: true)
    }
    
    // Generate the annotation view for specific annotation (user, event)
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var annotationView: MKAnnotationView?
        
        if annotation.isKind(of: MKUserLocation.self) {
            
            if let deqAnno = mapView.dequeueReusableAnnotationView(withIdentifier: "User") {
                
                annotationView = deqAnno
            } else {
                
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "User")
                
                // TODO: add a button here to contact with user
            }
            
            print("$debug user annotation")
            
            annotationView?.canShowCallout = false
            annotationView?.image = UIImage(named: "duck")
            
            
        } else {
            
            if let deqAnno = mapView.dequeueReusableAnnotationView(withIdentifier: "Event") {
                
                annotationView = deqAnno
            } else {
                
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "Event")
                // TODO: setup annotation view with info from annotation
                // TODO: add a button here to join the event
                
            }
            
            print("$debug event annotation")
            
            annotationView?.canShowCallout = true
            annotationView?.image = UIImage(named: "event")
            
        }
        
//        let a = MKPinAnnotationView()

        return annotationView
//        return a
        
    }
    
    
    func handleSingleTap(gesture: UIGestureRecognizer) {
        
        let touchPoint: CGPoint = gesture.location(in: mapView)
        
        let coord = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
//        createAnnoForEvent(forlocation: coord, withEventName: "Unique Event Name")
        
        let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        
        geoFireInstance.setLocation(location, forKey: "Test New Event", withCompletionBlock: nil)
        
        print("$debug handling new event on location: \(coord)")
    
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        
        let location = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        
        showSightingsOnMap(location: location)
        
    }
    
    func showSightingsOnMap(location: CLLocation) {
        
        let circleQuery = geoFireInstance.query(at: location, withRadius: 1)
        
        _ = circleQuery?.observe(GFEventType.keyEntered, with: { (key, location) in
        
            if let key = key, let location = location {
                
                self.createAnnoForEvent(forlocation: location.coordinate, withEventName: key)
                
            }
        })
        
    }
    
    func createAnnoForEvent(forlocation location: CLLocationCoordinate2D, withEventName eventName: String) {
        
        let eventAnno = EventAnnotation(coordinate: location, eventName: eventName, eventTime: "Today", eventHolder: "Tianxiao Yang", eventImg: UIImage(named: "event")!)
        
        mapView.addAnnotation(eventAnno)
        
    }

}


























