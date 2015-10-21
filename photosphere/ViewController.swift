//
//  ViewController.swift
//  photosphere
//
//  Created by Kenneth Pu on 10/20/15.
//  Copyright © 2015 Kenneth Pu. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let panoramaNear = CLLocationCoordinate2DMake(37.7737729, -122.408536)
        let panoView = GMSPanoramaView.panoramaWithFrame(CGRectZero, nearCoordinate:panoramaNear)
        panoView.streetNamesHidden = true
        panoView.navigationGestures = false
        self.view = panoView
        
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

