//
//  FlickrImage.swift
//  VirtualTourist
//
//  Created by zeyadel3ssal on 6/2/19.
//  Copyright © 2019 zeyadel3ssal. All rights reserved.
//

import Foundation

struct DownloadedFlickrImage{
    
    //MARK : properties
    let imageStringURL : String
    
    init(dictionary : [String:AnyObject]) {
        imageStringURL = dictionary[FlickrClient.Constants.FlickrResponseKeys.mediumURL] as! String
    }
    
    static func imageURLsFromResults(_ results:[[String:AnyObject]])->[DownloadedFlickrImage]{
        var flickrImages = [DownloadedFlickrImage]()
        for result in results{
            flickrImages.append(DownloadedFlickrImage(dictionary: result))
        }
        return flickrImages
    }
    
}
