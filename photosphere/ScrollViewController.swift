//
//  ScrollViewController.swift
//  photosphere
//
//  Created by David Fontenot on 10/25/15.
//  Copyright © 2015 CodePath. All rights reserved.
//
import UIKit
import MapKit
import GoogleMaps
import Parse

class ScrollViewController: UIViewController, UIScrollViewDelegate, MapViewControllerDelegate {
    var scrollView: UIScrollView!
    var pageControl: UIPageControl!
    
    var panoViewController: PanoViewController!
    var mapViewController: MapViewController!
    
    var imageView: UIImageView!
    var mapsButton: UIButton!
    
    var placesClient: GMSPlacesClient?
    var placePicker: GMSPlacePicker?

    var placesArray: [PFObject] = []
    var placesSubviewsArray: [UIImageView] = []

    var coordinate: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.placesArray = []
        
        panoViewController = PanoViewController()
        mapViewController = MapViewController()
        mapViewController.delegate = self

        self.scrollView = UIScrollView(frame: view.bounds)
        view.addSubview(self.scrollView)

        self.pageControl = UIPageControl()
        view.addSubview(pageControl)

        self.mapsButton = UIButton(type:UIButtonType.System) as UIButton
        self.view.addSubview(self.mapsButton)

        placesClient = GMSPlacesClient()

        let query = PFQuery(className:"PanoData")
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in

            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects as [PFObject]! {
                    for object in objects {
                        //print(object.objectId)
                        //let lat = object["latitude"]
                        //print("latitude: \(lat)")
                        self.placesArray.append(object)
                        //print("loaded data into places array")
                        //print(self.placesArray)

                    }
                    if (self.placesArray.count == objects.count) {
                        self.setupScrollView()
                        self.setupPageControl()
                        self.setupMapsButton()
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }

    }

