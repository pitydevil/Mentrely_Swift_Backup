//
//  HospitalViewController.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 29/07/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class HospitalViewController: UIViewController,UISearchBarDelegate, CLLocationManagerDelegate {


    @IBOutlet weak var mapView: MKMapView!

    let manager = CLLocationManager()

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        let location = locations[0]
        let span : MKCoordinateSpan = MKCoordinateSpan.init(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let myLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region : MKCoordinateRegion = MKCoordinateRegion(center: myLocation, span: span)
        mapView.setRegion(region, animated: true)
        self.mapView.showsUserLocation = true


    }

    override func viewDidLoad() {
        super.viewDidLoad()


        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()

    }

    @IBAction func searchButton(_ sender: Any) {

        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)


    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        // ignoring user
        UIApplication.shared.beginIgnoringInteractionEvents()

        // activity indicator
        let activyIndicator = UIActivityIndicatorView()
        activyIndicator.style = UIActivityIndicatorView.Style.gray
        activyIndicator.center = self.view.center
        activyIndicator.hidesWhenStopped = true
        activyIndicator.startAnimating()

        self.view.addSubview(activyIndicator)
        // hide  search bar
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)

        // create search request

        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchBar.text

        let activeSearch  = MKLocalSearch(request: searchRequest)

        activeSearch.start { (response, error) in

        activyIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()

            if response == nil {

                print("error")

            } else {

                // remove notation

                let annotations = self.mapView.annotations
                self.mapView.removeAnnotations(annotations)

                // getting the data

                let latitude = response?.boundingRegion.center.latitude
                let longitude = response?.boundingRegion.center.longitude

                // creating annotation

                let annotation = MKPointAnnotation()
                annotation.title = searchBar.text
                annotation.coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
                self.mapView.addAnnotation(annotation)

                // zooming on the annotation

                let coordinate : CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude!, longitude!)
                let span = MKCoordinateSpan.init(latitudeDelta: 0.1, longitudeDelta: 0.1)
                let region = MKCoordinateRegion.init(center: coordinate, span: span)
                self.mapView.setRegion(region, animated: true)
            }
        }
    }









}
