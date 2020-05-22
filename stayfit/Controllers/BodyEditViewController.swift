//
//  BodyEditViewController.swift
//  stayfit
//
//  Created by Robert on 07/05/2020.
//  Copyright © 2020 Robert. All rights reserved.
//

import UIKit
import RealmSwift

class BodyEditViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var profileNameTextLabel: UITextField!
    @IBOutlet weak var profileMassTextLabel: UITextField!
    @IBOutlet weak var profileHeightTextLabel: UITextField!
    @IBOutlet weak var profileTargetTextLabel: UITextField!
    @IBOutlet weak var profileDatePickerTextLabel: UITextField!
    @IBOutlet weak var lightModeSwitch: UISwitch!
    @IBOutlet weak var dayIntenseSelectorDisplay: UISegmentedControl!
    @IBOutlet weak var genderSelectorDisplay: UISegmentedControl!
    @IBOutlet weak var tempoSelectorDisplay: UISegmentedControl!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var intenseLabel: UILabel!
    @IBOutlet weak var massLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var tempoLabel: UILabel!
    @IBOutlet weak var lightModeLabel: UILabel!
    
    @IBOutlet weak var nameLabelStack: UIStackView!
    @IBOutlet weak var massLabelStack: UIStackView!
    @IBOutlet weak var heightLabelStack: UIStackView!
    @IBOutlet weak var ageLabelStack: UIStackView!
    @IBOutlet weak var genderLabelStack: UIStackView!
    @IBOutlet weak var targetLabelStack: UIStackView!
    @IBOutlet weak var lightModeLabelStack: UIStackView!
    
    private var datePicker = UIDatePicker()
    private var numberPicker = UIPickerView()
    
    private var toolBar = UIToolbar()
    private var toolButtonDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(endEditing))
    private var toolConstrains = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    
    let dataSource = DataSource()
    let updateMethods = UpdateMethods()
    let realm = try! Realm()
    var myProfile: ProfileModel?
    var vcID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let profileModel = realm.objects(ProfileModel.self).first
        myProfile = profileModel
        
        lightModeSwitch.addTarget(self, action: #selector(BodyEditViewController.switchChanged), for: UIControl.Event.valueChanged)
        profileNameTextLabel.addTarget(self, action: #selector(BodyEditViewController.textFieldDidChange(_:)), for: .editingChanged)
        
        datePicker.datePickerMode = .date
        datePicker.locale = Locale.current
        profileDatePickerTextLabel.inputView = datePicker
        
        profileMassTextLabel.inputView = numberPicker
        profileHeightTextLabel.inputView = numberPicker
        profileTargetTextLabel.inputView = numberPicker
        
        numberPicker.delegate = self
        profileNameTextLabel.delegate = self
        profileMassTextLabel.delegate = self    //set delegates to PickerViews to disable writing (confuses user if enabled)
        profileHeightTextLabel.delegate = self
        profileTargetTextLabel.delegate = self
        
        toolBar.sizeToFit()
        toolBar.tintColor = UIColor(named: "PrimaryColor")
        toolBar.setItems([toolConstrains, toolButtonDone], animated: true)
        
        profileDatePickerTextLabel.inputAccessoryView = toolBar
        profileMassTextLabel.inputAccessoryView = toolBar
        profileTargetTextLabel.inputAccessoryView = toolBar
        profileHeightTextLabel.inputAccessoryView = toolBar
        
        navigationItem.hidesBackButton = true
    }

    //MARK: - saving method and update profile with PPM CPM
    
    @IBAction func saveProfilePressed(_ sender: UIBarButtonItem) {
        if profileDatePickerTextLabel.text != ""{
            let profileTimeStart = Date()
            updateMethods.saveData(dataToSave: profileTimeStart)
            performSegue(withIdentifier: "FromEditProfileToMainMenu", sender: self)
        } else {
            let alert = UIAlertController(title: "Alert", message: NSLocalizedString("Proszę podać datę urodzenia", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil ))
            alert.view.tintColor = UIColor(named: "PrimaryColor")
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - loading values to fetch data from profile
    
    override func viewWillAppear(_ animated: Bool) {
        if let loadProfileData = realm.objects(ProfileModel.self).first {
            loadProfileData.lightMode ? (overrideUserInterfaceStyle = .light) : (overrideUserInterfaceStyle = .dark)
            profileNameTextLabel.text = loadProfileData.name
            profileMassTextLabel.text = String(loadProfileData.mass)
            profileTargetTextLabel.text = String(loadProfileData.target)
            profileHeightTextLabel.text = String(loadProfileData.height)
            lightModeSwitch.isOn = loadProfileData.lightMode
            if loadProfileData.date != "01/01/1000" {
                profileDatePickerTextLabel.text = loadProfileData.date
            }
            dayIntenseSelectorDisplay.selectedSegmentIndex = setProperIndex(data: loadProfileData.dayIntense)
            genderSelectorDisplay.selectedSegmentIndex = setProperIndex(gender: loadProfileData.gender)
            tempoSelectorDisplay.selectedSegmentIndex = setProperIndex(tempo: loadProfileData.tempo)
            
    //MARK: - setup the animation
            
            nameLabelStack.alpha = 0.0
            massLabelStack.alpha = 0.0
            heightLabelStack.alpha = 0.0
            ageLabelStack.alpha = 0.0
            genderLabelStack.alpha = 0.0
            targetLabelStack.alpha = 0.0
            tempoLabel.alpha = 0.0
            lightModeLabelStack.alpha = 0.0
            
            nameLabel.alpha = 0.0
            intenseLabel.alpha = 0.0
            massLabel.alpha = 0.0
            heightLabel.alpha = 0.0
            ageLabel.alpha = 0.0
            genderLabel.alpha = 0.0
            targetLabel.alpha = 0.0
            lightModeLabel.alpha = 0.0
            
            self.dayIntenseSelectorDisplay.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
            self.genderSelectorDisplay.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
            self.tempoSelectorDisplay.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        }
    }
    
    //MARK: - animation block
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.1){
            self.nameLabelStack.isHidden = false
            self.nameLabelStack.alpha = 1.0
        }
        UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseOut, animations: {
            self.nameLabel.alpha = 1.0
        })
        UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseOut, animations: {
            self.intenseLabel.alpha = 1.0
        })
        UIView.animate(withDuration: 0.5, delay: 0.3, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
            self.dayIntenseSelectorDisplay.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
        UIView.animate(withDuration: 0.5, delay: 0.4, options: .curveEaseOut, animations: {
            self.massLabelStack.alpha = 1.0
        })
        UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseOut, animations: {
            self.massLabel.alpha = 1.0
            self.heightLabelStack.alpha = 1.0
        })
        UIView.animate(withDuration: 0.5, delay: 0.6, options: .curveEaseOut, animations: {
            self.heightLabel.alpha = 1.0
            self.ageLabelStack.alpha = 1.0
        })
        UIView.animate(withDuration: 0.5, delay: 0.7, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
            self.genderSelectorDisplay.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
        UIView.animate(withDuration: 0.5, delay: 0.7, options: .curveEaseOut, animations: {
            self.ageLabel.alpha = 1.0
            self.genderLabelStack.alpha = 1.0
        })
        UIView.animate(withDuration: 0.5, delay: 0.8, options: .curveEaseOut, animations: {
            self.genderLabel.alpha = 1.0
            self.targetLabelStack.alpha = 1.0
        })
        UIView.animate(withDuration: 0.5, delay: 0.9, options: .curveEaseOut, animations: {
            self.targetLabel.alpha = 1.0
            self.tempoLabel.alpha = 1.0
        })
        UIView.animate(withDuration: 0.5, delay: 1.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
            self.tempoSelectorDisplay.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
        UIView.animate(withDuration: 0.5, delay: 1.1, options: .curveEaseOut, animations: {
            self.lightModeLabel.alpha = 1.0
        })
        UIView.animate(withDuration: 0.5, delay: 1.2, options: .curveEaseOut, animations: {
            self.lightModeLabelStack.alpha = 1.0
        })
    }
    
    func setProperIndex(data: Double? = nil, gender: String? = nil, tempo: String? = nil) -> Int {
        var index: Int?
        if data != nil {
            switch data {
            case 1.2: index = 0
            case 1.4: index = 1
            case 1.7: index = 2
            case 2.0: index = 3
            case 2.4: index = 4
            default:
                index = 0
            }
        }
        if gender != nil {
            switch gender {
            case "MALE": index = 0
            case "FEMALE": index = 1
            default:
                index = 0
            }
        }
        if tempo != nil {
            switch tempo {
            case "slow": index = 0
            case "medium": index = 1
            case "fast": index = 2
            default:
                index = 0
            }
        }
        return index ?? 0
    }
    
    
    //MARK: - textfield delegate methods for profileNameTextLabel
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        profileNameTextLabel.endEditing(true)
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let securedName = textField.text {
            updateMethods.saveData(dataToSave: securedName, id: "profileName")
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == profileMassTextLabel || textField == profileTargetTextLabel || textField == profileHeightTextLabel {
            return false
        }
        return true
    }
    
    //MARK: - datepicker format preparation
    
    @objc func dateChanged() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        profileDatePickerTextLabel.text = formatter.string(from: datePicker.date)
        if let securedData = profileDatePickerTextLabel.text {
            updateMethods.saveData(dataToSave: securedData, id: "profileDate" )
        }
    }
    
    @objc func endEditing() {
        if profileDatePickerTextLabel.isFirstResponder {
            dateChanged()
            view.endEditing(true)
        } else {
            view.endEditing(true)
        }
    }
    
    //MARK: - mass, target and height pickers setup
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.numberPicker.reloadAllComponents()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if profileMassTextLabel.isFirstResponder || profileTargetTextLabel.isFirstResponder {
            return dataSource.profileMass.count
        } else {
            return dataSource.profileHeight.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if profileMassTextLabel.isFirstResponder || profileTargetTextLabel.isFirstResponder {
            return String(dataSource.profileMass[row])
        } else {
            return String(dataSource.profileHeight[row])
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var id = String()
        var data = Int()
        if profileMassTextLabel.isFirstResponder {
            profileMassTextLabel.text = String(dataSource.profileMass[row]) + " KG"
            id = "profileMass"
            data = dataSource.profileMass[row]
        } else if profileTargetTextLabel.isFirstResponder {
            profileTargetTextLabel.text = String(dataSource.profileMass[row]) + " KG"
            id = "profileTarget"
            data = dataSource.profileMass[row]
        } else if profileHeightTextLabel.isFirstResponder {
            profileHeightTextLabel.text = String(dataSource.profileHeight[row]) + " CM"
            id = "profileHeight"
            data = dataSource.profileHeight[row]
        } else {
            fatalError("brak lejbelu dla pickerview - cos poszlo nie tak (BodyEditViewController)")
        }
        updateMethods.saveData(dataToSave: data, id: id)
    }
    
    //MARK: - segmented controllers setup
    
    @IBAction func dayIntensePressed(_ sender: UISegmentedControl) {
        
        if sender.tag == 0 {
        let intensity: Double?
        switch sender.selectedSegmentIndex {
        case 0: intensity = 1.2
        case 1: intensity = 1.4
        case 2: intensity = 1.7
        case 3: intensity = 2.0
        case 4: intensity = 2.4
        default:
            fatalError("wybrano opcje za skalą (BodyEditViewController)")
        }
        if let securedIntense = intensity {
        updateMethods.saveData(dataToSave: securedIntense, id: "profileDayIntense")
        }
        } else if sender.tag == 1 {
            var gender: String?
            switch sender.selectedSegmentIndex {
            case 0: gender = "MALE"
            case 1: gender = "FEMALE"
            default:
                fatalError("no gender")
            }
            if let securedGender = gender {
                updateMethods.saveData(dataToSave: securedGender, id: "profileGender")
            }
        } else {
            let tempo: String?
            switch sender.selectedSegmentIndex {
            case 0: tempo = "slow"
            case 1: tempo = "medium"
            case 2: tempo = "fast"
            default:
                fatalError("no valid tempo")
            }
            if let securedTempo = tempo {
              updateMethods.saveData(dataToSave: securedTempo, id: "profileTempo")
            }
        }
    }
    
    @objc func switchChanged() {
        let status: Bool?
        if lightModeSwitch.isOn {
            status = true
            overrideUserInterfaceStyle = .light
            navigationController?.navigationBar.barTintColor = UIColor(named: "SecondaryColor")
        } else {
            status = false
            overrideUserInterfaceStyle = .dark
            navigationController?.navigationBar.barTintColor = UIColor(named: "NavigationBarColor")
        }
        if let securedStatus = status {
            updateMethods.saveData(dataToSave: securedStatus, id: "profileMode")
        }
    }
}
