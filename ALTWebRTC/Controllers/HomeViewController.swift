//
//  HomeViewController.swift
//  ALTWebRTC
//
//  Created by Alfredo Luco on 06-06-20.
//  Copyright © 2020 Alfredo Luco. All rights reserved.
//

import UIKit
import SwiftValidator

class HomeViewController: UIViewController {

    //MARK: - IBOutlets
    
    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    
    //MARK: - Variables
    var validator: Validator = Validator()
    
    //MARK: - App lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.validator.registerField(self.nameTextField, rules: [RequiredRule(message: "Debes indicar un nombre")])
        self.enterButton.addTarget(self, action: #selector(enter), for: .touchUpInside)
    }
    
    //MARK: - Selectors
    
    @objc func enter() {
        self.validator.validate(self)
    }

}

//MARK: - <Validation Delegate>

extension HomeViewController: ValidationDelegate {
    
    func validationSuccessful() {
        //TODO
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        guard let first = errors.first else { return }
        print(first.1.errorMessage)
    }
    
}
