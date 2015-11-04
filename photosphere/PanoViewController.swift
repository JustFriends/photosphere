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
import Parse
import JavaScriptCore

class PanoViewController: UIViewController {
    
    /** Panorama Viewer **/
    var panoView: GMSPanoramaView!
    
    /** UISlider for Transitioning Panoramas **/
    var sliderView: UISlider!
    let sliderOffsetX: CGFloat = 80
    let sliderOffsetY: CGFloat = 40
    let sliderHeight: CGFloat = 15
    
    /** Back Button **/
    var backButton: UIButton!
    let buttonOffsetX: CGFloat = 10
    let buttonOffsetY: CGFloat = 10
    let buttonSideLength: CGFloat = 32
    
    /** UIWebView for Javascript Queries **/
    var webView: UIWebView!
    var context: JSContext!
    
    /** Date Label **/
    var dateLabel: UILabel!
    var dateLabelOffsetY: CGFloat = 10
    
    /** Core Motion Variables **/
    var motionManager: CMMotionManager!
    let FRAMES_PER_SECOND: Double = 30.0    // How often we update the camera
    let YAW_DIFF_THRESHOLD = 0.21           // Used to account for drift in iPhone sensors
    var lastYaw = 0.0                       // Used to keep track of last known iPhone sensor yaw reading
    var viewerYaw = 0.0                     // Used to keep track of panorama viewer camera yaw value

    /** Lat/Lng Viewer Coordinates **/
    var coordinate: CLLocationCoordinate2D?
    
    /** PanoIDs **/
    var curPanoIdx:Int = 0
    
//    let panoIds = ["8M0oSy72ZpFk4J3un7SP_Q", "AAjXHanNaa7Dtqg2EJVeJw", "iomOIUdQxOrEDNwCcYZezA", "lr1iiI-kK-y2xh21Y-_2-Q", "l6e5AqxAybbXLR6JDZGAvQ", "Y5Ksm5XXnoRBIT0Yo9Y2tA", "ZOlaZcBNsJpGElMdV_9mgA", "Qekog4wpckRgvRtLfYtRPg", "tCSQSQHKh_FooZSarXIEXQ", "IghRrTimM7EWs47efin2Rw", "EqOQAAniB8iN0lhbBH6UtQ", "1ZtbDdNk9WVQdpg21IFSsg"]

//    let panoIds = ["PX6YfpzfUrt9uZSU1w0jgw", "lX_7bJrRcKYSc1TavLjEpA", "6OFOxdNE0bPOeIimGEZdww", "fW9Xcvf3Ruu6-3ztX98Atg", "Wa1lL6Gxwn5KpD8kNdwyGw", "M8OhPIPtPwUKVrVAaLB0Bg", "gGJFmV7F8390zQ7P-O53yw", "f1n1xnMpRTaqwxyX61I4-g", "9MPchhFmorzbgJojawhwog", "R1mfPYyD6b6mZTrvNfcYHw", "Z725BFV4tBx__LEbhkMqaA", "ITFc25E1U68uRvg1D9KHSg", "1c1bOspjxda0DqgboGkTcA", "SoMjaYiGi_ptXjWI775K6g"]
    
//    let panoIds = ["8M0oSy72ZpFk4J3un7SP_Q", "AAjXHanNaa7Dtqg2EJVeJw", "iomOIUdQxOrEDNwCcYZezA", "lr1iiI-kK-y2xh21Y-_2-Q", "l6e5AqxAybbXLR6JDZGAvQ", "Y5Ksm5XXnoRBIT0Yo9Y2tA", "ZOlaZcBNsJpGElMdV_9mgA", "Qekog4wpckRgvRtLfYtRPg", "tCSQSQHKh_FooZSarXIEXQ", "IghRrTimM7EWs47efin2Rw", "EqOQAAniB8iN0lhbBH6UtQ", "1ZtbDdNk9WVQdpg21IFSsg"]
    
//    let panoIds = ["1Dy-VwTcyuQvB5I_-7_2Rw", "Bkj5T7_ucCqszo041xDzYA", "Po_C7wwaeWUCogm7AlcG2w", "o_if0Nlc0rPFareD1jew1w", "jExha2UWpDyCoWF_k83z_A", "9tSX6Us59MBve8kZtJkEMA", "4fTr34kJu9FM_7KQ9M77bQ", "e2KORPNObCvD878fUZxalQ", "jB0WxPBjOcXBwSjp1ZbkOQ", "bz2f1lKHqBBL1-YeAb5gWg"]
    
