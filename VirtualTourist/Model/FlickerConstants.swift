//
//  FlickerConstants.swift
//  VirtualTourist
//
//  Created by zeyadel3ssal on 5/31/19.
//  Copyright © 2019 zeyadel3ssal. All rights reserved.
//

import Foundation

extension FlickrClient{
    
    //MARK : Constants
    
    struct Constants {
        //MARK : Flicker's URL Constants
        struct Flickr {
            static let APIScheme = "https"
            static let APIHost = "www.flickr.com"
            static let APIPath = "/services/rest"
            //Handling bounding box search
            static let searchBBoxHalfWidth = 1.0
            static let searchBBoxHalfHeight = 1.0
            static let searchLatRange = (-90.0,90.0)
            static let searchLonRange = (-180.0,180.0)
            
        }
        //MARK : KEYS
        struct FlickrParameterKeys {
            static let method = "method"
            static let apiKey = "api_key"
            static let boundingBox = "bbox"
            static let safeSearch = "safe_search"
            static let extras = "extras"
            static let format = "format"
            static let noJSONCallBack = "nojsoncallback"
            static let page = "page"
        }
        
        struct FlickrResponseKeys {
            static let status = "stat"
            static let photos = "photos"
            static let photo = "photo"
            static let title = "title"
            static let mediumURL = "url_m"
            static let pages = "pages"
        }
        
        //MARK : Values
        struct FlickrParameterValues {
            static let method = "flickr.photos.search"
            static let apiKey = "21997cc5cbec56c0a5ba29ff791a1f67"
            static let useSafeSearch = "1"
            static let mediumURL = "url_m"
            static let responseJSONFormat = "json"
            static let disableJSONCallBack = "1"
        }
        
        struct FlickrResponseValue {
            static let okStatus = "ok"
        }
    }
}
