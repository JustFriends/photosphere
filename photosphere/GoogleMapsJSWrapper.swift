//
//  GoogleMapsJSWrapper.swift
//  photosphere
//
//  Created by Kenneth Pu on 11/3/15.
//  Copyright © 2015 CodePath. All rights reserved.
//

import UIKit
import JavaScriptCore

class GoogleMapsJSWrapper: NSObject, UIWebViewDelegate {
    static let sharedInstance = GoogleMapsJSWrapper()
    
    private var webView: UIWebView!
    private var context:JSContext!
    private var outString:String = ""
    var isReady: Bool = false
    
    override init() {
        super.init()
        webView = UIWebView()
        webView.delegate = self
        //        let srcString:String! = "<script src=\"https://maps.googleapis.com/maps/api/js?key=AIzaSyAdlMM7vTQO3IHs1kq_wTSkrSXErHa3qP8&signed_in=true\"></script>>"
        let srcString:String! = "<script src=\"https://maps.googleapis.com/maps/api/js?v=3.exp&sensor=true\"></script>>"
        webView.loadHTMLString(srcString, baseURL: nil)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        context = webView.valueForKeyPath("documentView.webView.mainFrame.javaScriptContext") as! JSContext
        context!.exceptionHandler = { context, exception in
            print("JS Error: \(exception)")
        }
        
        let simplifyString: @convention(block) String -> String = { input in
            let mutableString = NSMutableString(string: input) as CFMutableStringRef
            CFStringTransform(mutableString, nil, kCFStringTransformToLatin, Bool(0))
            CFStringTransform(mutableString, nil, kCFStringTransformStripCombiningMarks, Bool(0))
            self.outString = mutableString as String
            return mutableString as String
        }
        context.setObject(unsafeBitCast(simplifyString, AnyObject.self), forKeyedSubscript: "simplifyString")
        context.evaluateScript("var outData = '';")
        let funcString = "function processSVData(data, status) { if (status === google.maps.StreetViewStatus.OK) { outData = simplifyString(data.imageDate); } }"
        context.evaluateScript(funcString)
        context.evaluateScript("var sv = new google.maps.StreetViewService();")
        isReady = true
    }
    
    func getDateStringForPanoId(panoramaID: String!) -> String {
        let scriptString = "sv.getPanorama({pano: '\(panoramaID)'}, processSVData);"
        context.evaluateScript(scriptString)
        let a = context.objectForKeyedSubscript("outData")
        return a.toString()
    }
}