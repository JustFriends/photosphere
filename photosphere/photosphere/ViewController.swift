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
    
    
    @IBOutlet weak var bottomView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: use auto layout constraints instead of frame... maybe frame
        
        var panoView = GMSPanoramaView(frame: self.view.frame)
        panoView.moveNearCoordinate(CLLocationCoordinate2DMake(-33.732, 150.312))
        
        //TODO: hook up target
        var slider = UISlider(frame: CGRectMake(150, 280, self.view.frame.width * 0.5, 20)) //TODO: customize slider
        
        // TODO: stylez
        var mapButton = UIButton(type: UIButtonType.System)
        mapButton.frame = CGRectMake(500, 10, 40, 40)
        mapButton.backgroundColor = UIColor.blueColor()
        mapButton.setTitle("Map", forState: UIControlState.Normal)
        mapButton.addTarget(self, action: "onMapClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(panoView)
        self.view.addSubview(slider)
        self.view.addSubview(mapButton)
        
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
}

