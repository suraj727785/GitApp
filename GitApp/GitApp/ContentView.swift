//
//  HomeView.swift
//  GitApp
//
//  Created by Suraj Kumar on 11/07/24.
//

import SwiftUI
import CoreData

struct HomeView: View {
    private let context: NSManagedObjectContext
    @State private var query = ""
    @State private var repositories = [Repository]()
    @State private var currentPage = 1
    @State private var isLoading = false
    @State private var allRepositoriesLoaded = false
    @State private var previousRepositories = [Repository]()
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if(!isLoading){
                    HStack {
                        TextField("Search Repositories", text: $query)
                            .padding(.leading, 8)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button(action: {
                            currentPage = 1
                            allRepositoriesLoaded = false
                            searchRepositories()
                        }) {
                            Text("Search")
                        }
                        .padding(.trailing, 8)
                    }
                    .padding()
                }
                
                if isLoading {
                    ProgressView()
                        .padding()
                } else {
                    List {
                        ForEach(repositories.prefix(10), id: \.id) { repo in
                            NavigationLink(destination: RepoDetailsView(repo: repo)) {
                                RepositoryRow(repo: repo)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    
                    HStack {
                        Button(action: {
                            currentPage -= 1
                            searchRepositories()
                        }) {
                            Text("Previous")
                        }
                        .disabled(currentPage == 1)
                        .padding()
                        
                        Spacer()
                        
                        Button(action: {
                            currentPage += 1
                            searchRepositories()
                        }) {
                            Text("Next")
                        }
                        .disabled(allRepositoriesLoaded)
                        .padding()
                    }
                }
            }
            .navigationTitle("Repositories")
            .onAppear {
                loadSavedData()
            }
        }
    }
    
    private func searchRepositories() {
        isLoading = true
        APIHelper.shared.searchRepositories(query: query, page: currentPage) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let repos):
                    repositories = repos
                    self.saveData(repos)
                    if repos.count < 10 {
                        self.allRepositoriesLoaded = true
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
                self.isLoading = false
            }
        }
    }
    
    private func loadPreviousRepositories() {
        guard let lastPageRepos = previousRepositories.last else { return }
        repositories = previousRepositories.dropLast(10).suffix(10) + [lastPageRepos]
        previousRepositories = Array(previousRepositories.dropLast(10).prefix(10))
        currentPage -= 1
    }
    
    private func loadSavedData() {
        let fetchRequest: NSFetchRequest<SavedRepository> = SavedRepository.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \SavedRepository.id, ascending: true)]
        fetchRequest.fetchLimit = 15
        
        do {
            let savedRepos = try context.fetch(fetchRequest)
            self.repositories = savedRepos.map {
                Repository(id: Int($0.id), name: $0.name ?? "", description: $0.repoDescription, owner: Owner(login: $0.owner ?? "", avatar_url: ""), html_url: $0.htmlURL ?? "")
            }
        } catch {
            print("Failed to load saved repositories: \(error.localizedDescription)")
        }
    }
    
    private func saveData(_ repositories: [Repository]) {
        let fetchRequest: NSFetchRequest<SavedRepository> = SavedRepository.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \SavedRepository.id, ascending: true)]
        fetchRequest.fetchLimit = 15
        
        do {
            let savedRepos = try context.fetch(fetchRequest)
            if savedRepos.count < 15 {
                for repo in repositories.prefix(15 - savedRepos.count) {
                    let savedRepo = SavedRepository(context: context)
                    savedRepo.id = Int64(repo.id)
                    savedRepo.name = repo.name
                    savedRepo.repoDescription = repo.description
                    savedRepo.owner = repo.owner.login
                    savedRepo.htmlURL = repo.html_url
                }
                try context.save()
            }
        } catch {
            print("Failed to save repositories: \(error.localizedDescription)")
        }
    }
}

struct RepositoryRow: View {
    let repo: Repository
    
    var body: some View {
        HStack {
            Text(repo.name)
                .font(.headline)
            Spacer()
        }
        .padding()
    }
}
