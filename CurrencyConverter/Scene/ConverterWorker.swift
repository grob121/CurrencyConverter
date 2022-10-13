import Alamofire
import ObjectMapper

protocol ConverterWorkingLogic {
    func executeGetExchange(query: String, callback: @escaping (Swift.Result<ExhangeResponse, Error>) -> Void)
}

class ConverterWorker {
    var serviceWorker: ServiceWorker
    
    init(_ serviceWorker: ServiceWorker){
        self.serviceWorker = serviceWorker
    }
    
    func executeGetExchange(fromAmount: String, fromCurrency: String, toCurrency: String, completion: @escaping (ExhangeResponse?, String?) -> Void) {
        serviceWorker.executeGetExchange(query: "\(fromAmount)-\(fromCurrency)/\(toCurrency)") { (callback) in
            switch callback{
                case .success(let response):
                    completion(response, nil)
                case .failure(let error):
                    completion(nil, error.localizedDescription)
            }
        }
    }
}

class ServiceWorker: ConverterWorkingLogic {
    func executeGetExchange(query: String, callback: @escaping (Swift.Result<ExhangeResponse, Error>) -> Void) {
        let url = String(format: Router.baseURL, query)
        
        AF.request(
            url,
            method: .get,
            encoding: JSONEncoding.default)
            .responseString { response in
            switch response.result {
                case .success(let value):
                    guard let exchange = ExhangeResponse(JSONString: value) else { return }
                    callback(.success(exchange))
                case .failure(let error):
                    callback(.failure(error))
            }
        }
    }
}
