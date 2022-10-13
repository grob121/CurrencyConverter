import Foundation

protocol ConverterPresentationLogic {
    func presentExchangeData(_ response: Converter.Exchange.Response)
    func presentError(_ response: Converter.Error.Response)
    func presentFromCurrencyValue(_ response: Converter.Currency.Response)
    func presentToCurrencyValue(_ response: Converter.Currency.Response)
    func presentConversion(_ response: Converter.Submit.Response)
}

class ConverterPresenter: ConverterPresentationLogic {
    weak var viewController: ConverterDisplayLogic?
    
    func presentExchangeData(_ response: Converter.Exchange.Response) {
        viewController?.displayExchangeData(.init(amount: "+ \(response.amount)\(response.amount.contains(".") ? "" : ".00")"))
    }
    
    func presentError(_ response: Converter.Error.Response) {
        viewController?.displayError(.init(title: "error_alert_title".localize(),
                                           message: response.message,
                                           alertButtonTitle: "ok_button_title".localize()))
    }
    
    func presentFromCurrencyValue(_ response: Converter.Currency.Response) {
        viewController?.displayFromCurrencyValue(.init(currency: response.currency))
    }
    
    func presentToCurrencyValue(_ response: Converter.Currency.Response) {
        viewController?.displayToCurrencyValue(.init(currency: response.currency))
    }
    
    func presentConversion(_ response: Converter.Submit.Response) {
        var updatedAmountArray = response.amountArray
        updatedAmountArray[response.fromCurrencyIndex] = "\(roundValue(response.fromAmountBalance))"
        updatedAmountArray[response.toCurrencyIndex] = "\(roundValue(response.toAmountBalance))"
        
        var alertMessage = String(format: "convert_success_message".localize(), "\(roundValue(response.fromAmountEntered)) \(response.fromCurrency)", "\(roundValue(response.toAmountEntered)) \(response.toCurrency)")
        
        if response.commission != 0 {
            alertMessage.append(String(format: "commission_fee_message".localize(), "\(roundValue(response.commission)) \(response.fromCurrency)"))
        }
        
        viewController?.displayConversion(.init(balanceArray: updatedAmountArray,
                                                title: "converted_alert_title".localize(),
                                                message: alertMessage,
                                                alertButtonTitle: "done_button_title".localize()))
    }
    
    private func roundValue(_ value: Float) -> String {
        let rounded = round(value * 100) / 100.0
        return String(format: "%.2f", rounded)
    }
}
