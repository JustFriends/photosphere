//
//  ScrollViewController.swift
//  photosphere
//
//  Created by David Fontenot on 10/25/15.
//  Copyright © 2015 CodePath. All rights reserved.
//

import UIKit

class ScrollViewController: UIViewController, UIScrollViewDelegate {
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    var pageControl: UIPageControl!
    var panoViewController: PanoViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        panoViewController = PanoViewController()
        
        scrollView = UIScrollView(frame: view.bounds)
        
        let contentWidth = scrollView.bounds.width
        let contentHeight = scrollView.bounds.height * 3
        scrollView.contentSize = CGSizeMake(contentWidth, contentHeight)
        
        view.addSubview(scrollView)
        
        self.pageControl = UIPageControl()
        
        view.addSubview(pageControl)
        
        let pageWidth = scrollView.bounds.width
        let pageHeight = scrollView.bounds.height
        
        scrollView.contentSize = CGSizeMake(3*pageWidth, pageHeight)
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        
        let view1 = UIView(frame: CGRectMake(0, 0, pageWidth, pageHeight))
        view1.backgroundColor = UIColor.blueColor()
        let view2 = UIView(frame: CGRectMake(pageWidth, 0, pageWidth, pageHeight))
        view2.backgroundColor = UIColor.orangeColor()
        let view3 = UIView(frame: CGRectMake(2*pageWidth, 0, pageWidth, pageHeight))
        view3.backgroundColor = UIColor.purpleColor()
        
        scrollView.addSubview(view1)
        scrollView.addSubview(view2)
        scrollView.addSubview(view3)
        
        scrollView.delegate = self
        
        pageControl.numberOfPages = 3
        
        pageControl.addTarget(self, action: "pageControlDidPage:", forControlEvents: UIControlEvents.ValueChanged)
        
        setupGestureRecognizer()
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
    
    // MARK: - Gesture Recognizer
    func setupGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: "handleTap:")
        tap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(tap)
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        print("tapped")
        self.presentViewController(panoViewController, animated: true, completion: nil)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
