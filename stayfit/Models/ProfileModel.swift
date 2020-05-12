import Foundation
import RealmSwift

class ProfileModel: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var mass: Int = 40
    @objc dynamic var height: Int = 120
    @objc dynamic var target: Int = 50
    @objc dynamic var gender: String = ""
    @objc dynamic var date: String = ""
    @objc dynamic var tempo: String = ""
    @objc dynamic var dayIntense: Double = 1.2
    @objc dynamic var lightMode: Bool = true
}
