//
//  PanoViewController.swift
//  photosphere
//
//  Created by Xuefan Zhang on 10/19/15.
//  Copyright © 2015 CodePath. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreMotion

class PanoViewController: UIViewController, GMSMapViewDelegate {
    
    /** Panorama Viewer **/
    var panoView: GMSPanoramaView!
    
    /** UISlider Constants **/
    var sliderView: UISlider!
    let sliderOffsetX: CGFloat = 50
    let sliderOffsetY: CGFloat = 40
    let sliderHeight: CGFloat = 15
    
    /** Core Motion Variables **/
    var motionManager: CMMotionManager!
    let FRAMES_PER_SECOND: Double = 30.0    // How often we update the camera
    let YAW_DIFF_THRESHOLD = 0.21           // Used to account for drift in iPhone sensors
    var lastYaw = 0.0                       // Used to keep track of last known iPhone sensor yaw reading
    var viewerYaw = 0.0                     // Used to keep track of panorama viewer camera yaw value

    /** Lat/Lng Viewer Coordinates **/
    var coordinate: CLLocationCoordinate2D?
    
    var curPanoIdx:Int = 0
    let panoIds = ["8M0oSy72ZpFk4J3un7SP_Q", "AAjXHanNaa7Dtqg2EJVeJw", "iomOIUdQxOrEDNwCcYZezA", "lr1iiI-kK-y2xh21Y-_2-Q", "l6e5AqxAybbXLR6JDZGAvQ", "Y5Ksm5XXnoRBIT0Yo9Y2tA", "ZOlaZcBNsJpGElMdV_9mgA", "Qekog4wpckRgvRtLfYtRPg", "tCSQSQHKh_FooZSarXIEXQ", "IghRrTimM7EWs47efin2Rw", "EqOQAAniB8iN0lhbBH6UtQ", "1ZtbDdNk9WVQdpg21IFSsg"]

//    let panoIds = ["PX6YfpzfUrt9uZSU1w0jgw", "lX_7bJrRcKYSc1TavLjEpA", "6OFOxdNE0bPOeIimGEZdww", "fW9Xcvf3Ruu6-3ztX98Atg", "Wa1lL6Gxwn5KpD8kNdwyGw", "M8OhPIPtPwUKVrVAaLB0Bg", "gGJFmV7F8390zQ7P-O53yw", "f1n1xnMpRTaqwxyX61I4-g", "9MPchhFmorzbgJojawhwog", "R1mfPYyD6b6mZTrvNfcYHw", "Z725BFV4tBx__LEbhkMqaA", "ITFc25E1U68uRvg1D9KHSg", "1c1bOspjxda0DqgboGkTcA", "SoMjaYiGi_ptXjWI775K6g"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
//        panoView.moveToPanoramaID("8M0oSy72ZpFk4J3un7SP_Q") // Nov 2007
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
        
        // Initialize panorama viewer
        panoView = GMSPanoramaView()
        panoView.streetNamesHidden = true
        panoView.navigationLinksHidden = true
        self.view.addSubview(panoView)
        
        // Set panorama coordinates
        if (coordinate != nil) {
            panoView.moveNearCoordinate(coordinate!)
        } else {
            panoView.moveNearCoordinate(CLLocationCoordinate2DMake(37.7737729,-122.408536))
        }

        // Set panorama camera to update with device motion (if motion sensors are available)
        motionManager = CMMotionManager()
        if motionManager?.deviceMotionAvailable == true {
            panoView.setAllGesturesEnabled(false)
            
            motionManager?.deviceMotionUpdateInterval = 1.0/self.FRAMES_PER_SECOND;
            let queue = NSOperationQueue()
            motionManager?.startDeviceMotionUpdatesUsingReferenceFrame(CMAttitudeReferenceFrame.XArbitraryCorrectedZVertical, toQueue: queue, withHandler: { [weak self] (motion, error) -> Void in
                
                // Get device orientation information
                let attitude = motion?.attitude
                let gravity = motion?.gravity
                if (attitude != nil && gravity != nil) {
                    let roll = attitude!.roll * 180.0/M_PI
                    let pitch = attitude!.pitch * 180.0/M_PI
                    let yaw = -attitude!.yaw * 180.0/M_PI
                    let gx = gravity!.x > 0 ? 1.0 : -1.0
                    
                    // Initialize variables for tracking device/viewer yaw values
                    if self!.lastYaw == 0 {
                        self!.lastYaw = yaw
                        self!.viewerYaw = yaw
                    }
                    
                    // Only update viewer yaw if device yaw has changed by a sufficient threshold
                    let yawDiff = yaw - self!.lastYaw
                    if (fabs(yawDiff) > self!.YAW_DIFF_THRESHOLD) {
                        self!.viewerYaw += yawDiff + gx * self!.YAW_DIFF_THRESHOLD
                    }
                    self!.lastYaw = yaw
                    
                    dispatch_async(dispatch_get_main_queue()) {
//                        print("r:\(roll), p:\(pitch), y:\(self!.viewerYaw)")
//                        print("gx:\(motion!.gravity.x), gy:\(motion!.gravity.y), gz:\(motion!.gravity.z)")
                        
                        // Update panorama viewer camera
                        self!.panoView.camera = GMSPanoramaCamera(heading: self!.viewerYaw, pitch:gx * roll - 90, zoom:1)
                    }
                }
            })
        }
        
        // Initialize slider
        sliderView = UISlider()
        sliderView.minimumValue = 0
        sliderView.maximumValue = Float(panoIds.count - 1)
        sliderView.addTarget(self, action: "sliderValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
        self.view.addSubview(sliderView)
    }

    override func viewWillLayoutSubviews() {
        // Layout panorama viewer
        panoView.frame = self.view.bounds
        
        // Layout slider
        sliderView.frame = CGRectMake(CGRectGetMinX(self.view.bounds) + sliderOffsetX, CGRectGetMaxY(self.view.bounds) - sliderOffsetY,
            self.view.bounds.width - 2 * sliderOffsetX, sliderHeight)
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.All
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        self.view.setNeedsLayout()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sliderValueChanged(slider: UISlider) -> () {
        let curIdx = Int(round(slider.value))
        if curIdx != curPanoIdx {
            panoView.moveToPanoramaID(panoIds[curIdx])
            curPanoIdx = curIdx
        }
    }
}

