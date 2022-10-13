import Foundation
protocol ConverterBusinessLogic {
    func getExchangeData(_ request: Converter.Exchange.Request)
    func setCurrencyValue(_ request: Converter.Currency.Request)
    func submitConversion(_ request: Converter.Submit.Request)
}

class ConverterInteractor {
    var worker: ConverterWorker? = ConverterWorker(ServiceWorker())
    var presenter: ConverterPresentationLogic?
}

extension ConverterInteractor: ConverterBusinessLogic {
    func getExchangeData(_ request: Converter.Exchange.Request) {
        guard request.fromAmount.last != "." else {
            return
        }
        
        worker?.executeGetExchange(fromAmount: request.fromAmount, fromCurrency: request.fromCurrency, toCurrency: request.toCurrency, completion: { [weak self] exchangeResponse, errorString in
            
            if let response = exchangeResponse {
                self?.presenter?.presentExchangeData(.init(amount: response.amount ?? "0.00"))
            } else if let errorMessage = errorString, !errorMessage.isEmpty {
                self?.presenter?.presentError(.init(message: errorMessage))
            }
        })
    }
    
    func setCurrencyValue(_ request: Converter.Currency.Request) {
        if request.isFromCurrencyActive {
            presenter?.presentFromCurrencyValue(.init(currency: request.selectedCurrency))
        } else {
            presenter?.presentToCurrencyValue(.init(currency: request.selectedCurrency))
        }
    }
    
    func submitConversion(_ request: Converter.Submit.Request) {
        let fromCurrencyIndex = request.currencyArray.firstIndex(of: request.fromCurrency) ?? 0
        let toCurrencyIndex = request.currencyArray.firstIndex(of: request.toCurrency) ?? 0
        
        var fromAmountBalance = (request.amountArray[fromCurrencyIndex] as NSString).floatValue
        let toAmountBalance = (request.amountArray[toCurrencyIndex] as NSString).floatValue
        
        let fromAmountEntered = (request.fromAmount as NSString).floatValue
        let toAmountEntered = (request.toAmount.replacingOccurrences(of: "+ ", with: "") as NSString).floatValue
        
        let commission = request.numberOfConversions > 5 && request.numberOfConversions%10 != 0 && fromAmountEntered < 200 ? 0.007*fromAmountEntered : 0
        fromAmountBalance -= commission
        
        if fromAmountEntered == 0.0 {
            presenter?.presentError(.init(message: "empty_field_message".localize()))
        } else if fromCurrencyIndex == toCurrencyIndex {
            presenter?.presentError(.init(message: "same_currency_message".localize()))
        } else if fromAmountEntered > fromAmountBalance {
            presenter?.presentError(.init(message: "not_enough_balance_message".localize()))
        } else {
            let newToBalance = toAmountBalance + toAmountEntered
            let newFromBalance = fromAmountBalance - fromAmountEntered
            
            presenter?.presentConversion(.init(amountArray: request.amountArray,
                                               fromCurrencyIndex: fromCurrencyIndex,
                                               toCurrencyIndex: toCurrencyIndex,
                                               fromCurrency: request.fromCurrency,
                                               toCurrency: request.toCurrency,
                                               fromAmountEntered: fromAmountEntered,
                                               toAmountEntered: toAmountEntered,
                                               fromAmountBalance: newFromBalance,
                                               toAmountBalance: newToBalance,
                                               commission: commission))
        }
    }
}
