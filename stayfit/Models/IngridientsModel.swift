import Foundation
import RealmSwift

class IngridientsModel: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var mass: Int = 100
    @objc dynamic var energy: Int = 10
    var parentDish = LinkingObjects(fromType: CustomDishModel.self, property: "ingridients")
}
