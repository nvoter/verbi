//
//  ApiWorkerProtocol.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 30.01.2025.
//

protocol ApiWorkerProtocol {
    func register(
        username: String,
        email: String,
        password: String,
        completion: @escaping (
            Result<
            Void,
            any Error
            >
        ) -> Void
    )
    func confirmEmail(email: String, code: String, completion: @escaping (Result<Void, any Error>) -> Void)
    func login(email: String, password: String, completion: @escaping (Result<Void, any Error>) -> Void)
    func logout(refreshToken: String, completion: @escaping (Result<Void, any Error>) -> Void)
    func resetPassword(email: String, completion: @escaping (Result<Void, any Error>) -> Void)
    func confirmResetPassword(
        email: String,
        newPassword: String,
        completion: @escaping (
            Result<
            Void,
            any Error
            >
        ) -> Void
    )
}
