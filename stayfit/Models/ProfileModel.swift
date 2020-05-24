import Foundation
import RealmSwift

class ProfileModel: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var mass: Int = 40
    @objc dynamic var height: Int = 120
    @objc dynamic var target: Int = 50
    @objc dynamic var gender: String = "MALE"
    @objc dynamic var date: String = "01/01/1000"
    @objc dynamic var tempo: String = "slow"
    @objc dynamic var dayIntense: Double = 1.2
    @objc dynamic var lightMode: Bool = true
    @objc dynamic var startDate: Date? = nil
    let lastSavedDates = List<LastSavedDates>()
    let measureArray = List<MeasurementsData>()
    
    @objc dynamic var przystawka: Bool = true
    @objc dynamic var sniadanie: Bool = true
    @objc dynamic var drugieSniadanie: Bool = true
    @objc dynamic var deser: Bool = true
    @objc dynamic var obiad: Bool = true
    @objc dynamic var lunch: Bool = true
    @objc dynamic var drugiObiad: Bool = true
    @objc dynamic var przekaska: Bool = true
    @objc dynamic var kolacja: Bool = true
    @objc dynamic var setAlarm: Bool = false
    
    @objc dynamic var timeOfprzystawka: String = "6:00"
    @objc dynamic var timeOfsniadanie: String = "7:00"
    @objc dynamic var timeOfdrugieSniadanie: String = "8:00"
    @objc dynamic var timeOfdeser: String = "9:00"
    @objc dynamic var timeOfobiad: String = "12:00"
    @objc dynamic var timeOflunch: String = "13:00"
    @objc dynamic var timeOfdrugiObiad: String = "14:00"
    @objc dynamic var timeOfprzekaska: String = "17:00"
    @objc dynamic var timeOfkolacja: String = "20:00"
}
