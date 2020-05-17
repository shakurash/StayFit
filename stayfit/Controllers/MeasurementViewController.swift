//
//  MeasurementViewController.swift
//  stayfit
//
//  Created by Robert on 16/05/2020.
//  Copyright © 2020 Robert. All rights reserved.
//

import UIKit
import RealmSwift

class MeasurementViewController: UIViewController {

    @IBOutlet weak var massPickerLabel: UITextField!
    @IBOutlet weak var datePickerLabel: UIDatePicker!
    
    let realm = try! Realm()
    let dataSource = DataSource()
    let updateMethods = UpdateMethods()
    var measurementDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myProfile = realm.objects(ProfileModel.self).first
        if let myDate = myProfile?.startDate {
            datePickerLabel.minimumDate = myDate
            datePickerLabel.maximumDate = Date()
        }
        datePickerLabel.addTarget(self, action: #selector(MeasurementViewController.dateValueChanged), for: .valueChanged)
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
        if let date = measurementDate {
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let measureData = dateFormatter.string(from: date)
            //updateMethods.saveData(dataToSave: measureData, id: "measureData") dodac info o wadze
        }
    }
}
