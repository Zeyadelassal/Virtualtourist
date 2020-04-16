//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by zeyadel3ssal on 5/30/19.
//  Copyright © 2019 zeyadel3ssal. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController,MKMapViewDelegate {
    
    //MARK : Properties
    @IBOutlet weak var mapView: MKMapView!
    var dataController : DataController!
    var locations = [Location]()
    var annotations = [MKPointAnnotation]()
    var locationCoordinate : CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        //Add long press gesture to get the pressed location coordinates
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(revealLoctionDetails(_:)))
        mapView.addGestureRecognizer(longPress)
        
        //Fetch locations from persistent store
        setupFetchRequest()
    }
    
    //Get location geo coodrinates upon pressing
    @objc func revealLoctionDetails(_ sender: UILongPressGestureRecognizer) {
        if sender.state != UILongPressGestureRecognizer.State.began {return}
        let location  = sender.location(in: mapView)
        locationCoordinate = mapView.convert(location, toCoordinateFrom: mapView)
        print("Tapped at lat:'\(locationCoordinate.latitude)' and long:'\(locationCoordinate.longitude)'")
       addLocation(locationCoordinate)
    }
    
    //Add location to persistent store
    func addLocation(_ coordinate : CLLocationCoordinate2D){
        let location = Location(context: dataController.viewContext)
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        locations.append(location)
        do{
            try dataController.viewContext.save()
        }catch{
            showInfoAlert("Can't load locations data")
        }
        showLocations()
    }
    
    //Show locations on the map
    func showLocations(){
        for location in locations{
            let lat = location.latitude
            let long = location.longitude
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotations.append(annotation)
        }
        self.mapView.addAnnotations(annotations)
        self.mapView.showAnnotations(annotations, animated: true)
    }
    
    //Setup fetching request to get locations data from persistent store
    func setupFetchRequest(){
        let fetchRequest : NSFetchRequest<Location> = Location.fetchRequest()
        if let result = try? dataController.viewContext.fetch(fetchRequest){
            locations = result
            showLocations()
        }
    }
    
    //Get the selected pin location coordinates from persistent store
    func getSelectedLocation(latitude:String,longitude:String)->Location{
        let fetchRequest : NSFetchRequest<Location> = Location.fetchRequest()
        let predicate = NSPredicate(format: "latitude == %@ AND longitude == %@",latitude,longitude)
        fetchRequest.predicate = predicate
        let selectedLocation = try? dataController.viewContext.fetch(fetchRequest)
        return (selectedLocation?.first)!
    }
    
    //Show location on map as pin
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView?.pinTintColor = .red
        }else{
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    //Move to the photo album view on pressing on the pin
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else {return}
        mapView.deselectAnnotation(annotation, animated: true)
        let lat = String(annotation.coordinate.latitude)
        let long = String(annotation.coordinate.longitude)
        let selectedLocation = getSelectedLocation(latitude: lat, longitude: long)
        print("Selected Location , lat : \(selectedLocation.latitude),long :\(selectedLocation.longitude)")
        performSegue(withIdentifier: "performSegue", sender: selectedLocation)
    }
    
    //Inject annotations and coordinate to photo album view before moving
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "performSegue"{
            let controller = segue.destination as? CollectionMapViewController
            controller?.selectedLocation = sender as? Location
            controller!.dataController = self.dataController
        }
    }
    
    //Show alert info
    func showInfoAlert(_ message:String){
        let controller = UIAlertController(title: "Info", message: message , preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default){action in
            controller.dismiss(animated: true, completion: nil)
        }
        controller.addAction(okAction)
        present(controller,animated: true,completion: nil)
    }
}

