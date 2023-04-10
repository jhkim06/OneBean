//
//  WeatherStore.swift
//  OneBean
//
//  Created by Junho Kim on 2023/04/09.
//

import UIKit
import Foundation

class WeatherStore {
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        
        return URLSession(configuration: config)
    }()
    
    func fetchWeatherInfo(completion: @escaping (Result<[Weather], Error>) -> Void) {
        
        let url = WeatherAPI.ultraSrtURL
        // set location
        //let url = WeatherAPI.ultraFcstURL
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request) { data, res, err in
            if let jsonData = data {
                if let jsonString = String(data: jsonData,
                                           encoding: .utf8) {
                    print(jsonString)
                    let result = self.processWeathersRequest(data: data, error: err)
                    OperationQueue.main.addOperation {
                        completion(result)
                    }
                    
                    print(result)
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
                                      error: Error?) -> Result<[Weather], Error> {
        guard let jsonData = data else {
            return .failure(error!)
        }
        return WeatherAPI.weather(fromJSON: jsonData)
    }
}
