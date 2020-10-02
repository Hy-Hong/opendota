//
//  ViewController.swift
//  Opendota
//
//  Created by Hy Horng on 10/1/20.
//  Copyright © 2020 Hy Horng. All rights reserved.
//

import UIKit
import SDWebImage


extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIView.ContentMode = .scaleAspectFill) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}

struct Hero: Decodable {
    let localized_name: String
    let roles: [String]
    let move_speed: Int
    let img: String
    let icon: String
}

class HeaderView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .cyan
        let headerImage = UIImageView(image: UIImage(named: "sreymun"))
        headerImage.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(headerImage)
        
        headerImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        headerImage.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        headerImage.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        headerImage.heightAnchor.constraint(equalToConstant: 200).isActive = true
        headerImage.contentMode = .scaleAspectFill
        
        
        


    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ViewController: UIViewController {
    
    

    @IBOutlet var collectionView: UICollectionView!
    
    let reuseIditifire = "cellID"
    var fullRole = String()
    var heroes = [Hero]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        
        view.backgroundColor = .black

        let headerView = HeaderView()
        headerView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(headerView)
        headerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        headerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        headerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: 200).isActive = true

//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "sreymun")?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch), for: .default)
        
        
        collectionView.delegate = self
        collectionView.dataSource = self
        // declear a variable to store url
        let urlString = URL(string: "https://api.opendota.com/api/heroStats")
        URLSession.shared.dataTask(with: urlString!) { (data, response, error) in
            if error == nil {
                do {
                    self.heroes = try JSONDecoder().decode([Hero].self, from: data!)
                }catch {
                    print("Parse Error")
                }
                DispatchQueue.main.sync {
                    self.collectionView.reloadData()
                }
            }
        }.resume()
    }
}



extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // to hide border on navigationBar
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 1. hide the shadow image in the current view controller you want it hidden in
        navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        navigationController?.navigationBar.layoutIfNeeded()
        
        // To custom navigationBar image
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default) //UIImage.init(named: "transparent.png")
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return heroes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIditifire, for: indexPath) as! CustomCollectionViewCell
        
//        cell.roleLbl.text = heroes[indexPath.item].roles[0]
        fullRole = ""
        for role in heroes[indexPath.item].roles {
            fullRole += " " + role
        }
        
        cell.roleLbl.text = fullRole
        
        cell.nameLbl.text = heroes[indexPath.item].localized_name.capitalized
        cell.speedLbl.text = "\( heroes[indexPath.item].move_speed)"
        cell.imageView.contentMode = .scaleAspectFill
        //Get imageView
        let defualtLink = "https://api.opendota.com"
        let imageLink = defualtLink + heroes[indexPath.item].img
//        cell.imageView.downloadedFrom(link: imageLink)
        cell.imageView.sd_setImage(with: URL(string: imageLink), placeholderImage: nil)
        cell.imageView.sd_imageIndicator = SDWebImageActivityIndicator.white
        
        //Get iconImage
        let iconLink = defualtLink + heroes[indexPath.item].icon
//        cell.iconImage.downloadedFrom(link: iconLink)
        cell.iconImage.sd_setImage(with: URL(string: iconLink), placeholderImage: nil)
        //Editor
        cell.nameLbl.textColor = .blue
        cell.speedLbl.textColor = .green
        cell.layer.cornerRadius = 5
        cell.backgroundColor = .gray
        cell.imageView.layer.cornerRadius = 5
        return cell
    }
}

