//
//  ViewController.swift
//  photosphere
//
//  Created by Xuefan Zhang on 10/19/15.
//  Copyright © 2015 CodePath. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreMotion

class ViewController: UIViewController, GMSMapViewDelegate {
    
    var panoView: GMSPanoramaView!
    
    var sliderView: UISlider!
    let sliderOffsetX: CGFloat = 50
    let sliderOffsetY: CGFloat = 40
    let sliderHeight: CGFloat = 15
    
    var motionManager: CMMotionManager!
    
    let YAW_DIFF_THRESHOLD = 0.21
    var lastYaw = 0.0
    var viewerYaw = 0.0
    
    let FRAMES_PER_SECOND: Double = 30.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        panoView = GMSPanoramaView()
        panoView.streetNamesHidden = true
        panoView.navigationLinksHidden = true
        self.view.addSubview(panoView)

        //TODO: move this out to function
//        panoView.moveNearCoordinate(CLLocationCoordinate2DMake(-33.732, 150.312))
        
        // Ferry Building (37.7944876,-122.3948276)
//        let panoramaNear = CLLocationCoordinate2DMake(37.7944876,-122.3948276)
//        panoView.moveToPanoramaID("PX6YfpzfUrt9uZSU1w0jgw") // Mar 2008
//        panoView.moveToPanoramaID("lX_7bJrRcKYSc1TavLjEpA") // Apr 2008
//        panoView.moveToPanoramaID("6OFOxdNE0bPOeIimGEZdww") // Jul 2009
//        panoView.moveToPanoramaID("fW9Xcvf3Ruu6-3ztX98Atg") // Apr 2011
//        panoView.moveToPanoramaID("Wa1lL6Gxwn5KpD8kNdwyGw") // May 2013
//        panoView.moveToPanoramaID("M8OhPIPtPwUKVrVAaLB0Bg") // Jun 2013
//        panoView.moveToPanoramaID("gGJFmV7F8390zQ7P-O53yw") // Feb 2014
//        panoView.moveToPanoramaID("f1n1xnMpRTaqwxyX61I4-g") // Apr 2014
//        panoView.moveToPanoramaID("9MPchhFmorzbgJojawhwog") // May 2014
//        panoView.moveToPanoramaID("R1mfPYyD6b6mZTrvNfcYHw") // Jun 2014
//        panoView.moveToPanoramaID("Z725BFV4tBx__LEbhkMqaA") // Aug 2014
//        panoView.moveToPanoramaID("ITFc25E1U68uRvg1D9KHSg") // Nov 2014
//        panoView.moveToPanoramaID("1c1bOspjxda0DqgboGkTcA") // Jan 2015
//        panoView.moveToPanoramaID("SoMjaYiGi_ptXjWI775K6g") // Jul 2015
        
        // 8th & Harrison (37.7737729,-122.408536)
        panoView.moveToPanoramaID("8M0oSy72ZpFk4J3un7SP_Q") // Nov 2007
//        panoView.moveToPanoramaID("AAjXHanNaa7Dtqg2EJVeJw") // Jul 2009
//        panoView.moveToPanoramaID("iomOIUdQxOrEDNwCcYZezA") // Feb 2011
//        panoView.moveToPanoramaID("lr1iiI-kK-y2xh21Y-_2-Q") // May 2013
//        panoView.moveToPanoramaID("l6e5AqxAybbXLR6JDZGAvQ") // Nov 2013
//        panoView.moveToPanoramaID("Y5Ksm5XXnoRBIT0Yo9Y2tA") // Jan 2014
//        panoView.moveToPanoramaID("ZOlaZcBNsJpGElMdV_9mgA") // Jun 2014
//        panoView.moveToPanoramaID("Qekog4wpckRgvRtLfYtRPg") // Jul 2014
//        panoView.moveToPanoramaID("tCSQSQHKh_FooZSarXIEXQ") // Oct 2014
//        panoView.moveToPanoramaID("IghRrTimM7EWs47efin2Rw") // Feb 2015
//        panoView.moveToPanoramaID("EqOQAAniB8iN0lhbBH6UtQ") // Jun 2015
//        panoView.moveToPanoramaID("1ZtbDdNk9WVQdpg21IFSsg") // Jul 2015

        //TODO: hook up target
        sliderView = UISlider()
        self.view.addSubview(sliderView)
    }

    override func viewWillLayoutSubviews() {
        panoView.frame = self.view.bounds
//        self.view.addSubview(panoView)
        
        sliderView.frame = CGRectMake(CGRectGetMinX(self.view.bounds) + sliderOffsetX, CGRectGetMaxY(self.view.bounds) - sliderOffsetY,
            self.view.bounds.width - 2 * sliderOffsetX, sliderHeight)
//        self.view.addSubview(slider)
        
        motionManager = CMMotionManager()
        if motionManager?.deviceMotionAvailable == true {
            panoView.setAllGesturesEnabled(false)
            
            motionManager?.deviceMotionUpdateInterval = 1.0/self.FRAMES_PER_SECOND;
            let queue = NSOperationQueue()
            motionManager?.startDeviceMotionUpdatesUsingReferenceFrame(CMAttitudeReferenceFrame.XArbitraryCorrectedZVertical, toQueue: queue, withHandler: { [weak self] (motion, error) -> Void in
                
                // Get the attitude of the device
                if let attitude = motion?.attitude {
                    var roll = attitude.roll * 180.0/M_PI
                    var pitch = attitude.pitch * 180.0/M_PI
                    var yaw = -attitude.yaw * 180.0/M_PI
                    
                    if self!.lastYaw == 0 {
                        self!.lastYaw = yaw
                        self!.viewerYaw = yaw
                    }
                    
//                    // kalman filtering
//                    var q = 0.2   // process noise
//                    var r = 0.2   // sensor noise
//                    var p = 0.1   // estimated error
//                    var k = 0.5   // kalman filter gain
//                    
//                    var x = self!.lastYaw
//                    p = p + q
//                    k = p / (p + r)
//                    x = x + k*(yaw - x)
//                    p = (1 - k)*p
//                    self!.lastYaw = x
                    
                    var yawDiff = yaw - self!.lastYaw
                    if (fabs(yawDiff) > self!.YAW_DIFF_THRESHOLD) {
                        self!.viewerYaw += yawDiff + self!.YAW_DIFF_THRESHOLD
                    }
                    self!.lastYaw = yaw
                    
                    dispatch_async(dispatch_get_main_queue()) {
//                        print("r:\(roll), p:\(pitch), y:\(x)")
                        
                        self!.panoView.camera = GMSPanoramaCamera(heading: self!.viewerYaw, pitch:roll - 90, zoom:1)
                    }
                }
            })
        } else {
            print("Device motion unavailable");
        }
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

