//
//  ColoredParenthesis.swift
//  
//
//  Created by Benedict on 19.02.22.
//

import Foundation

class ColoredParenthesis{
    
    ///Colorcodes matching parenthesis in literal
    ///
    ///This function assumes that the parenthesis do match. This should be checked before!
    ///- Parameter literal: literal to colorcode
    ///- Parameter colored: whether the colorcoding should be active
    ///- Returns: literal but with colorcoded parenthesis when printed out to the command line
    static func colorcodedLiteral(literal: String, colored: Bool) -> String{
        if(!colored){
            return literal
        }
        let coloresToUse: [ANSIColors] = [.yellow,.blue,.magenta,.cyan,.red,.green,.white,.black]
        
        var openColorStack: [ANSIColors] = []
        var colorIndex = 0
        var outputString = ""
        
        for position in (0..<literal.count){
            let currentChar: String = String(Array(literal)[position])
            
            switch currentChar{
            case "(", "[":
                outputString += "\u{001B}[1m" + currentChar.colored(coloresToUse[colorIndex])
                openColorStack.append(coloresToUse[colorIndex])
                colorIndex += 1
                if(colorIndex >= coloresToUse.count){
                    colorIndex = 0
                }
            case ")", "]":
                outputString += "\u{001B}[1m" + currentChar.colored(openColorStack.popLast() ?? .default)
            default:
                outputString += currentChar
            }
        }
        return outputString
    }
}
