//
//  CurrenciesTableViewController.swift
//  Pitaza170
//
//  Created by Артем Тихонов on 19.11.2022.
//

import UIKit

class CurrenciesTableViewController: UIViewController {
            
    private var currenciesTableView: CurrenciesTableView {
        return self.view as? CurrenciesTableView ?? CurrenciesTableView()
    }
    
    private var photoService: PhotoService!

    var userCurrencies: [UserCurrency]? {
        didSet {
            DispatchQueue.main.async {
                self.currenciesTableView.tableView.reloadData()
               }
        }
    }
    
    override func loadView() {
        super.loadView()
        self.view = CurrenciesTableView()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.applyGradient(
            colors: [.black, .purple],
            startPoint: CGPoint(x: 0, y: 1),
            endPoint: .zero
        )
        setupTableView()
        photoService = PhotoService(container: currenciesTableView.tableView)
    }
    
    func setupTableView() {
        currenciesTableView.tableView.register(CurrenciesTableViewCell.self, forCellReuseIdentifier: CurrenciesTableViewCell.identifier)
        currenciesTableView.tableView.delegate = self
        currenciesTableView.tableView.dataSource = self
    }
    
}

extension CurrenciesTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userCurrencies?.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = currenciesTableView.tableView.dequeueReusableCell(withIdentifier: CurrenciesTableViewCell.identifier,for: indexPath) as? CurrenciesTableViewCell
        else {
            return UITableViewCell()
        }
        
        guard let currency = userCurrencies?[indexPath.row] else {return cell}
        cell.configure(curImage: photoService.photoAtIndexPath(atIndexPath: indexPath, byUrl: currency.image) ?? UIImage(),
                       name: currency.name,
                       description: currency.description,
                       balance: currency.balance,
                       grow: currency.grow,
                       positive: currency.positive)
        return cell
    }
    
}