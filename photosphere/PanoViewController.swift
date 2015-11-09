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
    let sliderHeight: CGFloat = 20
    
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
    var dateLabelOffsetY: CGFloat = 30
    var dateLabelWidth: CGFloat = 120
    var dateLabelHeight: CGFloat = 50
    var dateLabelTargetAlpha: CGFloat = 0.7
    var dateLabelAnimateDuration: Double = 0.5
    var dateLabelFadeOutDelay: Double = 2.0
    var dateDispatchCount: Int = 0              // Keep track of in flight dispatches to only fade date label on last dispatch
    let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    
    /** Location Label **/
    var locationLabel: UILabel!
    var locationLabelOffsetY: CGFloat = 10
    var locationLabelWidth: CGFloat = 350
    var locationLabelHeight: CGFloat = 50
    var locationLabelTargetAlpha: CGFloat = 0.7
    var locationLabelAnimateDuration: Double = 0.5
    var locationLabelFadeOutDelay: Double = 2.0
    var locationDispatchCount: Int = 0
    
    /** Core Motion Variables **/
    var motionManager: CMMotionManager!
    let FRAMES_PER_SECOND: Double = 30.0    // How often we update the camera
    let YAW_DIFF_THRESHOLD = 0.21           // Used to account for drift in iPhone sensors
    var lastYaw = 0.0                       // Used to keep track of last known iPhone sensor yaw reading
    var viewerYaw = 0.0                     // Used to keep track of panorama viewer camera yaw value

    /** Lat/Lng Viewer Coordinates **/
    var coordinate: CLLocationCoordinate2D? {
        didSet {
            let searchLocation = PFGeoPoint(latitude: coordinate!.latitude, longitude: coordinate!.longitude)
            let query = PFQuery(className:"PanoData")
            query.whereKey("location", nearGeoPoint: searchLocation, withinMiles: 0.1)
            query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
                if error == nil {
                    self.dateLabel.alpha = 0
                    if let entry = objects?.first as PFObject! {
                        self.panoIds = entry["panoIds"] as! [String]
                        self.curPanoIdx = 0
                        self.panoView.navigationLinksHidden = true
                        self.panoView.navigationGestures = false
                        self.panoView.moveToPanoramaID(self.panoIds[self.curPanoIdx])
                        
                        self.sliderView.hidden = false
                        self.sliderView.maximumValue = Float(self.panoIds.count - 1)
                        self.sliderView.value = self.sliderView.minimumValue
                        
                        if (self.context != nil) {
                            let scriptString = "sv.getPanorama({pano: '\(self.panoIds[self.curPanoIdx])'}, processSVData);"
                            self.context.evaluateScript(scriptString)
                        }
                    } else {
                        self.panoIds = []
                        self.panoView.navigationLinksHidden = false
                        self.panoView.navigationGestures = true
                        self.panoView.moveNearCoordinate(self.coordinate!, radius: 500)
                        
                        self.sliderView.hidden = true
                        
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
        let backImage = UIImage(named:"backIcon-1")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        backButton.setImage(backImage, forState: UIControlState.Normal)
        backButton.addTarget(self, action: "backButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(backButton)
        
        // Initialize date label
        dateLabel = UILabel(frame: CGRectMake(150, dateLabelOffsetY, dateLabelWidth, dateLabelHeight))
        dateLabel.backgroundColor = UIColor.blackColor()
        dateLabel.alpha = 0
        dateLabel.layer.cornerRadius = 4
        dateLabel.clipsToBounds = true
        dateLabel.font = UIFont(name: "HelveticaNeue", size: 18)
        dateLabel.textAlignment = NSTextAlignment.Center
        dateLabel.textColor = UIColor.whiteColor()
        self.view.addSubview(dateLabel)
        
        // Initialize location label
        locationLabel = UILabel(frame: CGRectMake(150, locationLabelOffsetY, locationLabelWidth, locationLabelHeight))
        locationLabel.backgroundColor = UIColor.blackColor()
        locationLabel.alpha = 0
        locationLabel.layer.cornerRadius = 4
        locationLabel.clipsToBounds = true
        locationLabel.font = UIFont(name: "HelveticaNeue", size: 18)
        locationLabel.textAlignment = NSTextAlignment.Center
        locationLabel.textColor = UIColor.whiteColor()
        locationLabel.adjustsFontSizeToFitWidth = true
        self.view.addSubview(locationLabel)
    }

    override func viewWillLayoutSubviews() {
        // Layout panorama viewer
        panoView.frame = self.view.bounds
        
        // Layout slider
        sliderView.frame = CGRectMake(CGRectGetMinX(self.view.bounds) + sliderOffsetX, CGRectGetMaxY(self.view.bounds) - sliderOffsetY,
            self.view.bounds.width - 2 * sliderOffsetX, sliderHeight)
        
        // Layout date label
        dateLabel.frame = CGRectMake((self.view.bounds.width - dateLabel.bounds.width)/2, CGRectGetMaxY(sliderView.frame) - (dateLabel.bounds.height + dateLabelOffsetY), dateLabel.bounds.width, dateLabel.bounds.height)
        
        // Layout location label
        locationLabel.frame = CGRectMake((self.view.bounds.width - locationLabel.bounds.width)/2, locationLabelOffsetY, locationLabel.bounds.width, locationLabel.bounds.height)
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
        
        /** Setup a callback function for javascript to call after fetching panorama date **/
        let updateDateLabel: @convention(block) String -> () = { inputString in
            let dateString = self.getDateLabelString(inputString)
            if (self.dateLabel.text != dateString) {
                dispatch_async(dispatch_get_main_queue()) {
                    // Update date label text, fade in date label if previously hidden
                    self.dateLabel.text = dateString
                    if (self.dateLabel.alpha == 0) {
                        UIView.animateWithDuration(self.dateLabelAnimateDuration) {
                            self.dateLabel.alpha = self.dateLabelTargetAlpha
                        }
                    }
                }
                // Prepare a dispatch_after block, increment counter to keep track of in-flight dispatches
                self.dateDispatchCount += 1
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(self.dateLabelFadeOutDelay * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    // Decrement dispatch counter, fade out date label if we are the last block
                    self.dateDispatchCount -= 1
                    if (self.dateDispatchCount == 0) {
                        UIView.animateWithDuration(self.dateLabelAnimateDuration) {
                            self.dateLabel.alpha = 0
                        }
                    }
                }
            }
        }
        context.setObject(unsafeBitCast(updateDateLabel, AnyObject.self), forKeyedSubscript: "updateDateLabel")
        
        let updateLocationLabel: @convention(block) String -> () = { inputString in
            if (self.locationLabel.text != inputString) {
                dispatch_async(dispatch_get_main_queue()) {
                    // Update date label text, fade in date label if previously hidden
                    self.locationLabel.text = inputString
                    if (self.locationLabel.alpha == 0) {
                        UIView.animateWithDuration(self.locationLabelAnimateDuration) {
                            self.locationLabel.alpha = self.locationLabelTargetAlpha
                        }
                    }
                }
                // Prepare a dispatch_after block, increment counter to keep track of in-flight dispatches
                self.locationDispatchCount += 1
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(self.locationLabelFadeOutDelay * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    // Decrement dispatch counter, fade out date label if we are the last block
                    self.locationDispatchCount -= 1
                    if (self.locationDispatchCount == 0) {
                        UIView.animateWithDuration(self.locationLabelAnimateDuration) {
                            self.locationLabel.alpha = 0
                        }
                    }
                }
            }
        }
        context.setObject(unsafeBitCast(updateLocationLabel, AnyObject.self), forKeyedSubscript: "updateLocationLabel")
        
        // Set up a callback function in javascript that calls the above callback function
        let funcString = "function processSVData(data, status) {  if (status === google.maps.StreetViewStatus.OK) { updateDateLabel(data.imageDate); updateLocationLabel(data.location.description); } }"
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
        let dateComponents = oldString.characters.split{$0 == "-"}.map(String.init)
        if (dateComponents.count == 2) {
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
}
