//
//  Independent.swift
//  MiniFlickrApp
//
//  Created by Tanoi Tanwi on 4/8/16.
//  Copyright © 2016 Tanoi Tanwi. All rights reserved.
//

//import Foundation
import UIKit

protocol IndyDelegate
{
    func dismissImage()
}

class Indy : UIScrollView //NSObject
{
    func createScrollView(itsRect :CGRect,
//                          itsDelegate  theDelegate  :IndyDelegate,
                          inView       parentView   :UIView?,
                          bckndColor   bckColor     :UIColor,
                          offScreen    hideIt       :Int) -> UIScrollView
    {
        
        var viewRect = itsRect
        
        if (hideIt < 0)
        {
            viewRect.origin.x -= viewRect.size.width;		//Place it ON LEFT side
        } else if (hideIt == 1) {
            viewRect.origin.x += viewRect.size.width;		//Place it on RIGHT side
        }
        
        let theScrollLayer = UIScrollView (frame: viewRect)
        
        if(hideIt == 2) {
            theScrollLayer.hidden = true; //Hide it and the caller will unhide it
        }
        
        theScrollLayer.canCancelContentTouches = false
        theScrollLayer.clipsToBounds = true
//        theScrollView!.delegate = self.dismissImage()
        
        theScrollLayer.alwaysBounceVertical = true
        theScrollLayer.backgroundColor = bckColor
        
        if(parentView != nil) {
            parentView!.addSubview(theScrollLayer)
        }
        
        return theScrollLayer
    }

//++++ This method gets called when the + button or the image in the news detail view is tapped ++++
//    func showPhoto(theImage:UIImage?, inView parentView:UIView, withDelegate delegate:IndyDelegate, handledBy handler:Selector ) -> Bool
    func showPhoto(theImage:UIImage?, inView parentView:UIView) -> UIScrollView?
    {
        if (theImage == nil) {
            return nil
        }
        
        var theViewRect = parentView.frame;
        
        if(theViewRect.origin.y == 0.0) {	//in iOS 7, the statusbar is no longer excluded from view usage.
            theViewRect = CGRectMake(theViewRect.origin.x, theViewRect.origin.y+20.0, theViewRect.size.width, theViewRect.size.height);
        }
        
//        let imSize = theImage!.size;
//        [self performSelector(selector(toggleVersion:)), withObject:null afterDelay:15.0f];//Objective C version
       
        //Now first create black view on top
//        var theScrollView : UIScrollView? = nil

        let theScrollView = self.createScrollView(theViewRect,
//                                        itsDelegate:delegate,
                                        inView:nil,
                                        bckndColor:UIColor.blackColor(), 	//bckndColor:[UIColor clearColor]
                                        offScreen:0)						//-1:Place on Left, 0:Do nothing, 1:Placee on Right 2:Just hide it
//        theScrollView!.tag = 79;
        theScrollView.contentOffset = CGPointMake(0.0, 0.0)
        theScrollView.contentSize = theImage!.size
        
        //Now create a UIImageView to display the image in
        let theImageView = UIImageView(image: theImage)
        let xZero = (parentView.frame.size.width - (theImage?.size.width)!)/2.0
        let yZero = (parentView.frame.size.height - (theImage?.size.height)!)/2.0
        theImageView.frame = CGRectMake(xZero, yZero, theImage!.size.width, theImage!.size.height); //Made the difference!
        
        theImageView.userInteractionEnabled = true	//So user taps can be accepted
        theScrollView.addSubview(theImageView)
        
//        if(label != nil)
//        [CreateLabel createLabel:CGRectMake(8,8,208,32)
//        parentView:theImageView
//        labelText:label //@"Tap image to close"
//        fontSize:24
//        textColor:[UIColor whiteColor]
//        bgndColor:[UIColor blackColor]
//        labelTag:99];
        
        //Add a single tap Gesture to the picture
//        let theTaps = UITapGestureRecognizer(target:self, action: #selector(self.dismissImage))
//        theTaps.numberOfTapsRequired = 1	//Number of taps required
//        theImageView.addGestureRecognizer(theTaps) //++++ Now add the single tap gesture to the image ++++
        
        parentView.addSubview(theScrollView)
        
        return theScrollView
    }
    
/* This medthod not called, so I moved it to the caller
    func dismissImage()
    {
        print("dismissImage")
       theScrollView!.removeFromSuperview() //Remove also releases
    }
*/
    
}