    let panoIds = ["ydgoRUaihAL1HsBupYpg3g", "z0zIzWF1FXzlFLbzlyJGDA", "NT4T3bzg2Kcy3F8EuEDTyQ", "y_sXV7q2KnaeCy-WzG54fw", "43OS4Wqy_dVOt9VrC0CufA", "z7G09QmArnIAAAGusfdMqA", "KtpAFSPqmnUJDPtl2ER_KA", "yL1L01_gz-xtT63A474-qw", "cdyOxiQyyiUhVWeAPgd7jg", "Qvw_KZpSwAsP6-vIycF-Nw", "nckLYnNw1BA6Bdt4MLZJiA", "BjaJWJM1A4cAAAQYWWv-Qw", "NMpc8Tf9lStL3v0zsPbRUA", "Ruh4v3MJ7HQAAAQfDU3OlA", "IfQUtYCsXT0AAAQqargRfw", "_FVxOVvg67PO2p74igUtdQ"]
    
//    let panoIds = ["LS2ysGGsA7qFZwTgByApgA", "6JGJk7avMBL4ENdpV_W3CQ", "oxXGPISsU9Q_sIFiHjICag"]
    
    let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize webview
        webView = UIWebView()
        webView.delegate = self
        let srcString:String! = "<script src=\"https://maps.googleapis.com/maps/api/js?v=3.exp&sensor=true\"></script>>"
        webView.loadHTMLString(srcString, baseURL: nil)
        
        // Initialize panorama viewer
        panoView = GMSPanoramaView()
        panoView.streetNamesHidden = true
        panoView.navigationLinksHidden = true
        panoView.delegate = self
        self.view.addSubview(panoView)
        
        // Set panorama coordinates
//        if (coordinate == nil) {
//           coordinate = CLLocationCoordinate2DMake(37.7737729,-122.408536)
//        }
//        panoView.moveNearCoordinate(coordinate!, radius: 500)
        panoView.moveToPanoramaID(panoIds[panoIds.count - 1])
        
        //TODO: put this in a function/script
//        var panoData = PFObject(className:"PanoData")
//        panoData["latitude"] = coordinate!.latitude
//        panoData["longitude"] = coordinate!.longitude
//        panoData["panoDateDict"] = panoDateDict
//        
//        panoData.saveInBackgroundWithBlock {
//            (success: Bool, error: NSError?) -> Void in
//            if (success) {
//                print("has been saved")
//            } else {
//                print(error?.description)
//            }
//        }
        
