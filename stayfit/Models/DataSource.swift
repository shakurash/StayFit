import Foundation
import RealmSwift

struct DataSource {
    
    let profileModel = ProfileModel()
    let realm = try! Realm()
    
    //MARK: - profile setup
    
    let profileMass: [Int] = Array(30...300)
    let profileHeight: [Int] = Array(100...300)
    
    // profile PPM, CPM
    var age: Int {
        let ageComponents = calendar.dateComponents([.year], from: convertedDate, to: Date())
        return ageComponents.year!
    }
    
    var convertedDate: Date { // "dd/MM/yyyy" from profileModel
        let loadProfileData = realm.objects(ProfileModel.self).first
        guard let isoDate = loadProfileData?.date else {fatalError("profile has no saved date of birth")}
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        guard let date = dateFormatter.date(from:isoDate) else {fatalError("date was nil unable to convert")}
        return date
    }
    
    var staticValueForGender: (mass: Double, height: Double, stage: Double, static: Double) {
        guard let loadProfileData = realm.objects(ProfileModel.self).first else {fatalError("no profile data for gender to set staticValue")}
        var massValue: Double
        var heightValue: Double
        var stageValue: Double
        var staticValue: Double
        if loadProfileData.gender == "FEMALE" {
            massValue = 9.563
            heightValue = 1.85
            stageValue = 4.676
            staticValue = 655.1
            return (massValue, heightValue, stageValue, staticValue)
        } else {
            massValue = 13.75
            heightValue = 5.003
            stageValue = 6.775
            staticValue = 66.5
            return (massValue, heightValue, stageValue, staticValue)
        }
    }
    
    var PPM: Double {
        guard let loadProfileData = realm.objects(ProfileModel.self).first else {fatalError("no profile data to compute PPM")}
        let mass = staticValueForGender.mass * Double(loadProfileData.mass)
        let height = staticValueForGender.height * Double(loadProfileData.height)
        let stage = staticValueForGender.stage * Double(age)
        return staticValueForGender.static + mass + height - stage
    }
    
    var CPM: Double {
        guard let loadProfileData = realm.objects(ProfileModel.self).first else {fatalError("no profile data to compute CPM")}
        return PPM * loadProfileData.dayIntense
    }
    
    var passedTime: Int {
        guard let loadProfileData = realm.objects(ProfileModel.self).first else {fatalError("no profile data to compute CPM")}
            let profileDate = loadProfileData.startDate
            let currentDay = Date()
            let daysPassedSinceStart = calendar.dateComponents([.day], from: profileDate!, to: currentDay)
            let daysPassed = daysPassedSinceStart.day
            return predictionTime - daysPassed!
    }
    
    var predictionTime: Int {
        guard let loadProfileData = realm.objects(ProfileModel.self).first else {fatalError("no profile data to compute prediction time")}
        let tempo: Double
        let massDifference = loadProfileData.mass - loadProfileData.target
        if massDifference < 0 {
        switch loadProfileData.tempo {
                    case "slow": tempo = 1.1
                    case "medium": tempo = 1.15
                    case "fast": tempo = 1.2
                    default: tempo = 1.1
                    }
        } else {
            switch loadProfileData.tempo {
            case "slow": tempo = 0.9
            case "medium": tempo = 0.85
            case "fast": tempo = 0.8
            default: tempo = 0.9
            }
        }
        let timeToGetTarget = massDifference * 7
        let summarizeMass = Double(timeToGetTarget) * CPM
        let percentMass = CPM * tempo
        let howMuchProfileNeedsProtein = abs(percentMass * Double(timeToGetTarget) - summarizeMass)
        let realisticTimeToGetTarget = howMuchProfileNeedsProtein / CPM
        let realTimeInt = realisticTimeToGetTarget.rounded(.up)
        return abs(timeToGetTarget - Int(realTimeInt))
    }
    
    func profileTargetDay() -> Array<DataMark> { //for callendar to select specific days from beginning of profile and end of gaining target mass
        guard let loadProfileData = realm.objects(ProfileModel.self).first else {fatalError("no profile savepoint to make target data")}
        var arrayOfDatesToTargetDay: Array<DataMark> = []
        let startingProfileDate = loadProfileData.startDate
        var daysToTarget = predictionTime
        var dateComponent = DateComponents()
        let dateFormatter = DateFormatter()
        var dayCounter = 0
        while daysToTarget > 0 {
            dateComponent.day = dayCounter
            dayCounter += 1
            let analizedDate = calendar.date(byAdding: dateComponent, to: startingProfileDate!)
            let year = dateFormatter.calendar.component(.year, from: analizedDate!)
            let month = dateFormatter.calendar.component(.month, from: analizedDate!)
            let day = dateFormatter.calendar.component(.day, from: analizedDate!)
            let object = DataMark(year: year, month: month, day: day)
            arrayOfDatesToTargetDay.append(object)
            daysToTarget -= 1
        }
        return arrayOfDatesToTargetDay
    }
    
    //MARK: - calendar setup
    
    let months = ["Styczeń","Luty","Marzec","Kwiecień","Maj","Czerwiec","Lipiec","Sierpień","Wrzesień","Październik","Listopad","Grudzień"]
    let weekDays = [ "Niedziela", "Poniedziałek", "Wtorek", "Środa", "Czwartek", "Piątek", "Sobota"]
    var numberInMonths = [31,28,31,30,31,30,31,31,30,31,30,31]
    
    var direction = 0 // if 0 then current month if 1 future months if -1 previous months
    var emptySpaceBuffor = 0
    var numberOfEmptySpace = 0 //empty spaces at beginning of calendar
    var numberOfNextEmptySpace = 0
    var numberOfPreviousEmpySpace = 0

    //MARK: - view controller refresh functions

    func refreshDishLabels(steppers: [Any]) -> [Any] {
    guard let loadProfileData = realm.objects(ProfileModel.self).first else {fatalError("no profile data refresh dish labels and steppers")}
        let obj = loadProfileData
        var item = String()
        var counter = 0
        var steppersArray: [Any] = []
        for time in steppers {
            switch counter {
            case 0: item = obj.timeOfprzystawka
            case 1: item = obj.timeOfsniadanie
            case 2: item = obj.timeOfdrugieSniadanie
            case 3: item = obj.timeOfdeser
            case 4: item = obj.timeOfobiad
            case 5: item = obj.timeOflunch
            case 6: item = obj.timeOfdrugiObiad
            case 7: item = obj.timeOfprzekaska
            case 8: item = obj.timeOfkolacja
            default: break
            }
            if let whatType = time as? UIStepper {
                let justInt = item.dropLast(3)
                whatType.value = Double(Int(justInt)!)
                steppersArray.append(whatType)
            } else if time is UILabel {
                (time as! UILabel).text = item
                steppersArray.append(time)
            }
            counter += 1
        }
    return steppersArray
}
}