    func requestLocation (lat:CLLocationDegrees, long:CLLocationDegrees) {
//        placesClient?.currentPlaceWithCallback({ (placeLikelihoodList: GMSPlaceLikelihoodList?, error: NSError?) -> Void in
//            if let error = error {
//                print("Pick Place error: \(error.localizedDescription)")
//                return
//            }
//
//            if let placeLicklihoodList = placeLikelihoodList {
//                let place = placeLicklihoodList.likelihoods.first?.place
//                if let place = place {
//                    print(place.name)
//                    print(place.formattedAddress)
//                }
//            }
//        })
        let center = CLLocationCoordinate2DMake(lat, long)
        let northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001)
        let southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001)
        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        let config = GMSPlacePickerConfig(viewport: viewport)
        placePicker = GMSPlacePicker(config: config)

        placePicker?.pickPlaceWithCallback({ (place: GMSPlace?, error: NSError?) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }

            if let place = place {
                print("Place name \(place.name)")
                print("Place address \(place.formattedAddress)")
                print("Place attributions \(place.attributions)")
                print("Place coordinates \(place.coordinate)")
                self.coordinate = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude)
                if self.coordinate != nil {
                    self.panoViewController.coordinate = self.coordinate
                } else {
                    self.panoViewController.coordinate = CLLocationCoordinate2DMake(40.71288,-74.0140183)
                }
                self.presentViewController(self.panoViewController, animated: true, completion: nil)
            } else {
                print("No place selected")
            }
        })
    }

    override func viewWillLayoutSubviews() {
        setupScrollView()
        setupPageControl()
        setupMapsButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func pageControlDidPage(sender: AnyObject) {
        let xOffset = scrollView.bounds.width * CGFloat(pageControl.currentPage)
        scrollView.setContentOffset(CGPointMake(xOffset,0) , animated: true)
    }

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.bounds.width)
    }
    
    func mapViewController(mapViewcontroller: MapViewController!, didDismissWithCoordinate coordinate: CLLocationCoordinate2D) {
        print("delegate called \(coordinate)")
    }

    func setupScrollView() {
        //print("setting up scroll view")
        //print(self.placesArray)
        scrollView.frame = self.view.bounds
        //print(scrollView.frame)

        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        
        let pageWidth = view.bounds.width
        let pageHeight = view.bounds.height

        for subview in scrollView.subviews {
            subview.removeFromSuperview()
        }
        
        if (self.placesArray.count == 0) {
            //print("nil places array")
            //let view1 = UIView(frame: CGRectMake(0, 0, pageWidth, pageHeight))
            let view1 = UIImageView(frame: CGRectMake(0, 0, pageWidth, pageHeight))

            let urlString = "https://maps.googleapis.com/maps/api/streetview?location=37.7737729,-122.408536&size=\(Int(pageWidth))x\(Int(pageHeight))"
            //print(urlString)
            view1.setImageWithURL(NSURL(string: urlString)!)
            //view1.setImageWithURL(NSURL(string: "https://maps.googleapis.com/maps/api/streetview?location=37.7737729,-122.408536&size=375x667")!)

            //view1.backgroundColor = UIColor(patternImage: UIImage(named: "8th&Harrison")!)
            //view1.backgroundColor = UIColor.blueColor()

            let view2 = UIView(frame: CGRectMake(pageWidth, 0, pageWidth, pageHeight))
            view2.backgroundColor = UIColor.orangeColor()
            let view3 = UIView(frame: CGRectMake(2*pageWidth, 0, pageWidth, pageHeight))
            view3.backgroundColor = UIColor.purpleColor()

            scrollView.addSubview(view1)
            scrollView.addSubview(view2)
            scrollView.addSubview(view3)
        } else {
            //print("places array is non nil")
            for (var i = 0; i < self.placesArray.count; i++) {
                let object = self.placesArray[i]
                //print(object)
                //print(object)
                let location = object["location"] as! PFGeoPoint
                let view = UIImageView(frame: CGRectMake(CGFloat(i)*pageWidth, 0, pageWidth, pageHeight))
                if (object.objectForKey("previewImageURL") != nil) {
                    view.setImageWithURL(NSURL(string: object["previewImageURL"] as! String)!)
                } else {
                    view.setImageWithURL(NSURL(string: "https://maps.googleapis.com/maps/api/streetview?location=\(location.latitude),\(location.longitude)&size=\(Int(pageWidth))x\(Int(pageHeight))")!)
                }

                //print(urlString)

                scrollView.addSubview(view)
                addLabelToImageView(object["description"] as! String, imageView: view)
            }
        }

        for subview in scrollView.subviews {
            addGestureRecognizerToPage(subview)
        }

        scrollView.contentSize = CGSizeMake(CGFloat(self.scrollView.subviews.count)*scrollView.frame.width, scrollView.frame.height)

        scrollView.delegate = self
    }

    func setupPageControl() {
        //**should set numberOfPages dynamically
        if self.placesArray.count == 0 {
            pageControl.numberOfPages = 3
        } else {
            pageControl.numberOfPages = placesArray.count
        }

        let size = CGFloat(45)
        let screenWidth = self.view.frame.size.width
        pageControl.frame = CGRectMake((screenWidth / 2) - (size / 2), UIScreen.mainScreen().bounds.height-75, size, size)
        pageControl.addTarget(self, action: "pageControlDidPage:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func setupMapsButton() {
        //create button
        let screenWidth = self.view.frame.size.width
        let size = CGFloat(60)
        let frame = CGRectMake(screenWidth - size, 0, size, size)
        mapsButton.frame = frame
        
        //add image
        let image = UIImage(named: "maps-icon") as UIImage?

        mapsButton.setImage(image, forState: .Normal)
        
        //add button to subview

        mapsButton.translatesAutoresizingMaskIntoConstraints = false
        
        addGestureRecognizerToMapsButton()
    }
    
    func addLabelToImageView(string: String, imageView: UIImageView) {
        let size = CGFloat(250)
        let screenWidth = self.view.frame.size.width
        let frame = CGRectMake((0), UIScreen.mainScreen().bounds.height-65, screenWidth, 65)

        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        visualEffectView.frame = frame
        imageView.addSubview(visualEffectView)

        let label = UILabel(frame: visualEffectView.contentView.bounds)
        label.text = string
        label.textColor = UIColor(white: 1, alpha: 1)
        label.textAlignment = .Center
        label.font = UIFont(name: "HelveticaNeue", size: 20)
        visualEffectView.contentView.addSubview(label)
    }

    func addGestureRecognizerToMapsButton() {
        let tap = UITapGestureRecognizer(target: self, action: "tapMapsButton:")
        tap.numberOfTapsRequired = 1
        mapsButton.addGestureRecognizer(tap)
    }
    
    func tapMapsButton(recognizer: UITapGestureRecognizer) {
        requestLocation(38.8977,long: -77.0366)
        //requestLocation(40.71288,long:-74.0140183)
        //print("tapped map")
        //get coordinates from page clicked here
        //print(recognizer.view?.backgroundColor)
        //self.mapViewController.coordinate = CLLocationCoordinate2DMake(40.71288,-74.0140183)
        //self.presentViewController(mapViewController, animated: true, completion: nil)
    }
    
    // MARK: - Gesture Recognizer
//    func setupGestureRecognizer() {
//        let tap = UITapGestureRecognizer(target: self, action: "handleTap:")
//        tap.numberOfTapsRequired = 1
//        scrollView.addGestureRecognizer(tap)
//    }

    func addGestureRecognizerToPage(page:UIView) {
        let tap = UITapGestureRecognizer(target: self, action: "handleTap:")
        tap.numberOfTapsRequired = 1
        page.userInteractionEnabled = true
        page.addGestureRecognizer(tap)
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        //print("current page \(pageControl.currentPage)")
        if self.placesArray.count != 0 {
            let place = self.placesArray[pageControl.currentPage]
            let location = place["location"] as! PFGeoPoint
            //print(place)
            self.coordinate = CLLocationCoordinate2DMake(location.latitude as! CLLocationDegrees, location.longitude as! CLLocationDegrees)
        }
        //print("tapped")
        //get coordinates from page clicked here
        //print(recognizer.view?.backgroundColor)
        //pass in a CLLocationCoordinate2D
        if self.coordinate != nil {
            self.panoViewController.coordinate = self.coordinate
        } else {
            self.panoViewController.coordinate = CLLocationCoordinate2DMake(40.71288,-74.0140183)
        }
        self.presentViewController(self.panoViewController, animated: true, completion: nil)
    }
    
    // MARK: - Zooming: http://www.appcoda.com/uiscrollview-introduction/
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func setZoomScale() {
        let imageViewSize = imageView.bounds.size
        let scrollViewSize = scrollView.bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height
        
        scrollView.minimumZoomScale = min(widthScale, heightScale)
        scrollView.zoomScale = 1.0
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [UIInterfaceOrientationMask.LandscapeLeft,UIInterfaceOrientationMask.LandscapeRight]
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "segueToMap") {

        } else if (segue.identifier == "segueToPano") {

        }
    }


}
