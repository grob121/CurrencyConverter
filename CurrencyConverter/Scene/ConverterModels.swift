import CoreGraphics
enum Converter {
    
    // MARK: Use cases
    enum Exchange {
        struct Request {
            let fromAmount: String
            let fromCurrency: String
            let toCurrency: String
        }
        struct Response {
            let amount: String
        }
        struct ViewModel {
            let amount: String
        }
    }
    
    enum Currency {
        struct Request {
            let isFromCurrencyActive: Bool
            let selectedCurrency: String
        }
        struct Response {
            let currency: String
        }
        struct ViewModel {
            let currency: String
        }
    }
    
    enum Submit {
        struct Request {
            let amountArray: [String]
            let currencyArray: [String]
            let fromCurrency: String
            let toCurrency: String
            let fromAmount: String
            let toAmount: String
            let numberOfConversions: Int
        }
        struct Response {
            let amountArray: [String]
            let fromCurrencyIndex: Int
            let toCurrencyIndex: Int
            let fromCurrency: String
            let toCurrency: String
            let fromAmountEntered: Float
            let toAmountEntered: Float
            let fromAmountBalance: Float
            let toAmountBalance: Float
            let commission: Float
        }
        struct ViewModel {
            let balanceArray: [String]
            let title: String
            let message: String
            let alertButtonTitle: String
        }
    }
    
    enum Error {
        struct Response {
            let message: String
        }
        struct ViewModel {
            let title: String
            let message: String
            let alertButtonTitle: String
        }
    }
}
