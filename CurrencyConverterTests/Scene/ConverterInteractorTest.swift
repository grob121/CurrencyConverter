@testable import CurrencyConverter
import XCTest

class ConverterInteractorTest: XCTestCase {
    var sut: ConverterInteractor?
    
    override func setUp() {
        super.setUp()
        sut = ConverterInteractor()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_get_exchange_data() {
        let presenterSpy = ConverterPresentationLogicSpy()
        sut?.presenter = presenterSpy
        let workerSpy = ConverterWorkerSpy(ServiceWorker())
        workerSpy.isResponseSuccess = true
        sut?.worker = workerSpy
        
        sut?.getExchangeData(.init(fromAmount: "100", fromCurrency: "EUR", toCurrency: "USD"))
        
        XCTAssert(workerSpy.executeGetExchangeCalled)
        XCTAssert(presenterSpy.presentExchangeDataCalled)
    }
    
    func test_get_exchange_error() {
        let presenterSpy = ConverterPresentationLogicSpy()
        sut?.presenter = presenterSpy
        let workerSpy = ConverterWorkerSpy(ServiceWorker())
        workerSpy.isResponseSuccess = false
        sut?.worker = workerSpy
        
        sut?.getExchangeData(.init(fromAmount: "100", fromCurrency: "EUR", toCurrency: "USD"))
        
        XCTAssert(workerSpy.executeGetExchangeCalled)
        XCTAssert(presenterSpy.presentErrorCalled)
    }
    
    func test_set_from_currency_value() {
        let spy = ConverterPresentationLogicSpy()
        sut?.presenter = spy
        
        sut?.setCurrencyValue(.init(isFromCurrencyActive: true, selectedCurrency: "USD"))
        
        XCTAssert(spy.presentFromCurrencyValueCalled)
    }
    
    func test_set_to_currency_value() {
        let spy = ConverterPresentationLogicSpy()
        sut?.presenter = spy
        
        sut?.setCurrencyValue(.init(isFromCurrencyActive: false, selectedCurrency: "USD"))
        
        XCTAssert(spy.presentToCurrencyValueCalled)
    }
    
    func test_commission_within_conversion_limit() {
        let spy = ConverterPresentationLogicSpy()
        sut?.presenter = spy
        
        sut?.submitConversion(.init(amountArray: ["1000.00","0.00","0.00"],
                                    currencyArray: ["EUR","USD","JPY"],
                                    fromCurrency: "EUR",
                                    toCurrency: "USD",
                                    fromAmount: "100",
                                    toAmount: "+ 96.97",
                                    numberOfConversions: 5))
        
        XCTAssertTrue(spy.commission == 0)
    }
    
    func test_commission_conversion_attempts_multiple_of_ten() {
        let spy = ConverterPresentationLogicSpy()
        sut?.presenter = spy
        
        sut?.submitConversion(.init(amountArray: ["1000.00","0.00","0.00"],
                                    currencyArray: ["EUR","USD","JPY"],
                                    fromCurrency: "EUR",
                                    toCurrency: "USD",
                                    fromAmount: "100",
                                    toAmount: "+ 96.97",
                                    numberOfConversions: 20))
        
        XCTAssertTrue(spy.commission == 0)
    }
    
    func test_commission_amount_two_hundred_or_more() {
        let spy = ConverterPresentationLogicSpy()
        sut?.presenter = spy
        
        sut?.submitConversion(.init(amountArray: ["1000.00","0.00","0.00"],
                                    currencyArray: ["EUR","USD","JPY"],
                                    fromCurrency: "EUR",
                                    toCurrency: "USD",
                                    fromAmount: "200",
                                    toAmount: "+ 193.02",
                                    numberOfConversions: 15))
        
        XCTAssertTrue(spy.commission == 0)
    }
    
    func test_submit_conversion_success() {
        let spy = ConverterPresentationLogicSpy()
        sut?.presenter = spy
        
        sut?.submitConversion(.init(amountArray: ["1000.00","0.00","0.00"],
                                    currencyArray: ["EUR","USD","JPY"],
                                    fromCurrency: "EUR",
                                    toCurrency: "USD",
                                    fromAmount: "100",
                                    toAmount: "+ 96.97",
                                    numberOfConversions: 1))
        
        XCTAssert(spy.presentConversionCalled)
    }
    
    func test_empty_input_error() {
        let spy = ConverterPresentationLogicSpy()
        sut?.presenter = spy
        
        sut?.submitConversion(.init(amountArray: ["1000.00","0.00","0.00"],
                                    currencyArray: ["EUR","USD","JPY"],
                                    fromCurrency: "EUR",
                                    toCurrency: "USD",
                                    fromAmount: "",
                                    toAmount: "+ 0.00",
                                    numberOfConversions: 1))
   
        XCTAssert(spy.presentErrorCalled)
    }
    
    func test_same_currency_error() {
        let spy = ConverterPresentationLogicSpy()
        sut?.presenter = spy
        
        sut?.submitConversion(.init(amountArray: ["1000.00","0.00","0.00"],
                                    currencyArray: ["EUR","USD","JPY"],
                                    fromCurrency: "EUR",
                                    toCurrency: "EUR",
                                    fromAmount: "100",
                                    toAmount: "+ 100.00",
                                    numberOfConversions: 1))
   
        XCTAssert(spy.presentErrorCalled)
    }
    
    func test_insufficient_balance_error() {
        let spy = ConverterPresentationLogicSpy()
        sut?.presenter = spy
        
        sut?.submitConversion(.init(amountArray: ["1000.00","0.00","0.00"],
                                    currencyArray: ["EUR","USD","JPY"],
                                    fromCurrency: "EUR",
                                    toCurrency: "USD",
                                    fromAmount: "2000",
                                    toAmount: "+ 1902.00",
                                    numberOfConversions: 0))
   
        XCTAssert(spy.presentErrorCalled)
    }
}

extension ConverterInteractorTest {
    class ConverterPresentationLogicSpy: ConverterPresentationLogic {
        var presentExchangeDataCalled = false
        var presentErrorCalled = false
        var presentFromCurrencyValueCalled = false
        var presentToCurrencyValueCalled = false
        var presentConversionCalled = false
        var commission = Float(0)
        
        func presentExchangeData(_ response: Converter.Exchange.Response) {
            presentExchangeDataCalled = true
        }
        
        func presentError(_ response: Converter.Error.Response) {
            presentErrorCalled = true
        }
        
        func presentFromCurrencyValue(_ response: Converter.Currency.Response) {
            presentFromCurrencyValueCalled = true
        }
        
        func presentToCurrencyValue(_ response: Converter.Currency.Response) {
            presentToCurrencyValueCalled = true
        }
        
        func presentConversion(_ response: Converter.Submit.Response) {
            commission = response.commission
            presentConversionCalled = true
        }
    }
    
    class ConverterWorkerSpy: ConverterWorker {
        var isResponseSuccess = false
        var executeGetExchangeCalled = false
        
        override func executeGetExchange(fromAmount: String, fromCurrency: String, toCurrency: String, completion: @escaping (ExhangeResponse?, String?) -> Void) {
            executeGetExchangeCalled = true
            
            if isResponseSuccess == true {
                let value = "{\"amount\":\"0.96\",\"currency\":\"USD\"}"
                completion(ExhangeResponse(JSONString: value), nil)
            } else {
                completion(nil, "Error")
            }
        }
    }
}
