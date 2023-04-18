//
//  ViewController.swift
//  MapKitDemo
//
//  Created by Munu Bhai on 4/16/23.
//

import MapKit
import CoreLocation
import UIKit


class ViewController: UIViewController, UISearchBarDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let initialRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        mapView.setRegion(initialRegion, animated: false)
        
        searchBar.delegate = self
        
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        mapView.addGestureRecognizer(pinchGesture)

    }
    
    @objc func handlePinchGesture(_ gestureRecognizer: UIPinchGestureRecognizer) {
        if gestureRecognizer.state == .changed {
            let scale = gestureRecognizer.scale
            let region = mapView.region
            let span = MKCoordinateSpan(latitudeDelta: region.span.latitudeDelta / Double(scale), longitudeDelta: region.span.longitudeDelta / Double(scale))
            let adjustedRegion = MKCoordinateRegion(center: region.center, span: span)
            mapView.setRegion(adjustedRegion, animated: false)
            gestureRecognizer.scale = 1.0
        }
    }

    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchBar.text + " gas stations"
        
//        let gasStationFilter = MKPointOfInterestFilter(including: [.gasStation])
//        searchRequest.pointOfInterestFilter = gasStationFilter
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            if let error = error {
                print("Error searching for location: \(error.localizedDescription)")
                return
            }
            guard let mapItem = response?.mapItems.first else {
                print("No locations found")
                return
            }
            
            self.mapView.removeAnnotations(self.mapView.annotations)

            for mapItem in response!.mapItems {
                let annotation = MKPointAnnotation()
                annotation.coordinate = mapItem.placemark.coordinate
                annotation.title = mapItem.name
                self.mapView.addAnnotation(annotation)
            }

            
            let region = MKCoordinateRegion(center: mapItem.placemark.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            self.mapView.setRegion(region, animated: true)
        }
    }
}
