//
//  MapViewController.swift
//  photosphere
//
//  Created by Xuefan Zhang on 10/20/15.
//  Copyright © 2015 CodePath. All rights reserved.
//

import UIKit
import GoogleMaps

protocol MapViewControllerDelegate {
    func mapViewController(mapViewcontroller: MapViewController!, didDismissWithCoordinate coordinate: CLLocationCoordinate2D)
}

class MapViewController: UIViewController, GMSMapViewDelegate {
    
    var delegate: MapViewControllerDelegate?
    
    var coordinate: CLLocationCoordinate2D?
    let defaultZoom: Float = 14

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set panorama coordinates
        if (coordinate == nil) {
            coordinate = CLLocationCoordinate2DMake(37.7737729,-122.408536)
        }

        let camera = GMSCameraPosition.cameraWithTarget(coordinate!, zoom: defaultZoom)
        let mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        mapView.delegate = self;
        mapView.myLocationEnabled = true
        self.view = mapView
        
        let marker = GMSMarker()
        marker.position = coordinate!
        marker.map = mapView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        self.delegate?.mapViewController(self, didDismissWithCoordinate: coordinate)
        self.dismissViewControllerAnimated(true, completion: nil)   //TODO: do we really want to dismiss it?
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [UIInterfaceOrientationMask.LandscapeLeft,UIInterfaceOrientationMask.LandscapeRight]
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
