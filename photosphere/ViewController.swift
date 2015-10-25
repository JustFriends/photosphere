//
//  ViewController.swift
//  photosphere
//
//  Created by Xuefan Zhang on 10/19/15.
//  Copyright © 2015 CodePath. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController, GMSMapViewDelegate {
    var panoView: GMSPanoramaView!
    var sliderView: UISlider!
    
    let sliderOffsetX: CGFloat = 50
    let sliderOffsetY: CGFloat = 40
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        panoView = GMSPanoramaView()
        self.view.addSubview(panoView)
        
        //TODO: move this out to function
        panoView.moveNearCoordinate(CLLocationCoordinate2DMake(-33.732, 150.312))
        
        
        //TODO: hook up target
        sliderView = UISlider()
        self.view.addSubview(sliderView)
        
        // TODO: stylez
        //        var mapButton = UIButton(type: UIButtonType.System)
        //        mapButton.frame = CGRectMake(500, 10, 40, 40)
        //        mapButton.backgroundColor = UIColor.blueColor()
        //        mapButton.setTitle("Map", forState: UIControlState.Normal)
        //        mapButton.addTarget(self, action: "onMapClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        
        
        
        //        self.view.addSubview(mapButton)
        
    }
    
    override func viewWillLayoutSubviews() {
        panoView.frame = self.view.bounds
        
        sliderView.frame = CGRectMake(CGRectGetMinX(self.view.bounds) + sliderOffsetX, CGRectGetMaxY(self.view.bounds) - sliderOffsetY,
            self.view.bounds.width - 2 * sliderOffsetX, 15)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onMapClicked(sender:UIButton!){
        //TODO: push to explore/map view controller
        print("on Map button clicked")
        let mapViewController:MapViewController = MapViewController()
        self.presentViewController(mapViewController, animated: true, completion: nil)
        //navigationController?.pushViewController("MapViewController", animated: true)
        
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.All
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        self.view.setNeedsLayout()
    }
}

