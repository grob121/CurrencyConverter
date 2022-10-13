import UIKit
import RxSwift
import RxCocoa

protocol ConverterDisplayLogic: AnyObject {
    func displayExchangeData(_ viewModel: Converter.Exchange.ViewModel)
    func displayError(_ viewModel: Converter.Error.ViewModel)
    func displayFromCurrencyValue(_ viewModel: Converter.Currency.ViewModel)
    func displayToCurrencyValue(_ viewModel: Converter.Currency.ViewModel)
    func displayConversion(_ viewModel: Converter.Submit.ViewModel)
}

class ConverterViewController: BaseViewController {
    @IBOutlet private weak var balancesHeaderLabel: UILabel!
    @IBOutlet private weak var exchangeHeaderLabel: UILabel!
    @IBOutlet private weak var sellLabel: UILabel!
    @IBOutlet private weak var receiveLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var fromAmountTextField: UITextField!
    @IBOutlet private weak var fromCurrencyLabel: UILabel!
    @IBOutlet private weak var fromCurrencyButton: UIButton!
    @IBOutlet private weak var toAmountLabel: UILabel!
    @IBOutlet private weak var toCurrencyLabel: UILabel!
    @IBOutlet private weak var toCurrencyButton: UIButton!
    @IBOutlet private weak var submitButton: UIButton!
    @IBOutlet private weak var currencyPickerView: UIStackView!
    @IBOutlet private weak var pickerView: UIPickerView!
    @IBOutlet private weak var doneButtonItem: UIBarButtonItem!
    
    var interactor: ConverterBusinessLogic?
    private let disposeBag = DisposeBag()
    private let currencyArray = ["EUR","USD","JPY"]
    private var amountArray = ["1000.00","0.00","0.00"]
    private var isFromCurrencyActive = false
    private var numberOfConversions = 1
    
    // MARK: Object Lifecycle
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    private func setup() {
        let viewController = self
        let interactor = ConverterInteractor()
        let presenter = ConverterPresenter()
        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController
    }
    
    static func initFromStoryboard() -> ConverterViewController {
        return UIStoryboard(name: "Converter", bundle: nil).instantiateInitialViewController() as? ConverterViewController ?? ConverterViewController()
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        loadLocalizedStrings()
        setupObservables()
        hideKeyboardWhenTapAroundView()
    }
    
    private func configureUI() {
        submitButton.layer.masksToBounds = true
        submitButton.layer.cornerRadius = submitButton.frame.height/2
        currencyPickerView.isHidden = true
        fromAmountTextField.delegate = self
        collectionView.reloadData()
    }
    
    // MARK: Localization
    private func loadLocalizedStrings() {
        title = "navigation_bar_title".localize()
        balancesHeaderLabel.text = "balances_header_title".localize()
        exchangeHeaderLabel.text = "exchange_header_title".localize()
        sellLabel.text = "sell_title".localize()
        receiveLabel.text = "receive_title".localize()
        submitButton.titleLabel?.text = "submit_button_title".localize()
        doneButtonItem.title = "done_button_title".localize()
    }
}

// MARK: Rx
extension ConverterViewController {
    private func setupObservables() {
        disposeBag.insert([
            fromAmountTextField
                .rx
                .controlEvent(.editingChanged)
                .withLatestFrom(fromAmountTextField.rx.text.orEmpty)
                .subscribe(onNext: { [weak self] text in
                    self?.handleTypedText(text)
                }),
            
            fromCurrencyButton
                .rx
                .tap
                .subscribe(onNext: { [weak self] _ in
                    self?.isFromCurrencyActive = true
                    self?.handleSelectedCurrency(self?.fromCurrencyLabel.text ?? "EUR")
                }),
            
            toCurrencyButton
                .rx
                .tap
                .subscribe(onNext: { [weak self] _ in
                    self?.isFromCurrencyActive = false
                    self?.handleSelectedCurrency(self?.toCurrencyLabel.text ?? "EUR")
                }),
            
            doneButtonItem
                .rx
                .tap
                .subscribe(onNext: { [weak self] _ in
                    self?.handleDoneClicked()
                }),
            
            submitButton
                .rx
                .tap
                .subscribe(onNext: { [weak self] _ in
                    self?.handleSubmitClicked()
                })
        ])
    }

