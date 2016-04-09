//
//  FlickrPhotosViewController.swift
//  FlickrSearch
//
//  Created by Richard Turton on 13/04/2015.
//  Copyright (c) 2015 Richard turton. All rights reserved.
//
//  Modified by Tanoi Tanwi on 04/07/16 to use in the MiniTestApp

import UIKit

// MARK: - **** Flickr API Related ****
class FlickrPhotosViewController: UICollectionViewController  {
  
    private let reuseIdentifier = "FlickrCell"
    private let sectionInsets = UIEdgeInsets(top:4.0, left:2.0, bottom:4.0, right:2.0)
//    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)

    private var searches = [FlickrSearchResults]()
    private let flickr = Flickr()
    var singleTap : UITapGestureRecognizer? //(target:self, action: #selector(FlickrPhotosViewController.processSingleTap(_:)) )
    var deviceIsiPhone :Bool = false
    
    var thebigPictureView : UIScrollView? = nil
    
  func photoForIndexPath(indexPath: NSIndexPath) -> FlickrPhoto {
    return searches[indexPath.section].searchResults[indexPath.row]
  }

    func dismissImage()
    {
        print("dismissImage")
        thebigPictureView!.removeFromSuperview() //Remove also releases
    }

//    class displayLargeImage(flickrPhoto:FlickrPhoto, error: NSError?) -> Void
//    {
//    }
    
    // MARK: - **** Added to support taps on Thumbnails ****
     override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath:NSIndexPath)
    {
//        let largeImageData = NSData(contentsOfURL: flickrPhoto.loadLargeImage(displayLargeImage)

        let flickrPhoto = photoForIndexPath(indexPath)
        let fullSizedImage = flickrPhoto.largeImage
        if (fullSizedImage != nil)
        {
            let size = fullSizedImage!.size
            print(String(format:"didSelectItemAtIndexPath: fullSizedImage size (%.2f, %.2f",(size.width),(size.height)))

            print("didSelectItemAtIndexPath: image #\(indexPath.row) selected")
            print("didSelectItemAtIndexPath: photoID = \(flickrPhoto.photoID)")
            print("didSelectItemAtIndexPath: farm    = \(flickrPhoto.farm)")
            print("didSelectItemAtIndexPath: server  = \(flickrPhoto.server)")
            print("didSelectItemAtIndexPath: secret  = \(flickrPhoto.secret)")
            
            thebigPictureView = Indy().showPhoto(fullSizedImage, inView:self.view)

            if thebigPictureView != nil
            {                
                //Add a single tap Gesture to the picture scroll view to remove the view from its super
                let theTaps = UITapGestureRecognizer(target:self, action: #selector(dismissImage))
                theTaps.numberOfTapsRequired = 1                    //Just 1 tap required
                thebigPictureView!.addGestureRecognizer(theTaps)    //Now add the single tap gesture to the image view
            }

        }
    }

/*
// Wrote this UITapGestureRecognizer because above hadn't been added at first
   func processSingleTap(sender:UITapGestureRecognizer)
    {
        
        if (sender.state == .Ended )
        {
            let point :CGPoint  = sender.locationInView(collectionView)
            let indexPath = collectionView!.indexPathForItemAtPoint(point)
            
            if (indexPath != nil)
            {
                let flickrPhoto = photoForIndexPath(indexPath!)
                let fullSizedImage = flickrPhoto.largeImage
                if (fullSizedImage != nil) {
                    let size = fullSizedImage?.size
                    print("processSingleTap: Will display image with size (%.2f, %.2f",size?.width,size?.height)
                }
            }
            else
            {
                print("processSingleTap: indexPath is nil");
            }
        }
    }
*/
    
    // MARK: - **** App UIView Delegates added to support UITapGestureRecognizer ****
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        deviceIsiPhone = (UIDevice.currentDevice().userInterfaceIdiom == .Phone)
        print("viewDidLoad");

        //++++ Add a gesture recognizer to the view ++++ Disabled because didSelectItemAtIndexPath has been implemented
//        singleTap = UITapGestureRecognizer(target:self, action: #selector(FlickrPhotosViewController.processSingleTap(_:)) )
    
////        singleTap.delegate = self //Compiler won't allow this!!
//        singleTap!.numberOfTapsRequired = 1        //This doesn't make any difference
//        self.view.userInteractionEnabled = true   //This too not making any difference
//        self.view.addGestureRecognizer(singleTap!)
    }

//extension FlickrPhotosViewController : UICollectionViewDataSource {
  
    //MARK:- UICollectionViewController DataSource
  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return searches.count
  }
  
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return searches[section].searchResults.count
  }
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FlickrPhotoCell

    let flickrPhoto = photoForIndexPath(indexPath)
    cell.backgroundColor = UIColor.blackColor()
    cell.imageView.image = flickrPhoto.thumbnail
    
//    cell.imageView.addGestureRecognizer(singleTap!) //Allow user to tap on image thumb nail

    return cell
  }

}

// MARK: - **** Extended UITextField Delegate
extension FlickrPhotosViewController : UITextFieldDelegate
{
    
  func textFieldShouldReturn(textField: UITextField) -> Bool
  {
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    textField.addSubview(activityIndicator)
    activityIndicator.frame = textField.bounds
    activityIndicator.startAnimating()
    
    flickr.searchFlickrForTerm(textField.text!)
    {
      results, error in
      
      activityIndicator.removeFromSuperview()
      if error != nil {
        print("Error searching : \(error)")
      }
      
      if results != nil
      {
        print("Found \(results!.searchResults.count) matching \(results!.searchTerm)")
        self.searches.insert(results!, atIndex: 0)
        self.collectionView?.reloadData()
      }
    }
    
    textField.text = nil
    textField.resignFirstResponder()
    return true
  }
}

//MARK:- UICollectionViewController DelegateFlowLayout

extension FlickrPhotosViewController : UICollectionViewDelegateFlowLayout {
  
  func collectionView(collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
      
    let flickrPhoto =  photoForIndexPath(indexPath)
  
     if var size = flickrPhoto.thumbnail?.size
      {
        //Scale the the image to half its size,so we can get more thumb nails on the small display
        if deviceIsiPhone {
            size.width  *= 0.50
            size.height *= 0.50
        } else {
            size.width  += 8
            size.height += 8
        }
        return size
      } else {
            var size:CGSize
            if deviceIsiPhone {
                size = CGSize(width: 48, height: 48)
            } else {
                size = CGSize(width: 80, height: 80)
            }
            return size
       }
    
  }
  
  
  func collectionView(collectionView: UICollectionView,ayout collectionViewLayout:
    UICollectionViewLayout,insetForSectionAtIndex section: Int) -> UIEdgeInsets
  {
    
      return sectionInsets
  }
}
