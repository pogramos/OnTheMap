//
//  AuthenticationClient.swift
//  OnTheMap
//
//  Created by Guilherme on 1/22/18.
//  Copyright © 2018 Progeekt. All rights reserved.
//

import UIKit

class AuthenticationClient: NSObject {
    static let shared = AuthenticationClient()
    private override init() { }

    func logout(success: @escaping (AuthenticationResponse?) -> Void, failure: @escaping (Error?) -> Void) {
        let request = NSMutableURLRequest(url: udacityURL(with: [:], for: Methods.Session))
        let httpCookieStorage = HTTPCookieStorage.shared
        var xsrfCookie: HTTPCookie? = nil
        for cookie in httpCookieStorage.cookies! {
            if Headers.XsrfToken.range(of: cookie.name) != nil {
                xsrfCookie = cookie
            }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: Headers.XsrfToken)
        }
        NetworkClient().delete(request: request, decoder: AuthenticationResponse.self) { (session, error) in
            if let error = error {
                failure(error)
            } else {
                success(session)
            }
        }
    }

    func login(with facebook: FacebookAuthentication, success: @escaping ((AuthenticationResponse?) -> Void), failure: @escaping ((Error?) -> Void)) {
        let request = NSMutableURLRequest(url: udacityURL(with: [:], for: Methods.Session))
        let body = PostAuthentication(facebook: facebook, udacity: nil)
        NetworkClient().post(request: request, body: body,
                            decoder: AuthenticationResponse.self) { (authentication, error) in
            if let error = error {
                failure(error)
            } else {
                success(authentication)
            }
        }
    }

    func login(with udacityUser: UdacityAuthentication, success: @escaping ((AuthenticationResponse?) -> Void), failure: @escaping ((Error?) -> Void)) {
        let request = NSMutableURLRequest(url: udacityURL(with: [:], for: Methods.Session))
        let body = PostAuthentication(facebook: nil, udacity: udacityUser)
        NetworkClient().post(request: request, body: body,
                             decoder: AuthenticationResponse.self) { (authentication, error) in
            if let error = error {
                failure(error)
            } else {
                success(authentication)
            }
        }
    }

    func getUserInformation(for accountKey: String, success: @escaping ((Response?) -> Void), failure: @escaping ((Error?) -> Void)) {
        let request = NSMutableURLRequest(url:
            udacityURL(with: [:], for: Methods.UsersUserID.replace(key: Keys.UserID, to: accountKey))
        )
        NetworkClient().get(request: request as URLRequest, decoder: Response.self) { (response, error) in
            if let error = error {
                failure(error)
            } else {
                success(response)
            }
        }
    }

    private func udacityURL(with parameters: [String: AnyObject], for pathExtension: String? = nil) -> URL {
        var components = URLComponents()
        components.scheme = Constants.ApiScheme
        components.host = Constants.ApiHost
        components.path = Constants.ApiPath + (pathExtension ?? "")

        return NetworkClient.buildURL(forComponents: components, with: parameters)!
    }
}
