//
//  ViewController.swift
//  Github-Search
//
//  Created by Dhananjay Chhabra on 08/10/23.
//

import UIKit

class ViewController: UIViewController {
    
    private let logo: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "github")
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFit
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    private let textField: UITextField = {
        let field = UITextField()
        field.placeholder = "  Search Github ...  "
        field.backgroundColor = .white
        field.layer.cornerRadius = 10
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.leftView = paddingView
        field.leftViewMode = .always
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let getStartedButton: UIButton = {
        let button = UIButton()
        button.setTitle("Get Started", for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let searchButton: UIButton = {
        let button = UIButton()
        button.setTitle("Search", for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var logoTopConstraint: NSLayoutConstraint = NSLayoutConstraint()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        setUp()
        
        textField.delegate = self
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboad))
        view.addGestureRecognizer(gesture)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchButton.isEnabled = true
    }

}


// MARK: - Textfield Delegate Methods
extension ViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.logoTopConstraint.constant = 100
        self.textField.becomeFirstResponder()
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
}


// MARK: - Setup Methods
extension ViewController{
    func setUp(){
        view.addSubview(logo)
        logo.image = logo.image?.withRenderingMode(.alwaysTemplate)
        logo.tintColor = .white
        logoTopConstraint = logo.topAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.height/4)
        NSLayoutConstraint.activate([
            logo.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            logo.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            logoTopConstraint,
            logo.heightAnchor.constraint(equalToConstant: view.bounds.height/4)
        ])
        view.addSubview(getStartedButton)
        NSLayoutConstraint.activate([
            getStartedButton.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 50),
            getStartedButton.heightAnchor.constraint(equalToConstant: 50),
            getStartedButton.widthAnchor.constraint(equalToConstant: view.bounds.width/2),
            getStartedButton.centerXAnchor.constraint(equalTo: logo.centerXAnchor)
        ])
        getStartedButton.addTarget(self, action: #selector(getStarted), for: .touchUpInside)

    }
}

// MARK: - @objc Functions
extension ViewController{
    @objc func dismissKeyboad(){
        textField.resignFirstResponder()
        
        logoTopConstraint.constant = view.bounds.height/4
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func searchGithub(){
        searchButton.isEnabled = false
        
        guard let query = textField.text else {return}
        guard let url = URL(string: "https://api.github.com/search/users?q=\(query)&page=1") else {return}
        URLSession.shared.dataTask(with: URLRequest(url: url)){ data, _, error in
            guard let data = data, error == nil else{ return }
            do{
                let results = try JSONDecoder().decode(SearchResult.self, from: data)
                DispatchQueue.main.async {
                    let vc = SearchResultsViewController(searchResult: results, query: query)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }catch(let error){
                print(error.localizedDescription)
            }
        }.resume()
        
    }
    
    @objc func getStarted(){
        
        getStartedButton.removeFromSuperview()
    
        view.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 50),
            textField.heightAnchor.constraint(equalToConstant: 50),
            textField.widthAnchor.constraint(equalToConstant: view.bounds.width * 0.8),
            textField.centerXAnchor.constraint(equalTo: logo.centerXAnchor)
        ])
        
        view.addSubview(searchButton)
        NSLayoutConstraint.activate([
            searchButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 50),
            searchButton.heightAnchor.constraint(equalToConstant: 50),
            searchButton.widthAnchor.constraint(equalToConstant: view.bounds.width/2),
            searchButton.centerXAnchor.constraint(equalTo: logo.centerXAnchor)
        ])
        
        searchButton.addTarget(self, action: #selector(searchGithub), for: .touchUpInside)
        
        
        self.logoTopConstraint.constant = 100
        self.textField.becomeFirstResponder()
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
}
