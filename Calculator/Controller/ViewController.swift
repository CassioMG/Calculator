//
//  ViewController.swift
//  Stack Views Layout
//
//  Created by Cássio Marcos Goulart on 12/04/19.
//  Copyright © 2019 CMG Solutions. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Instance properties
    private var calculatorLogic = CalculatorLogic()    // Struct for dealing with all the calculator logic
    private var binaryOperationButtons: [UIButton]!    // Array of all binary operation buttons ("÷", "×", "+", "-")
    private var displayValue: Double? {                // Computed property to deal with the Display Value (Number vs String)
        
        get {
            if displayLabel.text == calculatorLogic.ERROR_DISPLAY {
                return 0
            }
            
            return calculatorLogic.formatStringToNumber(displayLabel.text!)
        }
        
        set {
            if let value = newValue {
                if value.magnitude <= calculatorLogic.MAX_MAGNITUDE_ALLOWED {
                    displayLabel.text = calculatorLogic.formatNumberToString(value)
                    return
                }
            }
            
            displayLabel.text = calculatorLogic.ERROR_DISPLAY
        }
    }
    
    // MARK: - UI elements references
    @IBOutlet weak private var displayLabel: UILabel!
    @IBOutlet weak private var divButton: UIButton!
    @IBOutlet weak private var multButton: UIButton!
    @IBOutlet weak private var minusButton: UIButton!
    @IBOutlet weak private var plusButton: UIButton!

    // MARK: - Lifecyle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        binaryOperationButtons = [divButton, multButton, minusButton, plusButton]
    }
    
    // MARK: - Button action handlers
    @IBAction private func numButtonPressed(_ sender: UIButton) {

        deselectBinaryOperationButtons()
        
        displayLabel.text = calculatorLogic.append(newChar: sender.currentTitle!, to: displayLabel.text!)

    }
    
    @IBAction private func operationButtonPressed(_ sender: UIButton) {
        
        deselectBinaryOperationButtons()
        
        if binaryOperationButtons.contains(sender) {
            sender.isSelected = true
        }
        
        displayValue = calculatorLogic.make(operation: sender.currentTitle!, withNumber: displayValue!)
    }
    
    private func deselectBinaryOperationButtons () {
        for button in binaryOperationButtons {
            button.isSelected = false
        }
    }
    
}

