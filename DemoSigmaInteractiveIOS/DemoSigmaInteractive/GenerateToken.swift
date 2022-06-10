//
//  GenerateToken.swift
//  DemoSigmaInteractive
//
//  Created by Pham Hai on 10/06/2022.
//

import Foundation
import CryptoKit

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
    let userData: [String: String]
}

extension Date {
    var millisecondsSince1970:Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

class GenerateToken {
    var uid: String
    var userData: [String: String]
    var role: String
    
    init(_ uid:String, _ userData: [String: String], _ role: String) {
        self.uid = uid
        self.userData = userData
        self.role = role
    }
    public func genToken() -> String {
        let secret = "abd89b50-d760-4a97-bb24-0a44881fc04a"
        let privateKey = SymmetricKey(data: Data(secret.utf8))
        let headerJSONData = try! JSONEncoder().encode(Header())
        let headerBase64String = headerJSONData.urlSafeBase64EncodedString()
        let payloadJSONData = try! JSONEncoder().encode(Payload(id: uid, exp: Date().millisecondsSince1970 + 30*24*3600*1000, role: role, appId: "default-app", userData: userData))
        let payloadBase64String = payloadJSONData.urlSafeBase64EncodedString()
        let toSign = Data((headerBase64String + "." + payloadBase64String).utf8)
        let signature = HMAC<SHA256>.authenticationCode(for: toSign, using: privateKey)
        let signatureBase64String = Data(signature).urlSafeBase64EncodedString()
        let token = [headerBase64String, payloadBase64String, signatureBase64String].joined(separator: ".")
        print("tokenApp=>", token)
        return token
    }
}
