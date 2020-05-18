//
//  MeasurementViewController.swift
//  stayfit
//
//  Created by Robert on 16/05/2020.
//  Copyright © 2020 Robert. All rights reserved.
//

import UIKit
import RealmSwift

class MeasurementViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var massPickerLabel: UITextField!
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
        toolBar.setItems([toolConstrains, toolButtonDone], animated: true)
        newMassPicker.inputAccessoryView = toolBar
        numberPicker.delegate = self
        
        let myProfile = realm.objects(ProfileModel.self).first
        if let myDate = myProfile?.startDate {
            datePickerLabel.minimumDate = myDate
            datePickerLabel.maximumDate = Date()
        }
        datePickerLabel.addTarget(self, action: #selector(MeasurementViewController.dateValueChanged), for: .valueChanged)
        measurementDate = datePickerLabel.date
    }
    
    override func viewWillAppear(_ animated: Bool) {
         if let loadProfileData = realm.objects(ProfileModel.self).first {
                   loadProfileData.lightMode ? (overrideUserInterfaceStyle = .light) : (overrideUserInterfaceStyle = .dark)
        }
    }
    
    @objc func dateValueChanged() {
        measurementDate = datePickerLabel.date
    }
    
    @IBAction func saveMeasurementPressed(_ sender: UIBarButtonItem) {
        if let date = measurementDate, let mass = newMassPicker.text {
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone.current // need timezone of current PC or it will save bad date -/+ 24h
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let measureData = dateFormatter.string(from: date)
            let measureMass = mass.dropLast(3)
            let newestMeasurements = measureModel
            let stringMass = String(measureMass)
            if let securedMass = Int(stringMass) {
            newestMeasurements.newestMass = Int(securedMass)
            newestMeasurements.date = measureData
            validateCurrentData(dateToCheck: newestMeasurements) //check if data to save isnt already in memory. If yes -> ask user if he wants to override
            } else {
                let alert = UIAlertController(title: "Brak wagi", message: "Proszę podać poprawną wartość", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    func validateCurrentData(dateToCheck: MeasurementsData) {
        if let loadProfileData = realm.objects(ProfileModel.self).first {
            var foundRecord = false
            for date in loadProfileData.measureArray {
                if date.date == dateToCheck.date {
                        let alert = UIAlertController(title: "Taka data już istnieje!", message: "Czy chcesz nadpisać pomiar wagi?", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Nie", style: .default, handler: nil))
                        alert.addAction(UIAlertAction(title: "Tak", style: .default, handler: {(alert: UIAlertAction!) in
                            let sendDateToOverride = String(date.date)
                            self.updateMethods.saveData(dataToSave: dateToCheck, id: sendDateToOverride)
                            _ = self.navigationController?.popViewController(animated: true)}))
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
//    @objc func dateChanged() {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "dd/MM/yyyy"
//        profileDatePickerTextLabel.text = formatter.string(from: datePicker.date)
//        if let securedData = profileDatePickerTextLabel.text {
//            updateMethods.saveData(dataToSave: securedData, id: "profileDate" )
//        }
//    }





