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
                if realm.objects(ProfileModel.self).first == nil{
                    realm.add(profileModel)
                } 
            }
        } catch {
            print(error)
        }
        performSegue(withIdentifier: "FromStartToEditProfile", sender: sender)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        view.setupbackground(imageViewName: "LogoBackground")
        if (realm.objects(ProfileModel.self).first != nil) {
              let myProfile = realm.objects(ProfileModel.self).first
            if (myProfile?.lightMode) != nil { //check if profile have info about dark mode and set it to navigationBar if not then check for user style preferences
                myProfile!.lightMode ? (navigationController?.navigationBar.barTintColor = UIColor(named: "SecondaryColor")):(navigationController?.navigationBar.barTintColor = UIColor(named: "NavigationBarColor"))
            } else {
                overrideUserInterfaceStyle == .light ? (navigationController?.navigationBar.barTintColor = UIColor(named: "SecondaryColor")):(navigationController?.navigationBar.barTintColor = UIColor(named: "NavigationBarColor"))
            }
        }
    }
}
