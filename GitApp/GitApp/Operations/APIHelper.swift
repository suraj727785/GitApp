//
//  APIHelper.swift
//  GitApp
//
//  Created by Suraj Kumar on 11/07/24.
//

import Foundation

class APIHelper {
    static let shared = APIHelper()
    
    private let baseURL = "https://api.github.com"
    
    func searchRepositories(query: String, page: Int, completion: @escaping (Result<[Repository], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/search/repositories?q=\(query)&page=\(page)&per_page=10") else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                let response = try JSONDecoder().decode(SearchResponse.self, from: data)
                completion(.success(response.items))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func getRepositoryDetails(owner: String, repo: String, completion: @escaping (Result<Repository, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/repos/\(owner)/\(repo)") else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                let repository = try JSONDecoder().decode(Repository.self, from: data)
                completion(.success(repository))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func getContributors(owner: String, repo: String, completion: @escaping (Result<[Contributor], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/repos/\(owner)/\(repo)/contributors") else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                let contributors = try JSONDecoder().decode([Contributor].self, from: data)
                completion(.success(contributors))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func getRepositories(for contributor: String, completion: @escaping (Result<[Repository], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/users/\(contributor)/repos") else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                let repositories = try JSONDecoder().decode([Repository].self, from: data)
                completion(.success(repositories))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}

struct SearchResponse: Decodable {
    let items: [Repository]
}

struct Repository: Decodable, Identifiable {
    let id: Int
    let name: String
    let description: String?
    let owner: Owner
    let html_url: String
}

struct Owner: Decodable {
    let login: String
    let avatar_url: String
}

struct Contributor: Decodable, Identifiable {
    let id: Int
    let login: String
    let avatar_url: String
}
