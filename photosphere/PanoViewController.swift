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
    let buttonSideLength: CGFloat = 40
    
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
    var coordinate: CLLocationCoordinate2D? {
        didSet {
            let query = PFQuery(className:"PanoData")
            query.whereKey("latitude", equalTo: coordinate!.latitude)
            query.whereKey("longitude", equalTo: coordinate!.longitude)
            query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
                if error == nil {
                    self.dateLabel.alpha = 0
                    if let entry = objects?.first as PFObject! {
                        self.panoIds = entry["panoIds"] as! [String]
                        self.curPanoIdx = self.panoIds.count - 1
                        self.panoView.navigationLinksHidden = true
                        self.panoView.navigationGestures = false
                        self.panoView.moveToPanoramaID(self.panoIds[self.curPanoIdx])
                        
                        self.sliderView.hidden = false
                        self.sliderView.maximumValue = Float(self.panoIds.count - 1)
                        self.sliderView.value = self.sliderView.maximumValue
                        
                        if (self.context != nil) {
                            let scriptString = "sv.getPanorama({pano: '\(self.panoIds[self.curPanoIdx])'}, processSVData);"
                            self.context.evaluateScript(scriptString)
                        }
                    } else {
                        self.sliderView.hidden = true
                        
                        self.panoIds = []
                        self.panoView.navigationLinksHidden = false
                        self.panoView.navigationGestures = true
                        self.panoView.moveNearCoordinate(self.coordinate!, radius: 500)
                        
                        if (self.context != nil) {
                            let curPanoID = self.panoView.panorama.panoramaID
                            let scriptString = "sv.getPanorama({pano: '\(curPanoID)'}, processSVData);"
                            self.context.evaluateScript(scriptString)
                        }
                    }
                }
            }
        }
    }
    
    /** PanoIDs **/
    var curPanoIdx:Int = 0
    var panoIds:[String]!
    
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
        dateLabel.font = UIFont(name: "HelveticaNeue", size: 18)
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
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [UIInterfaceOrientationMask.LandscapeLeft,UIInterfaceOrientationMask.LandscapeRight]
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
        
        if panoView.panorama != nil {
            let curPanoID = panoView.panorama.panoramaID
            let scriptString = "sv.getPanorama({pano: '\(curPanoID)'}, processSVData);"
            context.evaluateScript(scriptString)
        }
    }
    
    func backButtonTapped() -> () {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func getDateLabelString(oldString: String) -> String {
        if (panoIds.count > 1) {
            let dateComponents = oldString.characters.split{$0 == "-"}.map(String.init)
            let yearString = dateComponents[0]
            let monthString = months[Int(dateComponents[1])! - 1]
            return monthString + " " + yearString
        } else {
            return "May 2008"
        }
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
