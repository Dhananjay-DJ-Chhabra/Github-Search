//
//  SearchResultsViewController.swift
//  Github-Search
//
//  Created by Dhananjay Chhabra on 08/10/23.
//

import Foundation
import UIKit
import SDWebImage

class SearchResultsViewController: UIViewController{
    
    let resultsTable: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(ProfilesTableViewCell.self, forCellReuseIdentifier: ProfilesTableViewCell.identifier)
        return table
    }()
    
    var searchResult: SearchResult
    var query: String
    
    init(searchResult: SearchResult, query: String) {
        self.searchResult = searchResult
        self.query = query
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var pageNumber: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Search Results"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.tintColor = .black
        
        resultsTable.delegate = self
        resultsTable.dataSource = self
        view.addSubview(resultsTable)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        resultsTable.frame = view.bounds
    }
    
    
}


// MARK: - Table View Delegate and Data Source Methods
extension SearchResultsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProfilesTableViewCell.identifier) as? ProfilesTableViewCell else { return UITableViewCell() }
        guard let item = searchResult.items?[indexPath.row] else { return UITableViewCell() }
        
        cell.configureCell(url: item.avatar_url, username: searchResult.items?[indexPath.row].login)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let item = searchResult.items?[indexPath.row] else { return }
        fetchUser(query: item.login)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let items = searchResult.items, let totalCount = searchResult.total_count else { return }
        if indexPath.row == items.count - 1 && items.count < totalCount {
            pageNumber += 1
            doPagination(pageNumber: pageNumber)
        }
    }
    
}


// MARK: - Network Calls
extension SearchResultsViewController{
    func fetchUser(query: String?){
        guard let query = query else {return}
        guard let url = URL(string: "https://api.github.com/users/\(query)") else {return}
        URLSession.shared.dataTask(with: URLRequest(url: url)){ data, _, error in
            guard let data = data, error == nil else{ return }
            do{
                let results = try JSONDecoder().decode(UserModel.self, from: data)
                DispatchQueue.main.async {
                    let vc = ProfileViewController(user: results)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }catch(let error){
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    func doPagination(pageNumber: Int){
        guard let url = URL(string: "https://api.github.com/search/users?q=\(query)&page=\(pageNumber)") else {return}
        URLSession.shared.dataTask(with: URLRequest(url: url)){ data, _, error in
            guard let data = data, error == nil else{ return }
            do{
                let results = try JSONDecoder().decode(SearchResult.self, from: data)
                guard let items = results.items else { return }
                DispatchQueue.main.async {
                    self.searchResult.items?.append(contentsOf: items)
                    self.resultsTable.reloadData()
                }
            }catch(let error){
                print(error.localizedDescription)
            }
        }.resume()
    }
}
