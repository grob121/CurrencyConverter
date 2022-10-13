@testable import CurrencyConverter
import XCTest

class ConverterWorkerTest: XCTestCase {
    var sut: ConverterWorker?
    
    override func setUp() {
        super.setUp()
        sut = ConverterWorker(ServiceWorkerSpy())
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_execute_get_exchange_success() {
        let spy = ServiceWorkerSpy()
        sut?.serviceWorker = spy
        
        let expect = expectation(description: "Wait API return")
        sut?.executeGetExchange(fromAmount: "100",
                                fromCurrency: "EUR",
                                toCurrency: "USD",
                                completion: { response, error in
                                    expect.fulfill()
                                })
        waitForExpectations(timeout: 1.0)
        
        XCTAssertTrue(spy.executeGetExchangeCalled)
    }
}

extension ConverterWorkerTest {
    class ServiceWorkerSpy: ServiceWorker {
        var executeGetExchangeCalled = false
        
        override func executeGetExchange(query: String, callback: @escaping (Swift.Result<ExhangeResponse, Error>) -> Void) {
            executeGetExchangeCalled = true
            
            let value = "{\"amount\":\"0.96\",\"currency\":\"USD\"}"
            guard let exchangeResponse = ExhangeResponse(JSONString: value) else {
                return
            }
            
            callback(.success(exchangeResponse))
        }
    }
}
