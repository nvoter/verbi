//
//  ApiWorker.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 30.01.2025.
//

import Alamofire
import Foundation

final class ApiWorker {
    // MARK: - Properties
    private let baseURL = "http://192.168.0.32:8083/api/v1"

    // MARK: - Methods
    private func getAuthHeaders() -> HTTPHeaders {
        guard let accessToken = TokenManager.shared.getAccessToken() else {
            fatalError("Could not get access token")
        }

        let headers: HTTPHeaders = [.authorization(bearerToken: accessToken)]
        return headers
    }
}

// MARK: - AuthApiWorkerProtocol
extension ApiWorker: AuthApiWorkerProtocol {
    // MARK: Register
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

    // MARK: Confirm Email
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

    // MARK: Login
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

    // MARK: Reset Password
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

    // MARK: Confirm Reset Password
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

    // MARK: Resend Code
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

    // MARK: Refresh
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

    // MARK: Get User Info
    func getUserInfo(completion: @escaping (Result<UserInfoResponse, Error>) -> Void) {
        let url = "\(baseURL)/profile/"
        let headers = getAuthHeaders()
        let request = AF.request(url, method: .get, headers: headers)
        request
            .validate()
            .responseDecodable(of: UserInfoResponse.self) { response in
                switch response.result {
                case .success(let userInfo):
                    completion(.success(userInfo))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    // MARK: Update User Info
    func updateUserInfo(username: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = "\(baseURL)/profile/"
        let parameters: [String: Any] = [
            "new_username": username
        ]

        AF.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: getAuthHeaders())
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

    // MARK: Delete Account
    func deleteAccount(completion: @escaping (Result<String, Error>) -> Void) {
        let url = "\(baseURL)/profile/"

        AF.request(url, method: .delete, headers: getAuthHeaders())
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

    // MARK: Logout
    func logout(refreshToken: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = "\(baseURL)/auth/logout/"
        let headers: HTTPHeaders = [
            "Refresh-token": refreshToken
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
}

// MARK: - LibraryApiWorkerProtocol
extension ApiWorker: LibraryApiWorkerProtocol {
    // MARK: FetchDocuments
    func fetchDocuments(userId: UInt, completion: @escaping (Result<[Document], Error>) -> Void) {
        let url = "\(baseURL)/documents/\(userId)"
        AF.request(url, method: .get, headers: getAuthHeaders())
            .validate()
            .responseDecodable(of: GetDocumentsResponse.self) { resp in
                debugPrint(resp)
                switch resp.result {
                case .success(let data):
                    guard !data.documents.isEmpty else {
                        completion(.success([]))
                        return
                    }

                    completion(.success(data.documents))
                case .failure(let err):
                    completion(.failure(err))
                }
            }
    }

    // MARK: FetchCredentials
    func fetchCredentials(userId: UInt, completion: @escaping (Result<GetCredentialsResponse, Error>) -> Void) {
        let url = "\(baseURL)/documents/credentials"
        let params: Parameters = ["userId": userId]
        AF.request(url, method: .get, parameters: params, headers: getAuthHeaders())
            .validate()
            .responseDecodable(of: GetCredentialsResponse.self) { resp in
                switch resp.result {
                case .success(let creds): completion(.success(creds))
                case .failure(let err):   completion(.failure(err))
                }
            }
    }

    // MARK: CreateDocument
    func createDocument(
        userId: UInt,
        title: String,
        completion: @escaping (Result<CreateDocumentResponse, Error>) -> Void
    ) {
        let url = "\(baseURL)/documents"
        let params: Parameters = [
            "user_id": userId,
            "title": title
        ]
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: getAuthHeaders())
            .validate(statusCode: 200..<300)
            .responseDecodable(of: CreateDocumentResponse.self) { resp in
                debugPrint(resp)
                switch resp.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let err):
                    completion(.failure(err))
                }
            }
    }
}

// MARK: - LlmApiWorkerProtocol
extension ApiWorker: LlmApiWorkerProtocol {
    func send(request: LlmRequest, completion: @escaping (Result<LlmResponse, Error>) -> Void) {
        let url = "http://192.168.0.32:8082/api/v1/llm/response"
        AF.request(
            url,
            method: .post,
            parameters: request,
            encoder: JSONParameterEncoder.default
        )
        .validate()
        .responseDecodable(of: LlmResponse.self) { response in
            switch response.result {
            case .success(let resp):
                completion(.success(resp))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
