
import Foundation
import RealmSwift

class MeasurementsData: Object {
    @objc dynamic var newestMass: Int = 100
    @objc dynamic var date: Date = Date()
}
