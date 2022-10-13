import UIKit

class BaseViewController: UIViewController {
    private let indicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        if #available(iOS 13.0, *) {
            indicator.style = .large
        } else {
            indicator.style = .gray
        }
    }
    
    func hideKeyboardWhenTapAroundView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showLoading() {
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.startAnimating()
    }
    
    func hideLoading() {
        indicator.stopAnimating()
    }
    
    func displayAlert(title: String, message: String, alertButtonTitle: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        
        let action = UIAlertAction(title: alertButtonTitle, style: UIAlertAction.Style.default) { _ in }
        alertController.addAction(action)

        present(alertController, animated: true)
    }
}
