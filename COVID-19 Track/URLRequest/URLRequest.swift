//
//  URLRequest+Shield.swift
//  workable
//
//  Created by George Tsifrikas on 08/03/2020.
//  Copyright © 2020 George Tsifrikas. All rights reserved.
//

import Foundation
//import Alamofire

public struct HttpHeader {
    public let name: String
    public let value: String

    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }
}

enum HttpHeaderContentType {
    case json
    case formUrlEncoded
}

public struct Headers {

    public static let AUTHORIZATION_HEADER = "Authorization"
    public static let USER_AGENT_HEADER = "User-Agent"
    public static let WORKABLE_WEB_VIEW_USER_AGENT = "Workable-User-Agent"
    public static let supportedActionRequests = "X_Supported_Action_Requests"
    public static let protobufContentType: HttpHeader = HttpHeader(name: "Content-Type", value: "application/protobuf")
    public static let jsonContentType: HttpHeader = HttpHeader(name: "Content-Type", value: "application/json")
    public static let formUrlEncodedContentType: HttpHeader = HttpHeader(name: "Content-Type", value: "application/x-www-form-urlencoded; charset=utf-8")
}

public enum HTTPMethodType: String {
    case GET
    case PUT
    case POST
    case DELETE
    case PATCH
}

extension URLRequest: URLRequestConvertible {
    /// Returns a URL request or throws if an `Error` was encountered.
    public func asURLRequest() throws -> URLRequest { return self }
}

extension URLRequest {
    fileprivate static func addPathComponents(_ path: String, _ url: inout URL) {
        // Add path components
        let pathParts = path.split(separator: "/")
        for pathComponent in pathParts {
            url.appendPathComponent(String(pathComponent))
        }
    }
    
    fileprivate static func addRequestHeaders(_ headers: [HttpHeader], _ request: inout URLRequest) {
        // Add headers
        for header in headers {
            request.setValue(header.value, forHTTPHeaderField: header.name)
        }
    }
    
    fileprivate static func encodeParameters(_ request: inout URLRequest, _ parameters: [String: Any]?) {
        // Encode parameters
        let encoder = URLEncoding(destination: .methodDependent)
        if let requestWithParams = try? encoder.encode(request, with: parameters) {
            request = requestWithParams
        } else {
            preconditionFailure("Can not encode parameters")
        }
    }

    private static func defaultHeaders(contentType: HttpHeaderContentType) -> [HttpHeader] {
        let contentTypeHeader: HttpHeader
        switch contentType {
        case .formUrlEncoded:
            contentTypeHeader = Headers.formUrlEncodedContentType
        case .json:
            contentTypeHeader = Headers.jsonContentType
        }
        return [
            HttpHeader(name: "Accept", value: "application/json"),
            contentTypeHeader
        ]
    }

    fileprivate static func encodeBodyToJSON(_ request: inout URLRequest, _ parameters: [String: Any]) {
        // Create JSON body
        if let data = try? JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions()) {
            request.httpBody = data
        } else {
            preconditionFailure("Can not create JSON body")
        }
    }
    
    static func makeRequest(
          method: HTTPMethodType,
          path: String,
          parameters: [String: Any]? = nil,
          headers: [HttpHeader],
          contentType: HttpHeaderContentType,
          base: String) -> URLRequest {
        
        guard
            let components = URLComponents(string: base),
            var url = components.url else {
                preconditionFailure("Invalid url string")
        }
        
        let parameters = parameters ?? [:]
        
        addPathComponents(path, &url)
        var request = URLRequest(url: url)
        
        let allHeaders = defaultHeaders(contentType: contentType) + headers
        addRequestHeaders(allHeaders, &request)
        request.httpMethod = method.rawValue
        
        // If method .GET paraters on path?=foo=bar
        if method == .GET || contentType == .formUrlEncoded {
            // parameters on body foo=bar&...
            encodeParameters(&request, parameters)
        } else {
            encodeBodyToJSON(&request, parameters)
        }
        
        return request
    }
}
