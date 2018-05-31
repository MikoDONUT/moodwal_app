//
//  ViewController.swift
//  moodwalk_test
//
//  Created by Matias GOMEZ on 24/05/2018.
//  Copyright © 2018 ByWe. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    var animated=false
    
    @IBOutlet weak var search_bar: UISearchBar!
    @IBOutlet weak var warning_text: UITextField!
    @IBOutlet weak var search_button: UIButton!
    @IBOutlet weak var avatar_image: UIImageView!
    @IBOutlet weak var user_name_label: UILabel!
    @IBOutlet weak var tableView: UITableView!
        
    var mytab = [String]()
    var descpTab = [String]()
    let regex_avatar = "https://avatars[0-9]+.githubusercontent.com/u/[0-9]*[?]v=4"
    let regex_name = "(.)name(.)= (.)(.*)(.)"
    let first_error = "{\n    \"documentation_url\" = \"https://developer.github.com/v3/repos/#list-user-repositories\";\n    message = \"Not Found\";\n}"
    let second_error = "(\n)"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        search_button.layer.cornerRadius=6
        tableView.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print("passe par le return count")
        return mytab.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //give the number of rows
        return mytab.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //display data
        let cellIdentifier = "cellule"
        print("passe Fin tableView 1")
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        print("passe Fin tableView 2")
        cell.textLabel?.text = mytab[indexPath.row]
        print("passe Fin tableView 3")
        cell.detailTextLabel?.text = descpTab[indexPath.row]
        print("passe Fin tableView 4")
        return cell
    }
    
    
    func def_avatar(myJson_convert: String){
        do{
            print("In the def_avatar function")
            //search the avatar link
            let regex1 = try NSRegularExpression(pattern: regex_avatar)
            let results1 = regex1.matches(in: myJson_convert, range: NSRange(myJson_convert.startIndex..., in: myJson_convert))
            let url_avatar = results1.map { String(myJson_convert[Range($0.range, in: myJson_convert)!]) }
            let url:URL = URL(string: url_avatar[0])!
            let session = URLSession.shared
            let task_image = session.dataTask(with: url, completionHandler: {(data, response, error) in
                if data != nil{
                    let image = UIImage(data: data!)
                    if image != nil {
                        //Display the avatar
                        self.avatar_image.image = image
                    }
                }
            })
            //Display the username
            self.user_name_label.backgroundColor = UIColor.black
            self.user_name_label.text = self.search_bar.text
            task_image.resume()
            print("Fin avatar")
        }
        catch{
            print("ERROR : Avatar display")
        }
    }
    
    
    func def_name_repositories(myJson_convert: String){
        do{
            print("In the def_name_repositories function")
            //search the user repositories
            let regex = try NSRegularExpression(pattern: regex_name)
            let results = regex.matches(in: myJson_convert, range: NSRange(myJson_convert.startIndex..., in: myJson_convert))
            var name_repository = results.map { String(myJson_convert[Range($0.range, in: myJson_convert)!]) }
            print("Nombre de name repos : " + String(name_repository.count)) //nombre de nom de repos
            var i = 0
            var j = 0
            while i < name_repository.count {
                j = i + 1
                var part_name = name_repository[i].split(separator: "=")
                while j < name_repository.count {
                    if name_repository[i] == name_repository[j] {
                        print("time to remove")
                        name_repository.remove(at: j)
                    }
                    j += 1
                }
                j = 0
                name_repository[i] = String(part_name[1].characters.dropLast())
                print("Deuxième partie de name : " + name_repository[i])
                i += 1
                
            }
            print("Nombre de name repos après trie : " + String(name_repository.count)) //nombre de nom de repos après le trie
            mytab = name_repository
        }
        catch{
            print("ERROR : Name repositories display")
        }
        print("Fin name")
    }
    
    
    func def_desc_repositories(myJson_convert: String){
        do{
            //Search the description repositories
            let regex = try NSRegularExpression(pattern: "(.)description(.)= (.)*")
            let results = regex.matches(in: myJson_convert, range: NSRange(myJson_convert.startIndex..., in: myJson_convert))
            let desc_repository = results.map { String(myJson_convert[Range($0.range, in: myJson_convert)!]) }
            print("Nombre de desc : " + String(desc_repository.count))
            var i = 0
            while i < desc_repository.count {
                var part_desc = desc_repository[i].split(separator: "=")
                var correct_desc = String(part_desc[1].characters.dropLast(2))
                correct_desc = String(correct_desc.characters.dropFirst(2))
                i += 1
                print(correct_desc)
            }
            descpTab = desc_repository
        }
        catch{
            print("ERROR : Description repositories display")
        }
        print("Fin desc")
    }
    
    
    func search_on_the_web(user_name: String){
        //Search user by url provided by API
        let url = URL(string: "https://api.github.com/users/" + user_name + "/repos")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print(error)
            }
            else{
                if let content = data {
                    do {
                        //Extract the JSON of the link
                        let myJson = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        let myJson_convert = String(describing: myJson)
                        self.def_avatar(myJson_convert: myJson_convert)
                        self.def_desc_repositories(myJson_convert: myJson_convert)
                        self.def_name_repositories(myJson_convert: myJson_convert)
                        print("Start reloadData")
                        self.tableView.reloadData()
                        print("End reloadData")
                        self.tableView.isHidden = false
                    }
                    catch {
                        print("error")
                    }
                }
            }
        }
        task.resume()
    }
    
    
    func verif_user (user_name: String) -> Bool{
        let url = URL(string: "https://api.github.com/users/" + user_name + "/repos")
        print(1)
        var existe : Bool!
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print(error)
            }
            else{
                if let content = data {
                    do {
                        let myJson = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        let myJson_convert = String(describing: myJson)
                        if myJson_convert == self.first_error || myJson_convert == self.second_error{
                            print("User doesn't exist")
                            existe = false
                        }
                        else{
                            existe = true
                        }
                    }
                    catch {
                        print("error")
                    }
                }
            }
        }
        task.resume()
        sleep(5)
        return existe
      }

    
    @IBAction func search_button_action(_ sender: Any) {
        if search_bar.text != "" && animated==false && verif_user(user_name: self.search_bar.text!){
            self.search_on_the_web(user_name: self.search_bar.text!)
            UIView.animate(withDuration: 1, animations:{
                self.search_bar.frame.origin.y-=220;
                self.search_button.frame.origin.y-=220;
                self.warning_text.frame.origin.y-=220;
            }, completion: nil)
            animated=true
            search_bar.barTintColor = UIColor.black;
        }
        else if search_bar.text != "" && animated==true && verif_user(user_name: self.search_bar.text!){
            search_bar.barTintColor = UIColor.black
            warning_text.text=""
            self.search_on_the_web(user_name: self.search_bar.text!)
        }
        else {
            search_bar.barTintColor = UIColor.red
            warning_text.text="WARNING : Wrong username"
        }
    }
    
}

