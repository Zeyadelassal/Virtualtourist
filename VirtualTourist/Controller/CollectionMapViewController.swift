//
//  CollectionMapViewController.swift
//  VirtualTourist
//
//  Created by zeyadel3ssal on 5/31/19.
//  Copyright © 2019 zeyadel3ssal. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class CollectionMapViewController: UIViewController{
    
  
    @IBOutlet weak var collectionViewActivityIndictor: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollection: UIBarButtonItem!
    var selectedLocation : Location!
    var totalPages : Int16!
    var dataController : DataController!
    var fetchedResultsController : NSFetchedResultsController<Image>!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultController()
        updateFlowLayout(view.frame.size)
        let flag = checkImages()
        print(flag)
        if flag{
            print("Count:\(String(describing: fetchedResultsController.fetchedObjects?.count))")
            DispatchQueue.main.async {
                self.setUI(true)
            }
        }else{
            setUI(false)
            FlickrClient.sharedInstance().getImagesFromFlickr(longitude: selectedLocation.longitude, latitude: selectedLocation.latitude,pageNumber:1){(result,pages,error) in
                print("Pages: \(String(describing: pages))")
                self.totalPages = pages
                self.makeImagesURLStringArray(result!)
                print("pages:\(self.selectedLocation.numberOfPages)")
                DispatchQueue.main.async {
                    self.setUI(true)
                }
            }
        }
    }
    
    deinit {
        fetchedResultsController = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        collectionView.delegate = self
        showSelectedLocation(latitude: selectedLocation.latitude, longitude: selectedLocation.longitude)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        updateFlowLayout(size)
    }
    
    @IBAction func requestNewImages(_ sender: Any) {
        collectionViewActivityIndictor.startAnimating()
        for image in (fetchedResultsController.fetchedObjects)!{
            dataController.viewContext.delete(image)
        }
        try?dataController.viewContext.save()
        setupFetchedResultController()
        DispatchQueue.main.async {
            self.setUI(false)
        }
        totalPages = selectedLocation.numberOfPages
        let pageLimit = min(totalPages,40)
        let randomPage = Int16(arc4random_uniform(UInt32(pageLimit))) + 1
        FlickrClient.sharedInstance().getImagesFromFlickr(longitude: selectedLocation.longitude, latitude: selectedLocation.latitude, pageNumber: randomPage){(result,pages,error) in
            self.makeImagesURLStringArray(result!)
            DispatchQueue.main.async {
                self.setUI(true)
            }
        }
    }
    
    func setupFetchedResultController(){
        let fetchRequest : NSFetchRequest<Image> = Image.fetchRequest()
        let predicate = NSPredicate(format: "location == %@", selectedLocation)
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = predicate
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        do{
            try fetchedResultsController.performFetch()
        }catch{
            print("Can't fetch pictures")
        }
    }
    
    func checkImages()->Bool{
        if let data = fetchedResultsController.fetchedObjects,data.count>0
        {
            print("Already exist")
            return true
        }else{
            print("NEW")
            return false
        }
    }
    
    func makeImagesURLStringArray(_ results:[DownloadedFlickrImage]){
        for result in results{
            let image = Image(context: dataController.viewContext)
            image.imageURLString = result.imageStringURL
            image.location = selectedLocation
            selectedLocation.numberOfPages = totalPages
            try? dataController.viewContext.save()
            setupFetchedResultController()
        }
    }
    
    func setUI(_ bool : Bool){
        if bool{
            self.newCollection.isEnabled = bool
            self.collectionView.reloadData()
            self.collectionViewActivityIndictor.stopAnimating()
        }else{
            self.newCollection.isEnabled = bool
            self.collectionView.reloadData()
            self.collectionViewActivityIndictor.startAnimating()
        }
    }
}


//MARK : MapView
extension CollectionMapViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        if pinView == nil{
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView?.pinTintColor = .red
        }else{
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    //Show zoomed in selected location
    func showSelectedLocation(latitude:Double,longitude:Double){
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        //Zoom in to selected location
        let span = MKCoordinateSpan.init(latitudeDelta: 0.25, longitudeDelta: 0.25)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        self.mapView.addAnnotation(annotation)
        self.mapView.setRegion(region, animated: true)
    }
}


//MARK : CollectionView
extension CollectionMapViewController : UICollectionViewDataSource,UICollectionViewDelegate{
    
    private func updateFlowLayout(_ withSize: CGSize) {
        
        let landscape = withSize.width > withSize.height
        
        let space: CGFloat = landscape ? 5 : 3
        let items: CGFloat = landscape ? 2 : 3
        
        let dimension = (withSize.width - ((items + 1) * space)) / items
        
         collectionViewFlowLayout.minimumInteritemSpacing = space
         collectionViewFlowLayout.minimumLineSpacing = space
         collectionViewFlowLayout.itemSize = CGSize(width: dimension, height: dimension)
         collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: space, left: space, bottom: space, right: space)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (fetchedResultsController.sections?[0].numberOfObjects)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! CollectionViewCell
        cell.imageView = nil
        cell.activityIndicator.startAnimating()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! CollectionViewCell
        let imageURLString = fetchedResultsController.object(at: indexPath).imageURLString
        let imageURL = URL(string: imageURLString!)
        if let imageData = try? Data(contentsOf: imageURL!){
            cell.imageView.image = UIImage(data: imageData)
            cell.activityIndicator.stopAnimating()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = UIAlertController(title: "Alert", message: "Do you want to delete this image", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive){action in
            self.deleteSelectedImage(index: indexPath)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){action in
            controller.dismiss(animated: true, completion: nil)
        }
        controller.addAction(cancelAction)
        controller.addAction(deleteAction)
        present(controller,animated: true,completion: nil)
    }
    
    func deleteSelectedImage(index:IndexPath){
        let imageToDelete = fetchedResultsController.object(at: index)
        dataController.viewContext.delete(imageToDelete)
        try? dataController.viewContext.save()
        setupFetchedResultController()
        collectionView.deleteItems(at: [index])
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}


