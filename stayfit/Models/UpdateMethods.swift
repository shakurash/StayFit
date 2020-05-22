
import Foundation
import RealmSwift

struct UpdateMethods {
    
    let realm = try! Realm()
    
    func saveData(dataToSave: Any, id: String? = nil) {
        
        let myProfile = realm.objects(ProfileModel.self).first
        try! realm.write { // realm.write can catch entire block of code = less code
            if let myData = dataToSave as? Date {
                if myProfile?.startDate == nil {                    
                    myProfile?.startDate = myData
                }
            } else if let myData = dataToSave as? String {
                switch id {
                case "profileName": myProfile?.name = myData
                case "profileDate": myProfile?.date = myData
                case "profileTempo": myProfile?.tempo = myData
                case "profileGender": myProfile?.gender = myData
                case "0": myProfile?.timeOfprzystawka = myData
                case "1": myProfile?.timeOfsniadanie = myData
                case "2": myProfile?.timeOfdrugieSniadanie = myData
                case "3": myProfile?.timeOfdeser = myData
                case "4": myProfile?.timeOfobiad = myData
                case "5": myProfile?.timeOflunch = myData
                case "6": myProfile?.timeOfdrugiObiad = myData
                case "7": myProfile?.timeOfprzekaska = myData
                case "8": myProfile?.timeOfkolacja = myData
                //case "measureData": stworz array dat z waga
                default: break
                }
            } else if let myData = dataToSave as? Int {
                switch id {
                case "profileMass": myProfile?.mass = myData
                case "profileTarget": myProfile?.target = myData
                case "profileHeight": myProfile?.height = myData
                default: break
                }
            } else if let myData = dataToSave as? Double {
                if id == "profileDayIntense" {
                    myProfile?.dayIntense = myData
                }
            } else if let myData = dataToSave as? Bool {
                if id == "profileMode" {
                    myProfile?.lightMode = myData
                }
                if id == "setAlarm" {
                    myProfile?.setAlarm = myData
                }
                switch id {
                case "0": myProfile?.przystawka = myData
                case "1": myProfile?.sniadanie = myData
                case "2": myProfile?.drugieSniadanie = myData
                case "3": myProfile?.deser = myData
                case "4": myProfile?.obiad = myData
                case "5": myProfile?.lunch = myData
                case "6": myProfile?.drugiObiad = myData
                case "7": myProfile?.przekaska = myData
                case "8": myProfile?.kolacja = myData
                default: break                    
                }
            } else if let myData = dataToSave as? MeasurementsData {
                if id == "override" {
                    let dateFormatter = DateFormatter()
                    dateFormatter.timeStyle = .none
                    dateFormatter.dateStyle = .medium
                    if let arrayOfDates = myProfile?.measureArray {
                        for dates in arrayOfDates {
                            let dateItemInProfile = dateFormatter.string(from: dates.date)
                            let compareDate = dateFormatter.string(from: myData.date)
                            if dateItemInProfile == compareDate {
                            dates.date = myData.date
                            dates.newestMass = myData.newestMass
                            }
                        }
                    }
                } else {
                   myProfile?.measureArray.append(myData)
                }
            }
        }
        
        
        
    }
}
