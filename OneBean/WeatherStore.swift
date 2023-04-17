//
//  WeatherStore.swift
//  OneBean
//
//  Created by Junho Kim on 2023/04/09.
//

import UIKit
import Foundation
import SwiftUI

class WeatherStore {
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        
        return URLSession(configuration: config)
    }()
    
    func fetchWeatherInfo(endpoint: EndPoint = EndPoint.getUltraSrtNcst, completion: @escaping (Result<[String:Any], Error>) -> Void) {
        
        var url: URL
        switch endpoint {
        case .getUltraSrtNcst:
            url = WeatherAPI.ultraSrtURL
        case .getVilageFcst:
            url = WeatherAPI.vilageFcstURL
        case .getUltraSrtFcst:
            url = WeatherAPI.ultraFcstURL
        }
        
        //let url = WeatherAPI.ultraFcstURL
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request) { data, res, err in
            if let jsonData = data {
                if let _ = String(data: jsonData,
                                           encoding: .utf8) {
                    //print(jsonString)
                    let result = self.processWeathersRequest(data: data, error: err, endpoint: endpoint)
                    OperationQueue.main.addOperation {
                        // 'result' passed to a completion closure
                        // the closure is defined in the caller side
                        completion(result)
                        
                    }
                    
                    // print(result)
                }
            } else if let requestError = err {
                print("Error fetching weather info. \(requestError)")
            } else {
                print("Unexpected error with the request.")
            }
        }
        task.resume()
    }
    private func processWeathersRequest(data: Data?,
                                        error: Error?, endpoint:EndPoint = EndPoint.getUltraSrtNcst) -> Result<[String:Any], Error> {
        guard let jsonData = data else {
            return .failure(error!)
        }
        return WeatherAPI.weather(fromJSON: jsonData, endpoint: endpoint)
    }
}
