//
//  GenerateToken.swift
//  DemoSigmaInteractive
//
//  Created by Pham Hai on 10/06/2022.
//

import Foundation
import CryptoKit

struct DefaultsKeysUser {
    static let userId = "userId"
    static let userRole = "userRole"
    static let token = "token"
    static let userData = "userData"
}

extension Data {
    func urlSafeBase64EncodedString() -> String {
        return base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

struct Header: Encodable {
    let alg = "HS256"
    let typ = "JWT"
}

struct Payload: Codable {
    let id: String
    let exp: Int64
    let role: String
    let appId: String
    let userData: [String: String]?
}

extension Date {
    var millisecondsSince1970:Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}
let tokenFix = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6ImFkbWluIiwiaWQiOiJhZG1pbiIsImlzQWRtaW4iOmZhbHNlLCJpYXQiOjE2NDEzNTYyNTl9.WBRTuqhjBvzHTWCSorkVWeGeRcDFZUHzkGekDGtuZqg";
let apiToken = "https://dev-livestream.gviet.vn/api/interactive/v1/users/gen-token"
class GenerateToken {
    var uid: String
    var userData: [String: Any]
    var role: String
    
    init(_ uid:String, _ userData: [String: Any], _ role: String) {
        self.uid = uid
        self.userData = userData
        self.role = role
        let defaults = UserDefaults.standard
        defaults.set(uid, forKey: DefaultsKeysUser.userId)
        defaults.set(userData, forKey: DefaultsKeysUser.userData)
        defaults.set(role, forKey: DefaultsKeysUser.userRole)
    }
//    public func genToken() -> String {
//        let secret = "abd89b50-d760-4a97-bb24-0a44881fc04a"
//        let privateKey = SymmetricKey(data: Data(secret.utf8))
//        let headerJSONData = try! JSONEncoder().encode(Header())
//        let headerBase64String = headerJSONData.urlSafeBase64EncodedString()
//        let payloadJSONData = try! JSONEncoder().encode(Payload(id: uid, exp: Date().millisecondsSince1970 + 30*24*3600*1000, role: role, appId: "default-app", userData: userData.count > 0 ? userData : nil))
//        let payloadBase64String = payloadJSONData.urlSafeBase64EncodedString()
//        let toSign = Data((headerBase64String + "." + payloadBase64String).utf8)
//        let signature = HMAC<SHA256>.authenticationCode(for: toSign, using: privateKey)
//        let signatureBase64String = Data(signature).urlSafeBase64EncodedString()
//        let token = [headerBase64String, payloadBase64String, signatureBase64String].joined(separator: ".")
//        print("tokenApp=>", token)
//        return token
//    }
    public func convertDicToJsonString() -> String {
        var dataGetToken:[String: Any] = [:]
        dataGetToken["id"] = uid;
        dataGetToken["role"] = role
        dataGetToken["appId"] = "default-app"
        if userData.count > 0 {
            dataGetToken["userData"] = userData
        }
        var dataStringReturn = ""
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dataGetToken, options: .prettyPrinted)
            // here "jsonData" is the dictionary encoded in JSON data
            dataStringReturn = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        } catch {
            print(error.localizedDescription)
        }
        print("DataStringPost=>", dataStringReturn)
        return dataStringReturn
    }
    public func genTokenFromApi() -> String {
        var token = ""
        let semaphore = DispatchSemaphore.init(value: 0)
        let postData = convertDicToJsonString().data(using: .utf8)

        var request = URLRequest(url: URL(string: apiToken)!,timeoutInterval: Double.infinity)
        request.addValue(tokenFix, forHTTPHeaderField: "authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
        request.httpBody = postData
        print("postData=>", postData)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
            print("error=>", error)
            semaphore.signal()
            return
          }
          print("data=>", data)
          do {
              if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                  guard let tokenServer = json["token"] as? String else { return }
                  print("tokenServer=>", tokenServer)
                  token = tokenServer
              }
          } catch{ print("erroMsg") }
          semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        let defaults = UserDefaults.standard
        defaults.set(token, forKey: DefaultsKeysUser.token)
        print("token=>", token)
        return token
    }
}
