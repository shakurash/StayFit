//
//  MeasurementViewController.swift
//  stayfit
//
//  Created by Robert on 16/05/2020.
//  Copyright © 2020 Robert. All rights reserved.
//

import UIKit
import RealmSwift

class MeasurementViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    
    @IBOutlet weak var datePickerLabelStack: UIStackView!
    
    @IBOutlet weak var datePickerLabel: UIDatePicker!
    @IBOutlet weak var newMassPicker: UITextField!
    
    let realm = try! Realm()
    let dataSource = DataSource()
    let updateMethods = UpdateMethods()
    let profileModel = ProfileModel()
    let measureModel = MeasurementsData()
    var measurementDate: Date?
    
    private var numberPicker = UIPickerView()
    private var toolBar = UIToolbar()
    private var toolButtonDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(endEditing))
    private var toolConstrains = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newMassPicker.inputView = numberPicker
        toolBar.sizeToFit()
        toolBar.tintColor = UIColor(named: "PrimaryColor")
        toolBar.setItems([toolConstrains, toolButtonDone], animated: true)
        newMassPicker.inputAccessoryView = toolBar
        numberPicker.delegate = self
        newMassPicker.delegate = self
        
        let myProfile = realm.objects(ProfileModel.self).first
        if let myDate = myProfile?.startDate {
            datePickerLabel.minimumDate = myDate
            datePickerLabel.maximumDate = Date()
        }
        datePickerLabel.addTarget(self, action: #selector(MeasurementViewController.dateValueChanged), for: .valueChanged)
        measurementDate = datePickerLabel.date //load current day at beginning (more natural for user experience)
    }
    
    //MARK: - setup for animation
    override func viewWillAppear(_ animated: Bool) {
         if let loadProfileData = realm.objects(ProfileModel.self).first {
                   loadProfileData.lightMode ? (overrideUserInterfaceStyle = .light) : (overrideUserInterfaceStyle = .dark)
        }
        
        topLabel.alpha = 0.0
        bottomLabel.alpha = 0.0
        newMassPicker.alpha = 0.0
        datePickerLabelStack.alpha = 0.0
        datePickerLabel.transform = CGAffineTransform(scaleX: 1.0, y: 0.0)
    }
    
    //MARK: - animation execute
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
            self.topLabel.alpha = 1.0
        })
        UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseOut, animations: {
            self.newMassPicker.alpha = 1.0
        })
        UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseOut, animations: {
            self.bottomLabel.alpha = 1.0
        })
        UIView.animate(withDuration: 0.5, delay: 0.3, options: .curveEaseOut, animations: {
            self.datePickerLabelStack.alpha = 1.0
            self.datePickerLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    // delegate methods
    @objc func dateValueChanged(_ sender: UIDatePicker) {
        measurementDate = datePickerLabel.date
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    
    //MARK: - save method and validation - if its exist then user choice to override
    @IBAction func saveMeasurementPressed(_ sender: UIBarButtonItem) {
        if let date = measurementDate, let mass = newMassPicker.text {
            let measureMass = mass.dropLast(3)
            let newestMeasurements = measureModel
            let stringMass = String(measureMass)
            if let securedMass = Int(stringMass) {
            newestMeasurements.newestMass = Int(securedMass)
            newestMeasurements.date = date
            validateCurrentData(dateToCheck: newestMeasurements) //check if data to save isnt already in memory. If yes -> ask user if he wants to override
            } else {
                let alert = UIAlertController(title: NSLocalizedString("Brak wagi", comment: ""), message: NSLocalizedString("Proszę podać poprawną wartość", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                alert.view.tintColor = UIColor(named: "PrimaryColor")
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    func validateCurrentData(dateToCheck: MeasurementsData) {
        if let loadProfileData = realm.objects(ProfileModel.self).first {
            var foundRecord = false
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .none
            dateFormatter.dateStyle = .medium
            for date in loadProfileData.measureArray {
                let dateItemFromProfile = dateFormatter.string(from: date.date)
                let dateToLook = dateFormatter.string(from: dateToCheck.date)
                if dateItemFromProfile == dateToLook {
                        let alert = UIAlertController(title: NSLocalizedString("Taka data już istnieje!", comment: ""), message: NSLocalizedString("Czy chcesz nadpisać pomiar wagi?", comment: ""), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Nie", comment: ""), style: .default, handler: nil))
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Tak", comment: ""), style: .default, handler: {(alert: UIAlertAction!) in
                            self.updateMethods.saveData(dataToSave: dateToCheck, id: "override")
                            _ = self.navigationController?.popViewController(animated: true)}))
                        alert.view.tintColor = UIColor(named: "PrimaryColor")
                        self.present(alert, animated: true, completion: nil)
                    foundRecord = true
                }
            }
            if !foundRecord {
                self.updateMethods.saveData(dataToSave: dateToCheck)
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
//MARK: - mass, target and height pickers setup
func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
}

func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return dataSource.profileMass.count
}

func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return String(dataSource.profileMass[row])
}

func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        newMassPicker.text = String(dataSource.profileMass[row]) + " KG"
    }

    @objc func endEditing() {
        view.endEditing(true)
    }
}






