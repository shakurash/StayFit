//
//  DishSetupViewController.swift
//  stayfit
//
//  Created by Robert on 07/05/2020.
//  Copyright © 2020 Robert. All rights reserved.
//

import UIKit
import RealmSwift

class DishSetupViewController: UIViewController {
    
    @IBOutlet weak var alarmCheck: UISwitch!
    @IBOutlet weak var przystawkaCheckBox: CheckBox!
    @IBOutlet weak var sniadanieCheckBox: CheckBox!
    @IBOutlet weak var drugieSniadanieCheckBox: CheckBox!
    @IBOutlet weak var deserCheckBox: CheckBox!
    @IBOutlet weak var obiadCheckBox: CheckBox!
    @IBOutlet weak var lunchCheckBox: CheckBox!
    @IBOutlet weak var drugieDanieCheckBox: CheckBox!
    @IBOutlet weak var przekaskaCheckBox: CheckBox!
    @IBOutlet weak var kolacjaCheckBox: CheckBox!

    @IBOutlet var timerDisplayLabel: [UILabel]!
    @IBOutlet var stepperValues: [UIStepper]!
    
    let updateMethods = UpdateMethods()
    let realm = try! Realm()
    let dataSource = DataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let obj = realm.objects(ProfileModel.self).first {
            przystawkaCheckBox.isChecked = obj.przystawka
            sniadanieCheckBox.isChecked = obj.sniadanie
            drugieSniadanieCheckBox.isChecked = obj.drugieSniadanie
            deserCheckBox.isChecked = obj.deser
            obiadCheckBox.isChecked = obj.obiad
            lunchCheckBox.isChecked = obj.lunch
            drugieDanieCheckBox.isChecked = obj.drugiObiad
            przekaskaCheckBox.isChecked = obj.przekaska
            kolacjaCheckBox.isChecked = obj.kolacja
            alarmCheck.isOn = obj.setAlarm
            
            updateView(with: dataSource.refreshDishLabels(steppers: stepperValues))
            updateView(with: dataSource.refreshDishLabels(steppers: timerDisplayLabel))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let loadProfileData = realm.objects(ProfileModel.self).first {
            loadProfileData.lightMode ? (overrideUserInterfaceStyle = .light) : (overrideUserInterfaceStyle = .dark)
        }
    }
    
    func updateView(with: [Any]) {
        let timeArray = with
        if timeArray is [UIStepper] {
            for oldValue in stepperValues {
                oldValue.value = (timeArray[Int(oldValue.tag)] as! UIStepper).value
            }
        } else if timeArray is [UILabel] {
            for oldValue in timerDisplayLabel {
                oldValue.text = (timeArray[oldValue.tag] as! UILabel).text
            }
        }
    }
    
    @IBAction func dinnerCheckButton(_ sender: CheckBox) {
        let button = sender.tag
        var index = sender.isChecked
        switch button {
        case 0: index = !index
        case 1: index = !index
        case 2: index = !index
        case 3: index = !index
        case 4: index = !index
        case 5: index = !index
        case 6: index = !index
        case 7: index = !index
        case 8: index = !index
        default: fatalError("no button was found")
        }
        updateMethods.saveData(dataToSave: index, id: String(button))
    }
    
    @IBAction func alarmCheck(_ sender: UISwitch) {
        let status = sender.isOn
        updateMethods.saveData(dataToSave: status, id: "setAlarm")
    }
    
    @IBAction func stepperPressed(_ sender: UIStepper) {
        if let label = timerDisplayLabel {
            label[sender.tag].text = String(Int(sender.value)) + ":00"
            if let timeSaved = label[sender.tag].text{
            updateMethods.saveData(dataToSave: timeSaved, id: "\(sender.tag)")
            }
        }
    }
}
