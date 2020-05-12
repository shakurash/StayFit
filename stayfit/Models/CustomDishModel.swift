import Foundation
import RealmSwift

class CustomDishModel: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var energy: Int = 10
    var ingridients = List<IngridientsModel>()
}
