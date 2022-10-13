import Foundation
import ObjectMapper

open class ExhangeResponse: Mappable {
    public var amount: String?
    public var currency: String?

    public required init?(map: Map) { }

    open func mapping(map: Map) {
        amount     <- map["amount"]
        currency   <- map["currency"]
    }
}
