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
    let sliderHeight: CGFloat = 15

    override func viewDidLoad() {
        super.viewDidLoad()

        panoView = GMSPanoramaView()
        self.view.addSubview(panoView)

        //TODO: move this out to function
        panoView.moveNearCoordinate(CLLocationCoordinate2DMake(-33.732, 150.312))

        //TODO: hook up target
        sliderView = UISlider()
        self.view.addSubview(sliderView)
    }

    override func viewWillLayoutSubviews() {
        panoView.frame = self.view.bounds
        
        sliderView.frame = CGRectMake(CGRectGetMinX(self.view.bounds) + sliderOffsetX, CGRectGetMaxY(self.view.bounds) - sliderOffsetY,
            self.view.bounds.width - 2 * sliderOffsetX, sliderHeight)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.All
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        self.view.setNeedsLayout()
    }
}

