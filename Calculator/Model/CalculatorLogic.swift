//
//  CalculatorLogic.swift
//  Calculator
//
//  Created by Cássio Marcos Goulart on 23/05/19.
//  Copyright © 2019 CMG Solutions. All rights reserved.
//

import Foundation

struct CalculatorLogic {

    // MARK: - Instance properties
    private var newBinaryOperation = false
    private var timesPressedEqualsInSequence = 0
    private var calcTuple: (num: Double, op: String)?
    private let formatter = NumberFormatter()
    let MAX_MAGNITUDE_ALLOWED = 99999999999.9999  // -> define the maximum magnitude (+/- number) for this calculator, based on the Double capacity
    let ERROR_DISPLAY = "Error (∞)"               // -> text to display when there's an error (ex: when the maximum magnitude is exceeded)
    
    // List of all operations handled by the calculator, should have the exact same title as the button in the story board.
    private let ALLCLEAR_OP = "AC"
    private let SIGNAL_OP = "+/-"
    private let PERCENT_OP = "%"
    private let DIVIDE_OP = "÷"
    private let MULTIPLY_OP = "×"
    private let SUBTRACT_OP = "-"
    private let ADDITION_OP = "+"
    private let EQUAL_OP = "="
    
    // MARK: - Instance initializer
    init() {
        // Set up the Number Formatting style
        formatter.minimumIntegerDigits = 1       // -> garantees that there will be at least 1 leading zero, ex: ".85" becomes "0.85"
        formatter.maximumIntegerDigits = 11      // -> maximum integer digits allowed for this calculator is 11, to prevent exceeding the Double capacity
        formatter.minimumFractionDigits = 0      // -> minimum decimal digitis set to none, it's okey to display "7", instead of "7.0"
        formatter.maximumFractionDigits = 4      // -> maximum decimal digits allowed for this calculator is 4, to prevent exceeding the Double capacity
        formatter.decimalSeparator = "."         // -> US decimal separator style, ex: "3.1415"
        formatter.groupingSeparator = ","        // -> US grouping separator style, ex: "15,927,312.22"
        formatter.groupingSize = 3               // -> there should be a grouping separator char in between every 3 integer digits, ex: "15,927,312.22"
        formatter.usesGroupingSeparator = true   // -> should use grouping separator, ex: "15,927,312.22" instead of "15927312.22"
    }
    
    // MARK: - Display Label handler methods
    // Handle new inputs for the display (i.e. inputs from the number buttons and the dot button)
    mutating func append(newChar numPressed: String, to displayLabel: String) -> String {
        
        if newBinaryOperation {
            newBinaryOperation = false
            
            return numPressed == "." ? "0." : numPressed
        }
        
        if numPressed == "." && displayLabel.contains(".") { return displayLabel}
        
        if numPressed == "." { return displayLabel + "." }
        
        if displayLabel == "0" || displayLabel == ERROR_DISPLAY { return numPressed }
        
        let appendedDisplayNumber = (displayLabel + numPressed)
        return formatStringNumberWithSeparatorToString(appendedDisplayNumber)   
    }
    
    // MARK: - Number vs String formatter methods
    func formatNumberToString(_ number: Double) -> String {
        
        guard let formatedStringNumber = formatter.string(from: NSNumber(value: number)) else {
            fatalError("Could not convert number to a formatedStringNumber in func formatStringNumber.")
        }
        
        return formatedStringNumber
    }
    
    func formatStringToNumber(_ string: String) -> Double {
        
        guard let number = formatter.number(from: string) else {
            fatalError("Could not convert numberString to a number.")
        }
        
        return number.doubleValue
    }
    
    private mutating func formatStringNumberWithSeparatorToString(_ stringNumber: String) -> String {
        
        let stringNumberWithoutSeparator = stringNumber.replacingOccurrences(of: formatter.groupingSeparator, with: "")
        
        guard let number = formatter.number(from: stringNumberWithoutSeparator) else {
            fatalError("Could not convert stringNumberWithoutSeparator to a number in func formatStringNumber.")
        }
        
        if number.doubleValue.magnitude > MAX_MAGNITUDE_ALLOWED {
            resetCalculator()
            return ERROR_DISPLAY
        }
        
        guard let formatedStringNumber = formatter.string(from: number) else {
            fatalError("Could not convert number to a formatedStringNumber in func formatStringNumber.")
        }
        
        return formatedStringNumber
    }
    
    
    // MARK: - Operation logic methods
    // Handle all the operation logic, i.e. every time an operation button is pressed (namely: AC, +/-, %, ÷, ×, -, +, =)
    mutating func make(operation: String, withNumber number: Double) -> Double? {
        
        switch operation {
            
        case ALLCLEAR_OP:
            resetCalculator()
            return 0
            
        case SIGNAL_OP:
            return number * -1
            
        case PERCENT_OP:
            return number / 100
            
        case EQUAL_OP:
            timesPressedEqualsInSequence += 1
            
            var result: Double? = number
            
            // if there is a tuple, then calculate the result
            if calcTuple != nil {
                if timesPressedEqualsInSequence == 1 {
                    result = calculate(operation: calcTuple!.op, n1: calcTuple!.num, n2: number)
                    calcTuple!.num = number
                    
                } else {
                    // repeat the last operation if the user repeatedly press the "=" button
                    result = calculate(operation: calcTuple!.op, n1: number, n2: calcTuple!.num)
                }
            }
            
            // reset data if result is invalid
            if result == nil {
                resetCalculator()
            }
            
            return result
            
        default:
            // indicates that a new binary operation is being calculated (i.e: "÷", "×", "-", "+")
            newBinaryOperation = true
            
            // if there is a tuple, then calculate the result and update the tuple
            if calcTuple != nil && timesPressedEqualsInSequence == 0 {
                
                if let result = calculate(operation: calcTuple!.op, n1: calcTuple!.num, n2: number) {
                    calcTuple!.num = result
                    calcTuple!.op = operation
                    
                    return result
                    
                } else {
                    // reset data if result is invalid
                    resetCalculator()
                    return nil
                }

            } else {
                // if there isn't a tuple, create one and wait for the next button pressed to complete the operation
                timesPressedEqualsInSequence = 0
                calcTuple = (number, operation)
                
                return number
            }
        }
    }
    
    // Calculate operation between two numbers
    private mutating func calculate(operation: String, n1: Double, n2: Double) -> Double? {
        
        var result = 0.0
        
        switch operation {
            
        case DIVIDE_OP:
            result = n1 == 0 ? 0 : n1 / n2
        
        case MULTIPLY_OP:
            result = n1 * n2
            
        case SUBTRACT_OP:
            result = n1 - n2
            
        case ADDITION_OP:
            result = n1 + n2
            
        default:
            fatalError("Unknown Operation: \(operation)")
        }
        
        // Returns nil if result is considered invalid
        if result.isNaN || result.isSignalingNaN || result.isInfinite || result.magnitude > MAX_MAGNITUDE_ALLOWED { return nil }
        
        return result
    }
    
    // Reset calculator logic state
    private mutating func resetCalculator () {
        calcTuple = nil
        timesPressedEqualsInSequence = 0
        newBinaryOperation = false
    }

}