    private func handleTypedText(_ text: String) {
        submitButton.isEnabled = false
        showLoading()
        
        interactor?.getExchangeData(.init(fromAmount: text,
                                          fromCurrency: fromCurrencyLabel.text ?? "EUR",
                                          toCurrency: toCurrencyLabel.text ?? "EUR"))
    }
    
    private func handleSelectedCurrency(_ value: String) {
        submitButton.isEnabled = false
        currencyPickerView.isHidden = false
        showLoading()
        let defaultRowIndex = currencyArray.firstIndex(of: value)
        pickerView.selectRow(defaultRowIndex ?? 0, inComponent: 0, animated: false)
        
        interactor?.setCurrencyValue(.init(isFromCurrencyActive: isFromCurrencyActive, selectedCurrency: value))
    }
    
    private func handleDoneClicked() {
        currencyPickerView.isHidden = true
        
        interactor?.getExchangeData(.init(fromAmount: fromAmountTextField.text ?? "0.00",
                                          fromCurrency: fromCurrencyLabel.text ?? "EUR",
                                          toCurrency: toCurrencyLabel.text ?? "EUR"))
    }
    
    private func handleSubmitClicked() {        
        interactor?.submitConversion(.init(amountArray: amountArray,
                                           currencyArray: currencyArray,
                                           fromCurrency: fromCurrencyLabel.text ?? "EUR",
                                           toCurrency: toCurrencyLabel.text ?? "EUR",
                                           fromAmount: fromAmountTextField.text ?? "0.0",
                                           toAmount: toAmountLabel.text ?? "0.0",
                                           numberOfConversions: numberOfConversions))
    }
}

// MARK: Display Logic
extension ConverterViewController: ConverterDisplayLogic {
    func displayExchangeData(_ viewModel: Converter.Exchange.ViewModel) {
        hideLoading()
        submitButton.isEnabled = true
        toAmountLabel.text = viewModel.amount
    }
    
    func displayError(_ viewModel: Converter.Error.ViewModel) {
        hideLoading()
        
        displayAlert(title: viewModel.title,
                     message: viewModel.message,
                     alertButtonTitle: viewModel.alertButtonTitle)
    }
    
    func displayFromCurrencyValue(_ viewModel: Converter.Currency.ViewModel) {
        fromCurrencyLabel.text = viewModel.currency
    }
    
    func displayToCurrencyValue(_ viewModel: Converter.Currency.ViewModel) {
        toCurrencyLabel.text = viewModel.currency
    }
    
    func displayConversion(_ viewModel: Converter.Submit.ViewModel) {
        numberOfConversions += 1
        amountArray = viewModel.balanceArray
        collectionView.reloadData()
        fromAmountTextField.text = ""
        toAmountLabel.text = "+ 0.00"
        
        displayAlert(title: viewModel.title,
                     message: viewModel.message,
                     alertButtonTitle: viewModel.alertButtonTitle)
    }
}

// MARK: Picker View
extension ConverterViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
        
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencyArray.count
    }
        
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencyArray[row]
    }
        
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        interactor?.setCurrencyValue(.init(isFromCurrencyActive: isFromCurrencyActive, selectedCurrency: currencyArray[row]))
    }
}

// MARK: Text Field
extension ConverterViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let oldText = textField.text, let r = Range(range, in: oldText) else {
            return true
        }

        let newText = oldText.replacingCharacters(in: r, with: string)
        let isNumeric = newText.isEmpty || (Double(newText) != nil)
        let numberOfDots = newText.components(separatedBy: ".").count - 1
        
        let numberOfDecimalDigits: Int
        if let dotIndex = newText.firstIndex(of: ".") {
            numberOfDecimalDigits = newText.distance(from: dotIndex, to: newText.endIndex) - 1
        } else {
            numberOfDecimalDigits = 0
        }

        return isNumeric && numberOfDots <= 1 && numberOfDecimalDigits <= 2
    }
}

// MARK: Collection View
extension ConverterViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        currencyArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "converterCell", for: indexPath) as! ConverterCollectionViewCell
        cell.amountLabel.text = amountArray[indexPath.item]
        cell.currencyLabel.text = currencyArray[indexPath.item]
        return cell
    }
}
