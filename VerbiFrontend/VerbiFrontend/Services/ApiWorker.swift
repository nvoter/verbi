//
//  ApiWorker.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 30.01.2025.
//

import Foundation

final class ApiWorker: ApiWorkerProtocol {
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
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completion(.success(()))
        }
    }

    func confirmEmail(email: String, code: String, completion: @escaping (Result<Void, any Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completion(.success(()))
        }
    }

    func login(email: String, password: String, completion: @escaping (Result<Void, any Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completion(.success(()))
        }
    }

    func logout(refreshToken: String, completion: @escaping (Result<Void, any Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completion(.success(()))
        }
    }

    func resetPassword(email: String, completion: @escaping (Result<Void, any Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completion(.success(()))
        }
    }

    func confirmResetPassword(
        email: String,
        newPassword: String,
        completion: @escaping (
            Result<
            Void,
            any Error
            >
        ) -> Void
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completion(.success(()))
        }
    }

    func refresh(refreshToken: String, completion: @escaping (Result<String, any Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completion(.success(("token")))
        }
    }
}
