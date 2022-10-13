@testable import CurrencyConverter
import XCTest

class ConverterPresenterTest: XCTestCase {
    var sut: ConverterPresenter?
    
    override func setUp() {
        super.setUp()
        sut = ConverterPresenter()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_present_exchange_data() {
        let spy = ConverterDisplayLogicSpy()
        sut?.viewController = spy
        
        sut?.presentExchangeData(.init(amount: "96.97"))
        
        XCTAssert(spy.displayExchangeDataCalled)
    }
    
    func test_present_error() {
        let spy = ConverterDisplayLogicSpy()
        sut?.viewController = spy
        
        sut?.presentError(.init(message: "Error"))
        
        XCTAssert(spy.displayErrorCalled)
    }
    
    func test_present_from_currency_value() {
        let spy = ConverterDisplayLogicSpy()
        sut?.viewController = spy
        
        sut?.presentFromCurrencyValue(.init(currency: "USD"))
        
        XCTAssert(spy.displayFromCurrencyValueCalled)
    }
    
    func test_present_to_currency_value() {
        let spy = ConverterDisplayLogicSpy()
        sut?.viewController = spy
        
        sut?.presentToCurrencyValue(.init(currency: "EUR"))
        
        XCTAssert(spy.displayToCurrencyValueCalled)
    }
    
    func test_present_conversion_success() {
        let spy = ConverterDisplayLogicSpy()
        sut?.viewController = spy
        
        sut?.presentConversion(.init(amountArray: ["1000.00","0.00","0.00"],
                                     fromCurrencyIndex: 0,
                                     toCurrencyIndex: 1,
                                     fromCurrency: "EUR",
                                     toCurrency: "USD",
                                     fromAmountEntered: 100.0,
                                     toAmountEntered: 96.99,
                                     fromAmountBalance: 900.0,
                                     toAmountBalance: 96.99,
                                     commission: 0.0))
        
        XCTAssert(spy.displayConversionCalled)
    }
    
    func test_alert_message_with_commission() {
        let spy = ConverterDisplayLogicSpy()
        sut?.viewController = spy
        
        sut?.presentConversion(.init(amountArray: ["1000.00","0.00","0.00"],
                                     fromCurrencyIndex: 0,
                                     toCurrencyIndex: 1,
                                     fromCurrency: "EUR",
                                     toCurrency: "USD",
                                     fromAmountEntered: 100.0,
                                     toAmountEntered: 96.99,
                                     fromAmountBalance: 900.0,
                                     toAmountBalance: 96.99,
                                     commission: 0.7))
        
        XCTAssertTrue(spy.alertMessage.contains("Commission Fee"))
    }
}

extension ConverterPresenterTest {
    class ConverterDisplayLogicSpy: ConverterDisplayLogic {
        var displayExchangeDataCalled = false
        var displayErrorCalled = false
        var displayFromCurrencyValueCalled = false
        var displayToCurrencyValueCalled = false
        var displayConversionCalled = false
        var alertMessage = ""
        
        func displayExchangeData(_ viewModel: Converter.Exchange.ViewModel) {
            displayExchangeDataCalled = true
        }
        
        func displayError(_ viewModel: Converter.Error.ViewModel) {
            displayErrorCalled = true
        }
        
        func displayFromCurrencyValue(_ viewModel: Converter.Currency.ViewModel) {
            displayFromCurrencyValueCalled = true
        }
        
        func displayToCurrencyValue(_ viewModel: Converter.Currency.ViewModel) {
            displayToCurrencyValueCalled = true
        }
        
        func displayConversion(_ viewModel: Converter.Submit.ViewModel) {
            displayConversionCalled = true
            alertMessage = viewModel.message
        }
    }
}
