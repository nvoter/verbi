//
//  ApiWorkerProtocols.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 30.01.2025.
//

protocol ApiWorkerProtocol {
    func register(
        email: String,
        username: String,
        password: String,
        completion: @escaping (Result<String, Error>) -> Void
    )
    func confirmEmail(email: String, code: String, completion: @escaping (Result<String, Error>) -> Void)
    func login(emailOrUsername: String, password: String, completion: @escaping (Result<LoginResponse, Error>) -> Void)
    func logout(refreshToken: String, completion: @escaping (Result<String, Error>) -> Void)
    func refresh(refreshToken: String, completion: @escaping (Result<String, Error>) -> Void)
    func resetPassword(email: String, completion: @escaping (Result<String, Error>) -> Void)
    func confirmResetPassword(
        email: String,
        newPassword: String,
        code: String,
        completion: @escaping (Result<String, Error>) -> Void
    )
    func resendCode(email: String, codeType: String, completion: @escaping (Result<String, Error>) -> Void)
    func getUserInfo(completion: @escaping (Result<UserInfoResponse, Error>) -> Void)
    func updateUserInfo(username: String, completion: @escaping (Result<String, Error>) -> Void)
    func deleteAccount(completion: @escaping (Result<String, Error>) -> Void)
}
