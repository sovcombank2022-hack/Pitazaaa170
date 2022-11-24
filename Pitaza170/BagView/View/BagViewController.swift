import UIKit

final class BagViewController: UIViewController {
    
    private let presenter: BagViewOutput
    
    var userCurrency: UserCurrencies? {
        didSet {
            currencuesTableViewController.userCurrencies = userCurrency?.currencies
        }
    }
    
    lazy var balanceViewController = BalanceViewController(balance: "1", grow: "+1")
    
    lazy var currencuesTableViewController = CurrenciesTableViewController()
    
    var inputRublesButton: UIButton = {
        let button = UIButton()
        button.setTitle("Ввод рублей", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        button.backgroundColor = UIColor(red: 58/255, green: 41/255, blue: 100/255, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(inputRubles), for: .touchUpInside)
        return button
    }()
    
    @objc func inputRubles() {
        presenter.didTapInputButton()
    }
    
    var outputRublesButton: UIButton = {
        let button = UIButton()
        button.setTitle("Ввод рублей", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        button.backgroundColor = UIColor(red: 38/255, green: 55/255, blue: 53/255, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(outputRubles), for: .touchUpInside)
        return button
    }()
    
    private let bagButton: UIButton = {
        let button = UIButton()
        button.setTitle("Bag", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        button.backgroundColor = UIColor(red: 58/255, green: 41/255, blue: 100/255, alpha: 1)
        button.addTarget(
            self,
            action: #selector(bagButtonTapped(_:)), for: .touchUpInside
        )
        return button
    }()
    
    @objc private func bagButtonTapped(_ sender: Any) {
        // TODO: Add stick on top ?
        let currencies = currencuesTableViewController
        if let presentationController = currencies.presentationController
            as? UISheetPresentationController {
            presentationController.detents = [.medium(), .large()]
        }
        present(currencies, animated: true)
    }
    
    @objc func outputRubles() {
        presenter.didTapOutputButton()
    }
    
    init(presenter: BagViewOutput) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        self.configureUI()
        self.presenter.viewDidLoadCurrencies()
        self.presenter.viewDidLoadRubles()
    }
    
    // MARK: - Private
    
    private func configureUI() {
        self.addBalanceViewController()
        self.addButtons()
    }
    
    private func addBalanceViewController() {
        self.addChild(self.balanceViewController)
        self.view.addSubview(self.balanceViewController.view)
        self.balanceViewController.didMove(toParent: self)
        self.balanceViewController.view.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(55)
            make.left.right.equalToSuperview().inset(30)
            make.height.equalTo(200)
        }
    }
    
    private func addButtons() {
        view.addSubview(inputRublesButton)
        inputRublesButton.snp.makeConstraints { make in
            make.top.equalTo(balanceViewController.view.snp.bottom).inset(-15)
            make.left.equalToSuperview().inset(30)
            make.right.equalTo(view.snp.centerX).inset(15)
            make.height.equalTo(50)
        }
        view.addSubview(outputRublesButton)
        outputRublesButton.snp.makeConstraints { make in
            make.top.equalTo(inputRublesButton.snp.bottom).inset(-15)
            make.left.equalToSuperview().inset(30)
            make.right.equalTo(view.snp.centerX).inset(15)
            make.height.equalTo(50)
        }
        view.addSubview(bagButton)
        bagButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-100)
            make.height.equalTo(50)
            make.width.equalTo(100)
        }
    }
    
    override func viewDidLayoutSubviews() {
        inputRublesButton.layer.cornerRadius = inputRublesButton.frame.height / 2
        inputRublesButton.layer.masksToBounds = true
        
        outputRublesButton.layer.cornerRadius = inputRublesButton.frame.height / 2
        outputRublesButton.layer.masksToBounds = true
        
        bagButton.layer.cornerRadius = bagButton.frame.height / 2
        bagButton.layer.masksToBounds = true
    }
}

extension BagViewController: BagViewInput {
    
    func showInputRublesView() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Ввод рублей", message: nil, preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default){ (action: UIAlertAction) in
                if let text = alert.textFields?.first?.text,
                   let count = Int(text) {
                    self.presenter.didInputedRubles(count: count)
                }
            }
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addTextField { (textField: UITextField) in
                textField.placeholder = "Введите сумму"
            }
            
            alert.addAction(ok)
            alert.addAction(cancel)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showOutputRublesView() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Вывод рублей", message: nil, preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default){ (action: UIAlertAction) in
                if let text = alert.textFields?.first?.text,
                   let count = Int(text) {
                    self.presenter.didOutputedRubles(count: count)
                }
            }
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addTextField { (textField: UITextField) in
                textField.placeholder = "Введите сумму"
            }
            
            alert.addAction(ok)
            alert.addAction(cancel)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func updateRubles(rublesBalance: UserRubles) {
        DispatchQueue.main.async {
            self.balanceViewController.balanceValue = rublesBalance.balance
            self.balanceViewController.growValue = rublesBalance.grow
        }
    }
    
    func updateCurrencies(currency: UserCurrencies) {
        DispatchQueue.main.async {
            self.userCurrency = currency
        }
    }
}
