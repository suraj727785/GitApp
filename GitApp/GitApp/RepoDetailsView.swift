//
//  RepoDetailsView.swift
//  GitApp
//
//  Created by Suraj Kumar on 12/07/24.
//

import Foundation
import SwiftUI

struct RepoDetailsView: View {
    let repo: Repository
    @State var repository: Repository?
    @State var contributors = [Contributor]()
    @State var isLoading = true

    init(repo: Repository) {
        self.repo = repo
    }
    
    var body: some View {
        
        let contributorsCompletionHandler: ((Result<[Contributor], Error>) -> Void) = { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let contributors):
                    self.contributors = contributors
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        
        let repositoryDetailsCompletion: ((Result<Repository, Error>) -> Void) = {
            result in
            DispatchQueue.main.async {
                switch result {
                case .success(let repo):
                    self.repository = repo
                    APIHelper.shared.getContributors(owner: repo.owner.login, repo: repo.name,completion: contributorsCompletionHandler)
                case .failure(let error):
                    print(error.localizedDescription)
                }
                self.isLoading = false
            }
        }
        VStack {
            if isLoading {
                ProgressView()
                    .padding()
            } else {
                if let repository = repository {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(repository.name)
                            .font(.largeTitle)
                            .bold()
                        
                        if let description = repository.description {
                            Text(description)
                                .font(.body)
                        }
                        
                        NavigationLink(destination: RepoView(repo: repo)) {
                            Text("Project Link")
                        }
                        Text("Contributors")
                            .font(.headline)
                        
                        List(contributors) { contributor in
                            NavigationLink(destination: ContributorRepositoriesView(contributor: contributor)) {
                                ContributorRow(contributor: contributor)
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            APIHelper.shared.getRepositoryDetails(owner: repo.owner.login, repo: repo.name,completion: repositoryDetailsCompletion)
        }
    }
}

struct ContributorRow: View {
    let contributor: Contributor
    
    var body: some View {
        HStack {
            Text(contributor.login)
                .font(.headline)
            Spacer()
        }
        .padding()
    }
}
