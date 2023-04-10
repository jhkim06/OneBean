//
//  WeatherAPI.swift
//  OneBean
//
//  Created by Junho Kim on 2023/04/09.
//

import Foundation

enum EndPoint: String {
    case getUltraSrtNcst
    case getVilageFcst
    case getUltraSrtFcst
}
struct Response: Codable {
    let response: WeatherResponse

    enum CodingKeys: String, CodingKey {
        case response = "response"
    }
}
struct WeatherResponse: Codable {
    let body: WeatherBodyResponse

    enum CodingKeys: String, CodingKey {
        case body = "body"
    }
}
struct WeatherBodyResponse: Codable {
    let itemsInfo: WeatherItemsResponse

    enum CodingKeys: String, CodingKey {
        case itemsInfo = "items"
    }
}
struct WeatherItemsResponse: Codable {
    let items: [Weather]

    enum CodingKeys: String, CodingKey {
        case items = "item"
    }
}

struct WeatherAPI {
    
    private static let apiKey = "hAYJAtWrS7rAc4d%2Bc88i9Ii7Z%2FDxgHoQ4zoEkR0rZX5hgbw29jEodIZUaq5w1fujdDYb6t76%2F7kiFO8sWQjvyw%3D%3D"
    private static let baseURLString = "https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0"
    
    private static func weatherURL(endPoint: EndPoint, parameters: [String:String]?)->URL{
        
        // FIXME use current time and location
        /*
         let baseParams = ["serviceKey" : apiKey, "base_date" : "20230409", "base_time" : "1100",
                          "nx" : "55", "ny" : "127"]
         print(baseParams["serviceKey"])
        
         var components = URLComponents(string: baseURLString + "/" + endPoint.rawValue)!
         var queryItems = [URLQueryItem]()
        
        for (key, value) in baseParams {
            // URLQueryItem automatically encode string,
            // so there could be a case api key including '%' is not recongnized propery by the server
            let item = URLQueryItem(name: key, value: value)
            queryItems.append(item)
        }

        if let additionalParams = parameters {
            for (key, value) in additionalParams {
                let item = URLQueryItem(name: key, value: value)
                queryItems.append(item)
            }
        }
        components.queryItems = queryItems
        print(components.url!)
        return components.url!
        */
        
        // FIXME use current location
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd-HH:mm"

        var currentTime = dateFormatter.string(from: Date())
        let minute =  Int(currentTime.components(separatedBy: "-")[1].components(separatedBy: ":")[1])

        // 
        if minute! < 40 { // information updated at every 40 min
            let currentDate = Date()
            let calendar = Calendar.current

            // Subtract one hour from the current time
            let newDate = calendar.date(byAdding: .hour, value: -1, to: currentDate)

            // Format the new date as a string
            currentTime = dateFormatter.string(from: newDate!)
        }
        
        let baseParams = ["base_date" : currentTime.components(separatedBy: "-")[0],
                          "base_time" : currentTime.components(separatedBy: "-")[1]
                            .components(separatedBy: ":")[0] + "00",
                          "nx" : "55", "ny" : "127"]
        
        var urlStr = baseURLString + "/" + endPoint.rawValue + "?serviceKey=\(apiKey)"
        
        for (key, value) in baseParams {
           urlStr = urlStr + "&\(key)=\(value)"
            
        }
        if let additionalParams = parameters {
            for (key, value) in additionalParams {
                urlStr = urlStr + "&\(key)=\(value)"
            }
        }
        
        let url = URL(string: urlStr)
        return url!
    }
    
    static var ultraSrtURL: URL {
        return weatherURL(endPoint: .getUltraSrtNcst, parameters: ["pageNo" : "1", "numOfRows" : "72", "dataType" : "JSON"])
    }
    static var vilageFcstURL: URL {
        return weatherURL(endPoint: .getVilageFcst, parameters: ["pageNo" : "1", "numOfRows" : "72", "dataType" : "JSON"])
    }
    static var ultraFcstURL: URL {
        return weatherURL(endPoint: .getUltraSrtFcst, parameters: ["pageNo" : "1", "numOfRows" : "72", "dataType" : "JSON"])
    }
    static func weather(fromJSON data: Data) -> Result<[Weather], Error> {
        do {
            let decoder = JSONDecoder()
            let weatherResponse = try decoder.decode(Response.self, from: data)
            
            return .success(weatherResponse.response.body.itemsInfo.items)
        } catch {
            return .failure(error)
        }
    }
}

