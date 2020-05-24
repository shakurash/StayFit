//
//  DishSetupViewController.swift
//  stayfit
//
//  Created by Robert on 07/05/2020.
//  Copyright © 2020 Robert. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

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

    @IBOutlet weak var przystawkaStack: UIStackView!
    @IBOutlet weak var sniadanieStack: UIStackView!
    @IBOutlet weak var drugiesniadanieStack: UIStackView!
    @IBOutlet weak var deserStack: UIStackView!
    @IBOutlet weak var obiadStack: UIStackView!
    @IBOutlet weak var lunchStack: UIStackView!
    @IBOutlet weak var drugiedanieStack: UIStackView!
    @IBOutlet weak var przekaskaStack: UIStackView!
    @IBOutlet weak var kolacjaStack: UIStackView!
    @IBOutlet weak var bottomStack: UIStackView!
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet var timerDisplayLabel: [UILabel]!
    @IBOutlet var stepperValues: [UIStepper]!
    
    @IBOutlet weak var przystawkaRightStackCons: NSLayoutConstraint!
    @IBOutlet weak var sniadanieRightStackCons: NSLayoutConstraint!
    @IBOutlet weak var drugiesniadanieRightStackCons: NSLayoutConstraint!
    @IBOutlet weak var deserRightStackCons: NSLayoutConstraint!
    @IBOutlet weak var obiadRightStackCons: NSLayoutConstraint!
    @IBOutlet weak var lunchRightStackCons: NSLayoutConstraint!
    @IBOutlet weak var drugiedanieRightStackCons: NSLayoutConstraint!
    @IBOutlet weak var przekaskaRightStackCons: NSLayoutConstraint!
    @IBOutlet weak var kolacjaRightStackCons: NSLayoutConstraint!
    
    let updateMethods = UpdateMethods()
    let realm = try! Realm()
    let dataSource = DataSource()
    let notificationCenter = UNUserNotificationCenter.current()
    
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
        self.alarmCheck.isEnabled = false
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (userDidAccept, error) in //start once and ask user for notification
        if userDidAccept {
            DispatchQueue.main.async {
                self.alarmCheck.isEnabled = true
            }
        }
        }
        
        checkForNotifications() //starts everytime and check if user changed decision about notifications
