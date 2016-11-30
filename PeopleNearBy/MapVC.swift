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

let FILE_NAME = "MapVC.swift"

class MapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newEventBtn: UIButton!
    
    let locationManager = CLLocationManager()
    
    var hasCentered = false
    var geoFireInstance: GeoFire!
    var REF_EVET: FIRDatabaseReference!
    var singleTapRecognier: UITapGestureRecognizer!
    
    // [EventName:annotation]
    var currentEventAnnos = Dictionary<String,EventAnnotation>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        // geature recognizer 
        // https://github.com/azavea/ios-draggable-annotations-demo/blob/master/FinalCustomDraggableAnnotationDemo/FinalCustomDraggableAnnotationDemo/AZViewController.m
        
        mapView.delegate = self
        mapView.userTrackingMode = MKUserTrackingMode.follow
        
        attempToAuthLocation()
        
        geoFireInstance = GeoFireService.sharedInstance.getInstance
        REF_EVET = GeoFireService.sharedInstance.REF_EVENT
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        newEventBtn.isSelected = false
        if singleTapRecognier != nil {
            singleTapRecognier.isEnabled = false
        }
    }
    
    func attempToAuthLocation() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            
            mapView.showsUserLocation = true
        
            // Add recognier if user has authorized using location
            singleTapRecognier = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap))
            
            
            self.singleTapRecognier.numberOfTapsRequired = 1
            self.singleTapRecognier.numberOfTouchesRequired = 1
            self.mapView.addGestureRecognizer(singleTapRecognier)
            self.singleTapRecognier.isEnabled = false
            
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
            
            Debug.printEvent(withEventDescription: "getting user annotation", inFile: FILE_NAME)
            
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
            
            Debug.printEvent(withEventDescription: "getting event annotation", inFile: FILE_NAME)
            
            annotationView?.canShowCallout = true
            annotationView?.image = UIImage(named: "event")
            
            let rightBtn = UIButton(type: UIButtonType.detailDisclosure)
            
            annotationView?.rightCalloutAccessoryView = rightBtn
            annotationView?.leftCalloutAccessoryView = UIImageView(image: UIImage(named: "dog"))
            
        }

        return annotationView
        
    }
    
    // user tapped on callout
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        // TODO: perform segue to event detail view controller
        
        if let eventAnno = view.annotation as? EventAnnotation {
            
            performSegue(withIdentifier: "EventDetailVC", sender: eventAnno.eventInfo)
            
        }
    }
    
    func handleSingleTap(gesture: UIGestureRecognizer) {
        
        let touchPoint: CGPoint = gesture.location(in: mapView)
        
        let coord = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        
        print("$debug handling new event on location: \(coord)")
        
        performSegue(withIdentifier: "NewEventVC", sender: location)
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewEventVC" {
            if let destination = segue.destination as? NewEventVC {
                if let location = sender as? CLLocation {
                 
                    destination.location = location
                    
                }
            }
        } else  if segue.identifier == "EventDetailVC", let eventInfo = sender as? EventInfo {
            
            if let destination = segue.destination as? EventDetailVC {
                
                destination.configViewWithEventInfo(withEventInfo: eventInfo)
                
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        
        let location = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        
        showSightingsOnMap(location: location)
        
    }
    
    func showSightingsOnMap(location: CLLocation) {
        
        let circleQuery = geoFireInstance.query(at: location, withRadius: 1)
        
        _ = circleQuery?.observe(GFEventType.keyEntered, with: { (key, location) in
        
            if let key = key, let location = location {
                
                self.REF_EVET.child(key).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let value = snapshot.value as? Dictionary<String, String> {
                        
                        let singleEvent = EventInfo(eventName: value["name"]!, eventTime: value["time"]!, eventHolder: value["holder"]!, eventDesription: value["content"]!, eventImg: UIImage(named: "dog")!, eventId: key)
                        
                        _ = self.createAnnoForEvent(forlocation: location.coordinate, eventInfo:  singleEvent)
                        
                    }
                })
            }
        })
        
        _ = circleQuery?.observe(.keyExited, with: {(key, location) in
            
            if let key = key {
                self.mapView.annotations.forEach({ (anno) in
                    if let eventAnno  = anno as? EventAnnotation {
                        if eventAnno.eventInfo.eventId == key {
                            
                            self.mapView.removeAnnotation(anno)
                            
                            Debug.printEvent(withEventDescription: "removing annotation with key \(key)", inFile: "MapVC")
                            
                        }
                    }
                })
            }
            
            Debug.printEvent(withEventDescription: "key exited", inFile: "MapVC")
            
        })
    }
    
    func createAnnoForEvent(forlocation location: CLLocationCoordinate2D, eventInfo: EventInfo) -> EventAnnotation{
        
        let eventAnno = EventAnnotation(coordinate: location, eventInfo: eventInfo)
        
        mapView.addAnnotation(eventAnno)
        
        return eventAnno
    }

    @IBAction func newEventBtnPressed(_ sender: UIButton) {
        
        if !sender.isSelected {
            
            sender.isSelected = true
            self.singleTapRecognier.isEnabled = true
            
        } else {
            
            sender.isSelected = false
            self.singleTapRecognier.isEnabled = false
            
        }
    }
    
    @IBAction func backToContact() {
        
//        self.dismiss(animated: true, completion: nil)
        _ = navigationController?.popViewController(animated: true)
        
    }
}


























