//
//  ApiWorker.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 30.01.2025.
//

import Alamofire
import Foundation

final class ApiWorker: ApiWorkerProtocol {
    // MARK: - Properties
    private let baseURL = "http://192.168.0.32:8080/api/v1"

    // MARK: - Register
    func register(
        email: String,
        username: String,
        password: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let url = "\(baseURL)/auth/register"
        let parameters: [String: Any] = [
            "email": email,
            "username": username,
            "password": password
        ]
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .responseDecodable(of: ApiResponse.self) { response in
                switch response.result {
                case .success(let apiResponse):
                    if let message = apiResponse.message {
                        completion(.success(message))
                    } else {
                        completion(.failure(NSError(domain: "InvalidResponse", code: 400, userInfo: nil)))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    // MARK: - Confirm Email
    func confirmEmail(email: String, code: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = "\(baseURL)/auth/email"
        let parameters: [String: String] = [
            "email": email,
            "code": code
        ]
        AF.request(url, method: .get, parameters: parameters)
            .validate()
            .responseDecodable(of: ApiResponse.self) { response in
                switch response.result {
                case .success(let apiResponse):
                    if let message = apiResponse.message {
                        completion(.success(message))
                    } else {
                        completion(
                            .failure(
                                NSError(
                                    domain: "InvalidResponse",
                                    code: 400,
                                    userInfo: nil
                                )
                            )
                        )
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    // MARK: - Login
    func login(
        emailOrUsername: String,
        password: String,
        completion: @escaping (Result<LoginResponse, Error>) -> Void
    ) {
        let url = "\(baseURL)/auth/login"
        let parameters: [String: String] = [
            "emailOrUsername": emailOrUsername
        ]
        let headers: HTTPHeaders = [
            "Password": password
        ]
        AF.request(url, method: .get, parameters: parameters, headers: headers)
            .validate()
            .responseDecodable(of: LoginResponse.self) { response in
                print(response)
                switch response.result {
                case .success(let loginResponse):
                    completion(.success(loginResponse))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    // MARK: - Logout
    func logout(refreshToken: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = "\(baseURL)/auth/logout"
        let headers: HTTPHeaders = [
            "refreshToken": refreshToken
        ]
        AF.request(url, method: .get, headers: headers)
            .validate()
            .responseDecodable(of: ApiResponse.self) { response in
                switch response.result {
                case .success(let apiResponse):
                    if let message = apiResponse.message {
                        completion(.success(message))
                    } else {
                        completion(.failure(NSError(domain: "InvalidResponse", code: 400, userInfo: nil)))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    // MARK: - Refresh
    func refresh(refreshToken: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = "\(baseURL)/auth/refresh"
        let headers: HTTPHeaders = [
            "Refresh-token": refreshToken
        ]
        AF.request(url, method: .get, headers: headers)
            .validate()
            .responseDecodable(of: RefreshResponse.self) { response in
                switch response.result {
                case .success(let refreshResponse):
                    completion(.success(refreshResponse.accessToken))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    // MARK: - Reset Password
    func resetPassword(email: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = "\(baseURL)/auth/password"
        let parameters: [String: String] = [
            "email": email
        ]
        AF.request(url, method: .get, parameters: parameters)
            .validate()
            .responseDecodable(of: ApiResponse.self) { response in
                switch response.result {
                case .success(let apiResponse):
                    if let message = apiResponse.message {
                        completion(.success(message))
                    } else {
                        completion(
                            .failure(
                                NSError(
                                    domain: "InvalidResponse",
                                    code: 400,
                                    userInfo: nil
                                )
                            )
                        )
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    // MARK: - Confirm Reset Password
    func confirmResetPassword(
        email: String,
        newPassword: String,
        code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let url = "\(baseURL)/auth/password"
        let parameters: [String: Any] = [
            "email": email,
            "new_password": newPassword,
            "code": code
        ]
        AF.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .responseDecodable(of: ApiResponse.self) { response in
                switch response.result {
                case .success(let apiResponse):
                    if let message = apiResponse.message {
                        completion(.success(message))
                    } else {
                        completion(.failure(NSError(domain: "InvalidResponse", code: 400, userInfo: nil)))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    // MARK: - Resend Code
    func resendCode(email: String, codeType: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = "\(baseURL)/auth/code"
        let parameters: [String: String] = [
            "email": email,
            "code_type": codeType
        ]
        AF.request(url, method: .get, parameters: parameters)
            .validate()
            .responseDecodable(of: ApiResponse.self) { response in
                switch response.result {
                case .success(let apiResponse):
                    if let message = apiResponse.message {
                        completion(.success(message))
                    } else {
                        completion(
                            .failure(
                                NSError(
                                    domain: "InvalidResponse",
                                    code: 400,
                                    userInfo: nil
                                )
                            )
                        )
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}
