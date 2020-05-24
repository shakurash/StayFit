import Foundation
import RealmSwift

class LastSavedDates: Object {
    @objc dynamic var day: Int = 0
    @objc dynamic var month: Int = 0
    @objc dynamic var year: Int = 0
}