        //TEMP: code snippet to fetch from parse - xfz
//        var query = PFQuery(className:"PanoData")
//        query.getObjectInBackgroundWithId("9fNLFJ6q1c") {
//            (panodata: PFObject?, error: NSError?) -> Void in
//            if error == nil && panodata != nil {
//                print(panodata)
//            } else {
//                print(error)
//            }
//        }

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
                        let viewerHeading = self!.viewerYaw + (gx > 0 ? 180 : 0)
                        let viewerPitch = gx * roll - 90
                        self!.panoView.camera = GMSPanoramaCamera(heading: viewerHeading, pitch:viewerPitch, zoom:1)
                    }
                }
            })
        }
        
        // Initialize slider
        sliderView = UISlider()
        sliderView.minimumValue = 0
        sliderView.maximumValue = Float(panoIds.count - 1)
        sliderView.value = sliderView.maximumValue
        sliderView.addTarget(self, action: "sliderValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
        self.view.addSubview(sliderView)
        
        // Initialize back button
        backButton = UIButton(frame: CGRectMake(buttonOffsetX, buttonOffsetY, buttonSideLength, buttonSideLength))
        let backImage = UIImage(named:"backIcon")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        backButton.setImage(backImage, forState: UIControlState.Normal)
        backButton.addTarget(self, action: "backButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(backButton)
        
        // Initialize date label
        dateLabel = UILabel(frame: CGRectMake(150, dateLabelOffsetY, 120, 50))
        dateLabel.backgroundColor = UIColor.blackColor()
        dateLabel.alpha = 0
        dateLabel.layer.cornerRadius = 3
        dateLabel.clipsToBounds = true
        dateLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 24)
        dateLabel.textAlignment = NSTextAlignment.Center
        dateLabel.textColor = UIColor.whiteColor()
        self.view.addSubview(dateLabel)
    }

    override func viewWillLayoutSubviews() {
        // Layout panorama viewer
        panoView.frame = self.view.bounds
        
        // Layout slider
        sliderView.frame = CGRectMake(CGRectGetMinX(self.view.bounds) + sliderOffsetX, CGRectGetMaxY(self.view.bounds) - sliderOffsetY,
            self.view.bounds.width - 2 * sliderOffsetX, sliderHeight)
        
        // Layout date label
        dateLabel.frame = CGRectMake((self.view.bounds.width - dateLabel.bounds.width)/2, dateLabelOffsetY, dateLabel.bounds.width, dateLabel.bounds.height)
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
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
            if (context != nil) {
                let scriptString = "sv.getPanorama({pano: '\(panoIds[curIdx])'}, processSVData);"
                context.evaluateScript(scriptString)
            }
        }
    }
}

extension PanoViewController: UIWebViewDelegate {
    func webViewDidFinishLoad(webView: UIWebView) {
        // Get Javascript context from webview
        context = webView.valueForKeyPath("documentView.webView.mainFrame.javaScriptContext") as! JSContext
        
        // Output any javascript exceptions as they occur
        context!.exceptionHandler = { context, exception in
            print("JS Error: \(exception)")
        }
        
        // Setup a callback function for javascript to call after fetching panorama date
        let updateDateLabel: @convention(block) String -> () = { inputString in
            self.dateLabel.text = self.getDateLabelString(inputString)
            if (self.dateLabel.alpha == 0) {
                UIView.animateWithDuration(0.5) {
                    self.dateLabel.alpha = 0.7
                }
            }
        }
        context.setObject(unsafeBitCast(updateDateLabel, AnyObject.self), forKeyedSubscript: "updateDateLabel")
        
        // Set up a callback function in javascript that calls the above callback function
        let funcString = "function processSVData(data, status) {  if (status === google.maps.StreetViewStatus.OK) { updateDateLabel(data.imageDate) } }"
        context.evaluateScript(funcString)
        
        // Initialize an instance of StreetViewService
        context.evaluateScript("var sv = new google.maps.StreetViewService();")
        
        let curPanoID = panoView.panorama.panoramaID
        let scriptString = "sv.getPanorama({pano: '\(curPanoID)'}, processSVData);"
        context.evaluateScript(scriptString)
    }
    
    func backButtonTapped() -> () {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func getDateLabelString(oldString: String) -> String {
        let dateComponents = oldString.characters.split{$0 == "-"}.map(String.init)
        let yearString = dateComponents[0]
        let monthString = months[Int(dateComponents[1])! - 1]
        return monthString + " " + yearString
    }
}

extension PanoViewController: GMSPanoramaViewDelegate {
    func panoramaView(view: GMSPanoramaView!, willMoveToPanoramaID panoramaID: String!) {
        if (context != nil) {
            let scriptString = "sv.getPanorama({pano: '\(panoramaID)'}, processSVData);"
            context.evaluateScript(scriptString)
        }
    }
    
    func panoramaView(view: GMSPanoramaView!, error: NSError!, onMoveToPanoramaID panoramaID: String!) {
        if (context != nil) {
            let scriptString = "sv.getPanorama({pano: '\(panoramaID)'}, processSVData);"
            context.evaluateScript(scriptString)
        }
    }
    
    func panoramaView(view: GMSPanoramaView!, error: NSError!, didMoveToPanoramaID panoramaID: String!) {
        if (context != nil) {
            let scriptString = "sv.getPanorama({pano: '\(panoramaID)'}, processSVData);"
            context.evaluateScript(scriptString)
        }
    }
}
