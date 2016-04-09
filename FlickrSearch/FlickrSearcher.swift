//
//  FlickrSearcher.swift
//  MiniFlickrApp
//
//  Created by Richard Turton on 31/07/2014.
//  Copyright (c) 2014 Razeware. All rights reserved.
//
//  Modified by Tanoi Tanwi on 04/07/16 to use in the MiniTestApp

import Foundation
import UIKit

let apiKey = "acb2a3a4feba9600ca8eb85f0a9beb06"

struct FlickrSearchResults {
  let searchTerm    : String
  let searchResults : [FlickrPhoto]
}

class FlickrPhoto : Equatable
{
  var thumbnail  : UIImage?
  var largeImage : UIImage?
  let photoID    : String
  let farm       : Int
  let server     : String
  let secret     : String
  
  init (photoID:String,farm:Int, server:String, secret:String)
  {
    self.photoID = photoID
    self.farm = farm
    self.server = server
    self.secret = secret
  }
  
  func flickrImageURL(size:String = "m") -> NSURL
  {
    return NSURL(string: "https://farm\(farm).staticflickr.com/\(server)/\(photoID)_\(secret)_\(size).jpg")!
  }
  
  func loadLargeImage(completion: (flickrPhoto:FlickrPhoto, error: NSError?) -> Void)
  {
    let loadURL = flickrImageURL("b")
    let loadRequest = NSURLRequest(URL:loadURL)
    NSURLConnection.sendAsynchronousRequest(loadRequest,
      queue: NSOperationQueue.mainQueue()) {
        response, data, error in
        
        if error != nil {
          completion(flickrPhoto: self, error: error)
          return
        }
        
        if data != nil
        {
          let returnedImage = UIImage(data: data!)
          self.largeImage = returnedImage
          completion(flickrPhoto: self, error: nil)
          return
        }
        
        completion(flickrPhoto: self, error: nil)
    }
  }
  

  func sizeToFillWidthOfSize(size:CGSize) -> CGSize
  {
    if thumbnail == nil {
      return size
    }
    
    let imageSize = thumbnail!.size
    var returnSize = size
    
    let aspectRatio = imageSize.width / imageSize.height
    
    returnSize.height = returnSize.width / aspectRatio
    
    if returnSize.height > size.height {
      returnSize.height = size.height
      returnSize.width = size.height * aspectRatio
    }
    
    return returnSize
  }
}

    
func == (lhs: FlickrPhoto, rhs: FlickrPhoto) -> Bool {
  return lhs.photoID == rhs.photoID
}

class Flickr
{
  let processingQueue = NSOperationQueue()
  
  func searchFlickrForTerm(searchTerm: String, completion : (results: FlickrSearchResults?, error : NSError?) -> Void)
  {
    let searchURL = flickrSearchURLForSearchTerm(searchTerm)
    let searchRequest = NSURLRequest(URL: searchURL)
    NSURLConnection.sendAsynchronousRequest(searchRequest, queue: processingQueue) {response, data, error in
      if error != nil {
        completion(results: nil,error: error)
        return
      }
      
      var JSONError : NSError?
        
        
       let resultsDictionary = try! NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions(rawValue: 0)) as? NSDictionary
        
      if JSONError != nil {
        completion(results: nil, error: JSONError)
        return
      }
      
      switch (resultsDictionary!["stat"] as! String)
      {
          case "ok":
            print("Results processed OK")
        
          case "fail":
            let APIError = NSError(domain: "FlickrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:resultsDictionary!["message"]!])
            completion(results: nil, error: APIError)
            return
        
          default:
            let APIError = NSError(domain: "FlickrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Uknown API response"])
            completion(results: nil, error: APIError)
            return
      }
      
      let photosContainer = resultsDictionary!["photos"] as! NSDictionary
      let photosReceived = photosContainer["photo"] as! [NSDictionary]
      
      let flickrPhotos : [FlickrPhoto] = photosReceived.map {
        photoDictionary in
        
        let photoID = photoDictionary["id"] as? String ?? ""
        let farm = photoDictionary["farm"] as? Int ?? 0
        let server = photoDictionary["server"] as? String ?? ""
        let secret = photoDictionary["secret"] as? String ?? ""
        
        let flickrPhoto = FlickrPhoto(photoID: photoID, farm: farm, server: server, secret: secret)
        
        let imageData = NSData(contentsOfURL: flickrPhoto.flickrImageURL())
        flickrPhoto.thumbnail  = UIImage(data: imageData!)
        
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// All in this block to try and get the largeImage
        var size = flickrPhoto.thumbnail?.size
        if (size != nil) {
            print(String(format:"searchFlickrForTerm: thumbnail size (%.2f, %.2f",(size?.width)!,(size?.height)!))
        }
        
        let largeImageData = NSData(contentsOfURL: flickrPhoto.flickrImageURL("b"))
        
//        print("searchFlickrTerm:largeImageData is \(largeImageData)")
        
        flickrPhoto.largeImage = UIImage(data: largeImageData!) //Will this give me the large image too?
        size = flickrPhoto.largeImage?.size
        if (size != nil) {
            print(String(format:"searchFlickrForTerm: largeImage size (%.2f, %.2f",(size?.width)!,(size?.height)!))
        }
// End of largeImage attempts **************
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        
        return flickrPhoto
      }
      
      dispatch_async(dispatch_get_main_queue(), {
        completion(results:FlickrSearchResults(searchTerm: searchTerm, searchResults: flickrPhotos), error: nil)
      })
    }
  }
  
  private func flickrSearchURLForSearchTerm(searchTerm:String) -> NSURL {
    
    //let escapedSearchTerm = searchTerm.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLPathAllowedCharacterSet())
    
    let escapedTerm = searchTerm.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
    let URLString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&text=\(escapedTerm)&per_page=20&format=json&nojsoncallback=1"
    return NSURL(string: URLString)!
  }
  
  
}
