//
//  ImageDownloadManager.swift
//  BeneficiosBCP
//
//  Created by Mateo Espinoza on 1/03/18.
//  Copyright © 2018 Mateo Thomas Espinoza Saavedra. All rights reserved.
//

import UIKit

public class MTImageDownloadManager: NSObject {

    
    @discardableResult public class func downloadImage(url : URL, success: ((_ image : UIImage)-> Void)?, failure: (()-> Void)?) -> URLSessionDataTask{
        
        let downloadTask = self.downloadImage(url: url, imageView: nil, success: { (image : UIImage) in
            success?(image)
        }) {
            failure?()
        }
        downloadTask.resume()
        return downloadTask
    }
    
    @discardableResult public class func downloadImage(url: URL, imageView : UIImageView?,success:((_ image : UIImage)-> Void)?, failure:(()->Void)?) -> URLSessionDataTask{
        
        let downloadTask = self.downloadImage(url: url, imageView: imageView, placeholder: nil, success: { (image:UIImage) in
            success?(image)
        }) {
            failure?()
        }
        return downloadTask
    }
    
    @discardableResult public class func downloadImage(url : URL, imageView : UIImageView?, placeholder : UIImage?, success: ((_ image : UIImage)->Void)?, failure : (()->Void)?) -> URLSessionDataTask{
        
        if imageView != nil  {
            imageView?.image = placeholder
        }
        
        let dataTask = URLSession.shared.dataTask(with: url) { (data : Data?, response: URLResponse?, error: Error?) in
            
            self.backgroundAsyncThread(completionHandler: {
                
                if let data = data, error == nil,
                    let image = UIImage(data: data){
                    
                    self.mainSyncThread(completionHandler: {
                        if imageView != nil{
                            imageView?.image = image
                        }
                        success?(image)
                    })
                }else{
                    self.mainSyncThread(completionHandler: {
                        failure?()
                    })
                }
            })
        }
        dataTask.resume()
        return dataTask
    }
    
    
    private class func backgroundAsyncThread(completionHandler:@escaping ()->Void){
    
        DispatchQueue.global(qos: .background).async {
            completionHandler()
        }
    }
    
    private class func mainSyncThread(completionHandler:@escaping ()->Void){
        
        DispatchQueue.main.sync {
            completionHandler()
        }
    }
}
