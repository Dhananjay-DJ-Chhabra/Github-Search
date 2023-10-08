//
//  ProfilesTableViewCell.swift
//  Github-Search
//
//  Created by Dhananjay Chhabra on 08/10/23.
//

import UIKit

class ProfilesTableViewCell: UITableViewCell {
    
    static let identifier = "ProfilesTableViewCell"
    
    private var profilePic: UIImageView = {
        let imgView = UIImageView()
        imgView.clipsToBounds = true
        imgView.contentMode = .scaleAspectFill
        imgView.layer.cornerRadius = 25
        imgView.backgroundColor = .gray
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    private let userName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUp()
    }
    
    private func setUp(){
        contentView.addSubview(profilePic)
        contentView.addSubview(userName)
        
        NSLayoutConstraint.activate([
            profilePic.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            profilePic.heightAnchor.constraint(equalToConstant: 50),
            profilePic.widthAnchor.constraint(equalToConstant: 50),
            profilePic.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            profilePic.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
        ])
        
        NSLayoutConstraint.activate([
            userName.leadingAnchor.constraint(equalTo: profilePic.trailingAnchor, constant: 20),
            userName.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            userName.centerYAnchor.constraint(equalTo: profilePic.centerYAnchor)
        ])
    }
    
    func configureCell(url: String?, username: String?){
        if let urlString = url, let url = URL(string: urlString), let username = username{
            profilePic.sd_setImage(with: url)
            userName.text = username
        }else{ userName.text = "Not Available"}
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
