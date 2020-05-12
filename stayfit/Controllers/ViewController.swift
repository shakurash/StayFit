//
//  ViewController.swift
//  stayfit
//
//  Created by Robert on 07/05/2020.
//  Copyright © 2020 Robert. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    let profileModel = ProfileModel()
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    @IBAction func createProfilePressed(_ sender: UIButton) {
        do {
            try realm.write {
                realm.add(profileModel)
            }
        } catch {
            print(error)
        }
        performSegue(withIdentifier: "FromStartToEditProfile", sender: sender)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (realm.objects(ProfileModel.self).first != nil) {
            performSegue(withIdentifier: "FromStartToMainMenu", sender: self)
        }
    }
}

