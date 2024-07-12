//
//  RepoView.swift
//  GitApp
//
//  Created by Suraj Kumar on 13/07/24.
//
import WebKit
import SwiftUI

struct WebView: UIViewRepresentable {
    let repo:Repository
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: URL(string: repo.html_url)!)
        uiView.load(request)
    }
}

struct RepoView: View {
    let repo: Repository
    var body: some View {
        NavigationView {
            WebView(repo: repo)
                .navigationBarTitle("Repo View", displayMode: .inline)
        }
    }
}
