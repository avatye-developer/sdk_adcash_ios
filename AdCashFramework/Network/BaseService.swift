//
//  BaseService.swift
//  AdCashFramework
//
//  Created by 임재혁 on 5/31/24.
//

import Foundation

protocol BaseService {
    /// API request URL
    var url: String { get set }
    var header: [String: String] { get set }
    var param: Encodable? { get set }
    /// Request에 들어가는 HTTP method
    var method: String { get set }
}

extension BaseService {
    /// BaseService에 지정한 값으로 API 연동을 수행한 결과(NetworkResult)가 클로저 함수의 parameter가 됨.
    func serverAction<T>(type: T.Type, completion: @escaping (NetworkResult<Any>) -> Void) where T: Decodable {
        var paramAsDictionary: [String: Any]? = ["Tmp": "Tmp"]
        do {
            let dictionary = try param?.encode()
            paramAsDictionary = dictionary
        } catch {
            AdCashLogger.error("BaseService serverAction Error \(error)")
        }

        guard var urlComponents = URLComponents(string: self.url) else {
            completion(.networkFail)
            return
        }

        var queryItems: [URLQueryItem] = []

        if let paramAsDictionary = paramAsDictionary {
            for (key, value) in paramAsDictionary {
                queryItems.append(URLQueryItem(name: key, value: "\(value)"))
            }
        }

        // URL에 쿼리 파라미터 추가
        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            completion(.networkFail)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        for (key, value) in header {
            request.setValue(value, forHTTPHeaderField: key)
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                AdCashLogger.error("BaseService ServerAction network Error \(error)")
                completion(.networkFail)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                
                if let data = data {
                    if statusCode < 300 {
                        let networkResult = self.isValidData(data: data, type: T.self)
                        completion(networkResult)
                    } else if statusCode >= 400 && statusCode < 500 {
                        completion(self.isErrorData(data: data, status: statusCode))
                    } else if statusCode >= 500 && statusCode < 600 {
                        completion(.serverErr)
                    } else {
                        completion(.unRecognizedError)
                    }
                } else {
                    completion(.unRecognizedError)
                }
            } else {
                completion(.unRecognizedError)
            }
        }
        task.resume()
    }

    func isValidData<T>(data: Data, type: T.Type) -> NetworkResult<Any> where T: Decodable {
        let decoder = JSONDecoder()
        
        guard let decodedData = try? decoder.decode(type, from: data) else {
            return .unRecognizedError
        }
        return .success(decodedData as Any)
    }

    func isErrorData(data: Data, status: Int) -> NetworkResult<Any> {
        let decoder = JSONDecoder()
        guard let errorDecoder = try? decoder.decode(ServerErrorModel.self, from: data) else {
            return .unRecognizedError
        }
        AdCashLogger.debug("isErrorData \(errorDecoder)")
        let errorJson = ServerErrorModel(code: errorDecoder.code, status: status, message: errorDecoder.message)
        var errorData: String?
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(errorJson)

            if let jsonString = String(data: jsonData, encoding: .utf8) {
                AdCashLogger.debug("jsonString \(jsonString)")
                errorData = jsonString
            } else {
                return .unRecognizedError
            }
        } catch {
            return .unRecognizedError
        }

        if let errorData = errorData {
            return .pathErr(errorData)
        } else {
            return .unRecognizedError
        }
    }
}

enum NetworkResult<T> {
    /// output data에 맞춰서 파싱까지 완료된 경우
    case success(T)
    /// network failure가 아닌 에러가 발생했고
    /// api 문서에 명시된 에러 data에 맞춰서 파싱까지 완료된 경우
    case pathErr(T)
    /// code 500~599로 서버 쪽 에러인 경우
    case serverErr
    /// 기기 네트워크 문제인 경우
    case networkFail
    /**
     1. network failure가 아닌 에러가 발생했지만
     api 문서에 명시된 에러 data에 맞춰서 파싱이 불가능한 경우
     2. code가 200대이기는 한데 Service 호출쪽에서 전달해준
     data 형식에 맞춰 파싱이 불가능한 경우
     3. code가 600 이상인 경우 */
    case unRecognizedError
}

// codable -> dictionary Type
extension Encodable {
    func encode() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }

        return dictionary
    }
}
