//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by zeyadel3ssal on 5/31/19.
//  Copyright © 2019 zeyadel3ssal. All rights reserved.
//

import Foundation

class FlickrClient : NSObject{
    
    //Shared session
    var session = URLSession.shared
    
    //MARK : GET
    func taskForGETMethod(parameters : [String:AnyObject],completionHndlerForGETMethod: @escaping (_ result:AnyObject?,_ error:NSError?)->Void) -> URLSessionTask{
        //Build the url
        let request = URLRequest(url: flickURLFromParameters(parameters: parameters))
        print(request)
        //Start request
        let task = session.dataTask(with: request){(data,response,error) in
            //Display error
            func sendError(_ error:String){
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHndlerForGETMethod(nil,NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            //Was there an error
            guard error == nil else {
                sendError("There error with your request:\(String(describing: error))")
                return
            }
            //Did we get a successful response
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode,statusCode >= 200 && statusCode <= 299 else {
                sendError("Request returns with status code other than 2xx")
                return
            }
            //Any data returned with request
            guard let data = data else {
                sendError("No data returned with your data")
                return
            }
            //Parse JSON data
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHndlerForGETMethod)
        }
        task.resume()
        return task
        
    }
    
    //Parse JSON data to a useable foundation object
    func convertDataWithCompletionHandler(_ data : Data,completionHandlerForConvertData : @escaping(_ result:AnyObject?,_ error:NSError?)->Void){
        
        var parsedData : AnyObject! = nil
        do{
            parsedData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        }catch{
            let userInfo = [NSLocalizedDescriptionKey : "Can't parse data as JSON:\(data)"]
            completionHandlerForConvertData(nil,NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        completionHandlerForConvertData(parsedData,nil)
    }
    
    func flickURLFromParameters(parameters : [String:AnyObject])->URL{
        
        var components = URLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key,value) in parameters{
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems?.append(queryItem)
        }
        return components.url!
    }
    
    func bbox(longitude : Double,latitude : Double)->String{
        let minLongitude = max(longitude-Constants.Flickr.searchBBoxHalfWidth,Constants.Flickr.searchLonRange.0)
        let minLatitude = max (latitude-Constants.Flickr.searchBBoxHalfHeight,Constants.Flickr.searchLatRange.0)
        let maxLongitude = min(longitude+Constants.Flickr.searchBBoxHalfWidth,Constants.Flickr.searchLonRange.1)
        let maxLatitude = min(latitude+Constants.Flickr.searchBBoxHalfHeight,Constants.Flickr.searchLatRange.1)
        return "\(minLongitude),\(minLatitude),\(maxLongitude),\(maxLatitude)"
    }
    
    class func sharedInstance()->FlickrClient{
        struct singleton {
            static var sharedInstance = FlickrClient()
        }
        return singleton.sharedInstance
    }
    
    
}
