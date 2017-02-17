//
//  ViewController.swift
//  CurrencyConverter
//
//  Created by Michael Wasserman on 2017-01-12.
//  Copyright © 2017 Wasserman. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var currencyAmountField: UITextField!
    @IBOutlet weak var selectCurrencyButton: UIButton!
    @IBOutlet weak var currencyPickerView: UIPickerView!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var collectionViewTopConstraint: NSLayoutConstraint!
    var pickerData = [""]
    var rates = Array<Rate>()
    
    fileprivate let currencyReuseIdentifier = "CurrCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    override func viewWillAppear(_ animated: Bool) {
        self.activityIndicator.color = UIColor.black
        currencyPickerView.isHidden = true
        collectionViewTopConstraint.constant = 20
        
        self.addSpinner()
        DataManager.sharedInstance.getCurrencyCodes({[weak self] (success, codes, err) in
            if success {
                self?.pickerData = codes
                self?.currencyPickerView.reloadAllComponents()
                self?.removeSpinner()
            } else {
                self?.presentAlert(title: "Error", message: err)
                self?.removeSpinner()
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapOutSideTextField: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tapOutSideTextField)
        currencyPickerView.dataSource = self
        currencyPickerView.delegate   = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: - UIPickerViewDataSource Methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    //MARK: - UIPickerViewDelegate Methods
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currencyLabel.text = pickerData[row]
    }
    
    //MARK: - UICollectionViewDataSource Methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return rates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: currencyReuseIdentifier, for: indexPath) as! RateCollectionViewCell

        if let code = rates[indexPath.row].currencyCode, let rate = rates[indexPath.row].currentRate {
            cell.render(code:code , amount:rate )
        }
        
        return cell
    }
    
    //MARK: - Action Methods
    
    @IBAction func getRatesAction(_ sender: UIButton) {
        dismissKeyboard()
        if currencyLabel.text == "" {
            self.presentAlert(title: "No Currency", message: "Please Select A Currency")
            return
        } else if currencyAmountField.text == "" {
            self.presentAlert(title: "No Amount", message: "Please Enter An Amount")
            return
        }
        
        self.addSpinner()
        
        if let curr = currencyLabel.text, let amount = currencyAmountField.text {
            DataManager.sharedInstance.getRatesForCode(amount, curr, {[weak self](success, rates, err) in
                if success {
                    self?.rates.removeAll()
                    for rate in rates {
                        if let amountDblValue = Double(amount), let currentRate = rate.currentRate, let rateDblValue = Double(currentRate), let currCode = rate.currencyCode {
                            let convertedRate = amountDblValue * rateDblValue
                            self?.rates.append(Rate(currencyCode: currCode, currentRate: String(convertedRate)))
                        }
                    }
                    self?.collectionView.reloadData()
                    self?.removeSpinner()
                } else {
                    self?.presentAlert(title: "Error", message: err)
                    self?.removeSpinner()
                }
                
            })
        }
        
    }
    @IBAction func selectCurrencyAction(_ sender: UIButton) {
        dismissKeyboard()
        if currencyPickerView.isHidden {
            currencyPickerView.isHidden = false
            selectCurrencyButton.setTitle("Hide Currencies",for: .normal)
            collectionViewTopConstraint.constant = 235
            if currencyLabel.text == "" {
                currencyLabel.text = pickerData[0]
            }
        } else {
            currencyPickerView.isHidden = true
            selectCurrencyButton.setTitle("Select Currency",for: .normal)
            collectionViewTopConstraint.constant = 20
        }
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout Methods
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace   = sectionInsets.left * (4 + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem   = availableWidth / 4
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    //MARK: - Utility Methods
    
    private func addSpinner() {
        self.activityIndicator.isHidden =  false
        self.activityIndicator.startAnimating()
    }
    
    private func removeSpinner() {
        self.activityIndicator.isHidden =  true
        self.activityIndicator.stopAnimating()
    }
    
    @objc private func dismissKeyboard() {
        currencyAmountField.resignFirstResponder()
    }
    
    private func presentAlert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

