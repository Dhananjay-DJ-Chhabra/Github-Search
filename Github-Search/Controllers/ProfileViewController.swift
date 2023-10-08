//
//  ProfileViewController.swift
//  Github-Search
//
//  Created by Dhananjay Chhabra on 08/10/23.
//

import UIKit

class ProfileViewController: UIViewController {
    private var profilePic: UIImageView = {
        let imgView = UIImageView()
        imgView.clipsToBounds = true
        imgView.contentMode = .scaleAspectFill
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 15
        stack.alignment = .fill
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let user: UserModel
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setUp()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrowshape.turn.up.forward.fill"), style: .done, target: self, action: #selector(shareProfile))
        navigationController?.navigationBar.tintColor = .white
    }
    
    init(user: UserModel){
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func shareProfile(){
           UIGraphicsBeginImageContext(view.frame.size)
           view.layer.render(in: UIGraphicsGetCurrentContext()!)
           let image = UIGraphicsGetImageFromCurrentImageContext()
           UIGraphicsEndImageContext()

           let textToShare = "Check out this Github profile"

        if let login = user.login, let profileUrl = URL(string: "https://api.github.com/users/\(login)") {
               let objectsToShare = [textToShare, profileUrl, image ?? #imageLiteral(resourceName: "app-logo")] as [Any]
               let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

               activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]

               activityVC.popoverPresentationController?.sourceView = profilePic
               self.present(activityVC, animated: true, completion: nil)
           }    }
    
    private func setUp(){
        view.addSubview(profilePic)
        NSLayoutConstraint.activate([
            profilePic.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            profilePic.heightAnchor.constraint(equalToConstant: view.bounds.width/2),
            profilePic.widthAnchor.constraint(equalToConstant: view.bounds.width/2),
            profilePic.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        profilePic.layer.cornerRadius = view.bounds.width/4
        fetchImage()
        
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: profilePic.bottomAnchor, constant: 50),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
        ])
        addItemsToStack()
        
    }
    
    @objc func seeFollowerDetails(){
        guard let followerUrl = user.followers_url, let query = user.login, let followersCount = user.followers else { return }
        guard let url = URL(string: followerUrl) else {return}
        URLSession.shared.dataTask(with: URLRequest(url: url)){ data, _, error in
            guard let data = data, error == nil else{ return }
            do{
                let results = try JSONDecoder().decode([Item].self, from: data)
                let result = SearchResult(total_count: followersCount, items: results)
                DispatchQueue.main.async {
                    let vc = SearchResultsViewController(searchResult: result, query: query)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }catch(let error){
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    private func addItemsToStack(){
        for i in 0..<9{
            let stack = UIStackView()
            stack.axis = .horizontal
            stack.spacing = 10
            stack.alignment = .fill
            stack.distribution = .fill
            
            let titleLabel = UILabel()
            titleLabel.textColor = .white
            titleLabel.font = .systemFont(ofSize: 20)
            stack.addArrangedSubview(titleLabel)
            
            let valueLabel = UILabel()
            valueLabel.textColor = .white
            valueLabel.font = .systemFont(ofSize: 20, weight: .bold)
            valueLabel.textAlignment = .right
            stack.addArrangedSubview(valueLabel)
            
            switch i{
            case 0:
                titleLabel.text = "Username: "
                if let name = user.login{
                    valueLabel.text = name
                }else{
                    valueLabel.text = "Not Available" }
            case 1:
                titleLabel.text = "Followers Detail: "
                if let name = user.followers_url{
                    valueLabel.text = "See Details"
                    valueLabel.textColor = .blue
                    
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(seeFollowerDetails))
                    valueLabel.isUserInteractionEnabled = true
                    valueLabel.addGestureRecognizer(tapGesture)
                }else{
                    valueLabel.text = "Not Available" }
            case 2:
                titleLabel.text = "Location: "
                if let name = user.location{
                    valueLabel.text = name
                }else{
                    valueLabel.text = "Not Available" }
            case 3:
                titleLabel.text = "Name: "
                if let name = user.name{
                    valueLabel.text = name}
                else{ valueLabel.text = "Not Available"}
            case 4:
                titleLabel.text = "Public Repos: "
                if let name = user.public_repos{
                    valueLabel.text = "\(name)"}
                else{ valueLabel.text = "Not Available"}
            case 5:
                titleLabel.text = "Public Gists: "
                if let name = user.public_gists{
                    valueLabel.text = "\(name)"}
                else{ valueLabel.text = "Not Available"}
            case 6:
                titleLabel.text = "Followers: "
                if let name = user.followers{
                    valueLabel.text = "\(name)"}
                else{ valueLabel.text = "Not Available"}
            case 7:
                titleLabel.text = "Updated At: "
                if let name = user.updated_at{
                    
                    let inputDateFormatter = DateFormatter()
                    inputDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    let inputDate = inputDateFormatter.date(from: name)

                    let outputDateFormatter = DateFormatter()
                    outputDateFormatter.dateStyle = .medium
                    outputDateFormatter.timeStyle = .short
                    let date = outputDateFormatter.string(from: inputDate ?? Date())
                    
                    valueLabel.text = date}
                else{ valueLabel.text = "Not Available"}
            default: break
            }
            
            stackView.addArrangedSubview(stack)
        }
    }
    
    private func fetchImage(){
        guard let imageUrl = user.avatar_url, let url = URL(string: imageUrl) else {return}
        profilePic.sd_setImage(with: url)
    }
}