//        notificationCenter.getPendingNotificationRequests { (not: [UNNotificationRequest]) in
//            print(not)
//        }
        
        if let loadProfileData = realm.objects(ProfileModel.self).first {
            loadProfileData.lightMode ? (overrideUserInterfaceStyle = .light) : (overrideUserInterfaceStyle = .dark)
            
    //MARK: - setup for animations
            
            topLabel.alpha = 0.0
            bottomStack.alpha = 0.0
            
            przystawkaStack.isHidden = true
            sniadanieStack.isHidden = true
            drugiesniadanieStack.isHidden = true
            deserStack.isHidden = true
            obiadStack.isHidden = true
            lunchStack.isHidden = true
            drugiedanieStack.isHidden = true
            przekaskaStack.isHidden = true
            kolacjaStack.isHidden = true
            
            przystawkaRightStackCons.constant -= view.bounds.width
            sniadanieRightStackCons.constant -= view.bounds.width
            drugiesniadanieRightStackCons.constant -= view.bounds.width
            deserRightStackCons.constant -= view.bounds.width
            obiadRightStackCons.constant -= view.bounds.width
            lunchRightStackCons.constant -= view.bounds.width
            drugiedanieRightStackCons.constant -= view.bounds.width
            przekaskaRightStackCons.constant -= view.bounds.width
            kolacjaRightStackCons.constant -= view.bounds.width
        }
    }
    
    //MARK:  - animations play
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.1){
            self.przystawkaStack.isHidden = false
        }
        przystawkaRightStackCons.constant = 160
        UIView.animate(withDuration: 0.1, delay: 0.1, options: .curveEaseOut, animations: {
            self.sniadanieStack.isHidden = false
            self.view.layoutIfNeeded()
        })
        sniadanieRightStackCons.constant = 160
        UIView.animate(withDuration: 0.1, delay: 0.2, options: .curveEaseOut, animations: {
            self.drugiesniadanieStack.isHidden = false
            self.view.layoutIfNeeded()
        })
        drugiesniadanieRightStackCons.constant = 160
        UIView.animate(withDuration: 0.1, delay: 0.3, options: .curveEaseOut, animations: {
            self.deserStack.isHidden = false
            self.view.layoutIfNeeded()
        })
        deserRightStackCons.constant = 160
        UIView.animate(withDuration: 0.1, delay: 0.4, options: .curveEaseOut, animations: {
            self.obiadStack.isHidden = false
            self.view.layoutIfNeeded()
        })
        obiadRightStackCons.constant = 160
        UIView.animate(withDuration: 0.1, delay: 0.5, options: .curveEaseOut, animations: {
            self.lunchStack.isHidden = false
            self.view.layoutIfNeeded()
        })
        lunchRightStackCons.constant = 160
        UIView.animate(withDuration: 0.1, delay: 0.6, options: .curveEaseOut, animations: {
            self.drugiedanieStack.isHidden = false
            self.view.layoutIfNeeded()
        })
        drugiedanieRightStackCons.constant = 160
        UIView.animate(withDuration: 0.1, delay: 0.7, options: .curveEaseOut, animations: {
            self.przekaskaStack.isHidden = false
            self.view.layoutIfNeeded()
        })
        przekaskaRightStackCons.constant = 160
        UIView.animate(withDuration: 0.1, delay: 0.8, options: .curveEaseOut, animations: {
            self.kolacjaStack.isHidden = false
            self.view.layoutIfNeeded()
        })
        kolacjaRightStackCons.constant = 160
        UIView.animate(withDuration: 0.1, delay: 0.9, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
        UIView.animate(withDuration: 0.5, delay: 0.3, options: .curveEaseOut, animations: {
            self.topLabel.alpha = 1.0
        })
        UIView.animate(withDuration: 0.5, delay: 0.9, options: .curveEaseOut, animations: {
            self.bottomStack.alpha = 1.0
        })
    }
    
    //MARK: - loading values from profile
    
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
        updateNotifications()
    }
    
    @IBAction func alarmCheck(_ sender: UISwitch) {
        if sender.isOn {
            self.updateNotifications()
            let status = sender.isOn
            updateMethods.saveData(dataToSave: status, id: "setAlarm")
        } else {
            notificationCenter.removeAllPendingNotificationRequests()
        }
    }
    
    @IBAction func stepperPressed(_ sender: UIStepper) {
         if let label = timerDisplayLabel {
             label[sender.tag].text = String(Int(sender.value)) + ":00"
             if let timeSaved = label[sender.tag].text{
             updateMethods.saveData(dataToSave: timeSaved, id: "\(sender.tag)")
             }
         }
         updateNotifications()
     }
    
    //MARK: - Notification block
    
    func checkForNotifications() {
        notificationCenter.getNotificationSettings { (settings) in
          if settings.authorizationStatus != .authorized {
            self.alarmCheck.isEnabled = false
          } else {
            self.alarmCheck.isEnabled = true
            }
        }
    }
    
    func updateNotifications() {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "H:mm"
        var myDate = Date()
        if let loadProfileData = realm.objects(ProfileModel.self).first {
            var checkArray: [Bool] = []
            var timeArray: [String] = []
            
            timeArray.append(loadProfileData.timeOfprzystawka)
            timeArray.append(loadProfileData.timeOfsniadanie)
            timeArray.append(loadProfileData.timeOfdrugieSniadanie)
            timeArray.append(loadProfileData.timeOfdeser)
            timeArray.append(loadProfileData.timeOfobiad)
            timeArray.append(loadProfileData.timeOflunch)
            timeArray.append(loadProfileData.timeOfdrugiObiad)
            timeArray.append(loadProfileData.timeOfprzekaska)
            timeArray.append(loadProfileData.timeOfkolacja)
            
            checkArray.append(loadProfileData.przystawka)
            checkArray.append(loadProfileData.sniadanie)
            checkArray.append(loadProfileData.drugieSniadanie)
            checkArray.append(loadProfileData.deser)
            checkArray.append(loadProfileData.obiad)
            checkArray.append(loadProfileData.lunch)
            checkArray.append(loadProfileData.drugiObiad)
            checkArray.append(loadProfileData.przekaska)
            checkArray.append(loadProfileData.kolacja)
            var counter = 0
            for status in checkArray {
                if status { //check status if true then put time in timeArray to request notifications
                    myDate = dateFormatter.date(from: timeArray[counter])!
                    let date = Calendar.current.dateComponents([.hour, .minute, .second], from: myDate)
                    let message = UNMutableNotificationContent()
                    message.title = "StayFit"
                    message.body = "\(dataSource.notificationMessageBody[counter])"
                    message.sound = .default
                    let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
                    let request = UNNotificationRequest(identifier: "StayFit\(counter)", content: message, trigger: trigger)
                    notificationCenter.add(request) { (error) in
                        if error != nil {
                            print(error!)
                        }
                    }
                }
                counter += 1
            }
            
        }
    }
}
