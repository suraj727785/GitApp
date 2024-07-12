//
//  ContributorRepositoriesView.swift
//  GitApp
//
//  Created by Suraj Kumar on 13/07/24.
//

import Foundation
import SwiftUI

struct ContributorRepositoriesView: View {
    let contributor: Contributor
    @State var isLoading: Bool = true
    @State var repositories = [Repository]()
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .padding()
            } else {
                List(repositories) { repo in
                    RepositoryRow(repo: repo)
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle(contributor.login)
        .onAppear {
            APIHelper.shared.getRepositories(for: contributor.login) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let repos):
                        self.repositories = repos
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                    self.isLoading = false
                }
            }
        }
    }
}


