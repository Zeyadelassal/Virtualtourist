//
//  FlickrConvenience.swift
//  VirtualTourist
//
//  Created by zeyadel3ssal on 5/31/19.
//  Copyright © 2019 zeyadel3ssal. All rights reserved.
//

import Foundation
extension FlickrClient{
    
    func getImagesFromFlickr(longitude : Double,latitude : Double,pageNumber:Int16,completionHandlerForGetImages:@escaping(_ result:[DownloadedFlickrImage]?,_ pages:Int16?,_ error:NSError?)->Void){
        print("long:\(longitude),,lat:\(latitude)")
        let methodParameters = [
            Constants.FlickrParameterKeys.method : Constants.FlickrParameterValues.method,
            Constants.FlickrParameterKeys.apiKey : Constants.FlickrParameterValues.apiKey,
            Constants.FlickrParameterKeys.extras : Constants.FlickrParameterValues.mediumURL,
            Constants.FlickrParameterKeys.safeSearch :Constants.FlickrParameterValues.useSafeSearch,
            Constants.FlickrParameterKeys.format : Constants.FlickrParameterValues.responseJSONFormat,
            Constants.FlickrParameterKeys.noJSONCallBack :              Constants.FlickrParameterValues.disableJSONCallBack,
            Constants.FlickrParameterKeys.boundingBox : bbox(longitude:longitude, latitude:latitude),
            Constants.FlickrParameterKeys.page : String(pageNumber)
        ]
        
        let _ = taskForGETMethod( parameters: methodParameters as [String : AnyObject]){(result,error) in
            if let error = error {
                print(error)
                completionHandlerForGetImages(nil,nil,error)
            }else{
                guard let stat = result?[Constants.FlickrResponseKeys.status] as? String , stat == Constants.FlickrResponseValue.okStatus else{
                    print("Flickr API returns an error,see error code and message in:\(String(describing: result))")
                    return
                }
                guard let photosDictionary = result?[Constants.FlickrResponseKeys.photos] as? [String : AnyObject] else{
                    print("Can't find '\(Constants.FlickrResponseKeys.photos)' in \(String(describing: result))")
                    return
                }
                guard let totalPages = photosDictionary[Constants.FlickrResponseKeys.pages] as? Int16 else{
                    print("Can't find '\(Constants.FlickrResponseKeys.pages)' in \(photosDictionary)")
                    return
                }
                guard let photosArray = photosDictionary[Constants.FlickrResponseKeys.photo] as? [[String : AnyObject]] else {
                    print("Can't find '\(Constants.FlickrResponseKeys.photo)' in \(photosDictionary)")
                    return
                }
                let imageURLsString = DownloadedFlickrImage.imageURLsFromResults(photosArray)
                completionHandlerForGetImages(imageURLsString,totalPages,nil)
                }
            }
        }
    
    }

