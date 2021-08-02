//
//  ProductsTableController.swift
//  CardsMulti
//
//  Created by Victor on 2021-07-25.
//  Copyright © 2021 Victorius Software Inc. All rights reserved.
//

import UIKit
import StoreKit

class ProductsTableController: UIViewController {
    
    // MARK: - Types
    
    fileprivate struct CellIdentifiers {
        static let availableProduct = "availableProduct"
        static let purchasedProduct = "purchasedProduct"
    }
    
    // MARK: - Properties
    
    var productIdentifiers = ProductIdentifiers()
    var productsTableView: UITableView!
    var products = [SKProduct]()
    
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.productsTableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.navigationController?.view.frame.height ?? self.view.frame.height), style: UITableView.Style.plain)
        self.productsTableView.delegate = self
        self.productsTableView.dataSource = self
        self.view.addSubview(self.productsTableView)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: UIStrings.restorePurchases, style: .plain, target: self, action: #selector(self.restorePurchases))
        
        StoreObserver.sharedInstance.delegate = self
        StoreManager.sharedInstance.delegate = self
        
        self.fetchProductInformation()
    }
    
    // MARK: - Private methods
    
    fileprivate func fetchProductInformation() {
        if !StoreObserver.sharedInstance.isAuthorizedForPayments {
            self.showAlert(title: UIStrings.error, text: UIStrings.notAuthorizedForPurchase)
            return
        }
        
        if !self.productIdentifiers.identifiers.isEmpty {
            StoreManager.sharedInstance.startProductRequest(with: self.productIdentifiers.identifiers)
        }
    }
    
    // MARK: - Actions
    
    @objc fileprivate func restorePurchases() {
        StoreObserver.sharedInstance.restore()
    }
}

// MARK: - Extension UITableViewDelegate

extension ProductsTableController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if self.products.count > indexPath.row {
            let product = self.products[indexPath.row]
            if !self.productIdentifiers.purchasedIdentifiers.contains(product.productIdentifier) {
                StoreObserver.sharedInstance.purchase(product)
            }
        }
    }
    
    /*
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let product = self.products[indexPath.row]
        
        cell.textLabel?.text = product.localizedTitle
        cell.detailTextLabel?.text = product.formattedPrice
    }
 */
}

// MARK: - Extension UITableViewDataSource

extension ProductsTableController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //return tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.availableProduct, for: indexPath)
        
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        
        if self.products.count > indexPath.row {
            let product = self.products[indexPath.row]
            cell.textLabel?.text = product.localizedTitle
            if self.productIdentifiers.purchasedIdentifiers.contains(product.productIdentifier) {
                cell.detailTextLabel?.text = UIStrings.purchased
                cell.selectionStyle = .none
            } else {
                cell.detailTextLabel?.text = product.formattedPrice
            }
        }
        
        return cell
    }    
}

// MARK: - Extension StoreObserverDelegate

extension ProductsTableController: StoreObserverDelegate {
    func didFailToPurchaseProduct(identifier: String) {
        if let product = self.products.first(where: { $0.productIdentifier == identifier}) {
            self.showAlert(title: UIStrings.purchaseStatus, text: String(format: UIStrings.purchaseFailed, product.localizedTitle))
        }
    }
    
    func didPurchaseOrRestoreProduct(identifier: String) {
        self.productIdentifiers.add(purchasedIdentifier: identifier)
        self.productsTableView.reloadData()
    }
    
    func didReceive(message: String) {
        self.showAlert(title: UIStrings.purchaseStatus, text: message)
    }
}

// MARK: - Extension StoreManagerDelegate

extension ProductsTableController: StoreManagerDelegate {
    func didReceive(availableProducts: [SKProduct]) {
        self.products = availableProducts
        self.productsTableView.reloadData()
    }
    
    func didRecieve(message: String) {
        self.showAlert(title: UIStrings.productRequestStatus, text: message)
    }
}
