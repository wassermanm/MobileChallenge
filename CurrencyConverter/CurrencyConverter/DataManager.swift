//
//  DataManager.swift
//  CurrencyConverter
//
//  Created by Michael Wasserman on 2017-01-12.
//  Copyright © 2017 Wasserman. All rights reserved.
//

import Foundation

class DataManager {
    
    static let sharedInstance = DataManager()
    private init() {}
    
    fileprivate var dataCache = Dictionary<String,DataCache>()
    
    func getCurrencyCodes( _ completion: @escaping (_ success: Bool, _ message: Array<String>) -> ()) {
        get(clientURLRequest("latest")) { (success, object) in
            DispatchQueue.main.async(execute: { () -> Void in
                var rates = Array<String>()
                let errorMessage = "there was an error retrieving currency codes"
                if success {
                    guard let dict = object as? [String: Any] else {
                        rates.append(errorMessage)
                        completion(false, rates)
                        return
                    }
                   guard let base = dict["base"] as? String else {
                        rates.append(errorMessage)
                        completion(false, rates)
                        return
                    }
                    rates.append(base)
                    
                    guard let exchangeRates = dict["rates"] as? [String:Any] else {
                        rates.append(errorMessage)
                        completion(false, rates)
                        return
                    }
                    
                    for rate in exchangeRates {
                        rates.append(rate.key)
                    }
                    
                    completion(true, rates)
                } else {
                    rates.append(errorMessage)
                    completion(false, rates)
                }
            })
        }
    }
    
    func getRatesForCode( _ amount:String, _ base:String, _ completion: @escaping (_ success: Bool, _ message: Array<Rate>, _ errorMessage: String) -> ()) {
        
        if let cachedData = self.dataCache[base] {
            if Date().compare(cachedData.updateTime) == .orderedAscending {
                completion(true, cachedData.rates, "")
                return
            }
        }
        
        let requestURLWithParams = "latest?base=" + base
        
        get(clientURLRequest(requestURLWithParams)) { (success, object) in
            DispatchQueue.main.async(execute: {[weak self] () -> Void in
                var rates = Array<Rate>()
                let errorMessage = "there was an error retrieving rates"
                if success {
                    guard let dict = object as? [String: Any] else {
                        completion(false, rates, errorMessage)
                        return
                    }
                    
                    guard let exchangeRates = dict["rates"] as? [String:Any] else {
                        completion(false, rates, errorMessage)
                        return
                    }
                    
                    for rate in exchangeRates {
                        let aRate = Rate.init(currencyCode: rate.key, currentRate: String(describing: rate.value))
                        rates.append(aRate)
                    }
                    
                    let calendar = Calendar.current
                    if let date = calendar.date(byAdding: .minute, value: 30, to: Date()) {
                        self?.dataCache[base] = DataCache.init(updateTime: date, rates: rates, baseCurr: base)
                    }
                    
                    
                    completion(true, rates, "")
                } else {
                    completion(false, rates, errorMessage)
                }
            })
        }

        
    }
    
    
    //MARK: - HTTP Handling Methods
    fileprivate func clientURLRequest(_ path: String, params: Dictionary<String, String>? = nil) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(url: URL(string: "http://api.fixer.io/"+path)!)
        if let params = params {
            var paramString = ""
            for (key, value) in params {
                let escapedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                let escapedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                paramString += "\(escapedKey)=\(escapedValue)&"
            }
            
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpBody = paramString.data(using: String.Encoding.utf8)
        }
        
        return request
    }
    
    fileprivate func post(_ request: NSMutableURLRequest, completion: @escaping (_ success: Bool, _ object: AnyObject?) -> ()) {
        dataTask(request, method: "POST", completion: completion)
    }
    
    fileprivate func get(_ request: NSMutableURLRequest, completion: @escaping (_ success: Bool, _ object: AnyObject?) -> ()) {
        dataTask(request, method: "GET", completion: completion)
    }
    
    fileprivate func dataTask(_ request: NSMutableURLRequest, method: String, completion: @escaping (_ success: Bool, _ object: AnyObject?) -> ()) {
        request.httpMethod = method
        completion(true, nil)
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
         
         session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
             if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data, options: [JSONSerialization.ReadingOptions.mutableContainers])
                if let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode {
                    completion(true, json as AnyObject?)
                } else {
                    completion(false, json as AnyObject?)
                }
             } else {
                print("NO DATA!")
             }
         }.resume()
    }
}
