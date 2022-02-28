//
//  PrettyPrint.swift
//  
//
//  Created by Benedict on 18.02.22.
//

import Foundation

class PrettyPrinter{
	var literal: String
    let colored: Bool
	
	var linesToPrint: [(index: Int, message: String)] = []
	var messages: [String] = []
	var failed = false
	
	//MARK: working variables
	var startingBlocks: [(startingChar: String, index: Int)] = []
	var currentPosition = 0
	var closingElementMatches: String = ""
	var state = 0
	
    init(input: String, colored: Bool){
        self.literal = input
        self.colored = colored
        formatInput()
        if(!failed){
            generateLines()
        }
	}
	
    ///Formats the input
    ///
    ///Adds '/' at the beginning or ending if necessary
    ///also checks whether the flags are valid or not
    private func formatInput(){
        if(!literal.hasPrefix("/")){
            literal = "/" + literal
        }
        
        let fullInputRange = NSRange(location: 0, length: literal.utf16.count)
        let regexLiteralEndings = try! NSRegularExpression(pattern: "[^\\\\]\\/")
        
        let literlEndings = regexLiteralEndings.matches(in: literal, options: [], range: fullInputRange)
        switch literlEndings.count{
        case 0:
            literal += "/"
        case 1:
            let regexFlags = try! NSRegularExpression(pattern: ".\\/[ixsmw]*$")
            if let endRange = regexFlags.matches(in: literal, options: [], range: fullInputRange).last?.range{
                let flags = literal.suffix(endRange.upperBound - endRange.lowerBound - 2)
                //Check if one flag is set multiple times
                var flagsDict: [Character : Int] = [:]
                for flag in flags{
                    flagsDict[flag, default: 0] += 1
                }
                for flagEntry in flagsDict{
                    if(flagEntry.value > 1){
                        messages.append("Warning: flag '\(flagEntry.key)' appeared \(flagEntry.value) times".colored(.yellow))//TODO: show flags
                    }
                }
                
            }else{
                failed = true
                let flags = literal.suffix(literal.count - literlEndings.last!.range.upperBound)
                messages.append("Error: invalid flags: \(flags)".colored(.red))
            }
        default:
            failed = true
            messages.append("Error: too many closing symbols".colored(.red))
        }
    }
    
	///Generates the output lines
	private func generateLines(){
		
		for currentChar in literal{
			switch currentChar {
			case "(":
				if(state > 0){
					addLine()
				}
				startingBlocks.append(("(", currentPosition))
			case "[":
				if(state > 0){
					addLine()
				}
				startingBlocks.append(("[", currentPosition))
			case ")":
				closingElementMatches = "("
				if(state > 0){
					addLine()
				}
				state = 1
			case "]":
				closingElementMatches = "["
				if(state > 0){
					addLine()
				}
				state = 1
			case "+", "?":
				if state == 2{
					state = 3
					break
				}
				fallthrough
			case "*", "+", "?":
				if(state == 1){
					state = 2
					break
				}
				fallthrough
			default:
				if(state > 0){
					addLine()
				}
				break
			}
			currentPosition += 1
		}
		if(!startingBlocks.isEmpty){
			messages.append("Warning: not all parenthesis closed".colored(.yellow))
		}
	}
	
	private func addLine(){
		let top = startingBlocks.popLast()
		guard let startIndex = top?.index else{
			messages.append("Error: too many closing parenthesis".colored(.red))
			failed = true
			return
		}
		if(top!.startingChar != closingElementMatches){
			messages.append("Error: parenthesis do not match: \(top!.startingChar) != \(closingElementMatches)".colored(.red))
			failed = true
			return
		}
		let whiteSpaces = Array(repeating: " ", count: 12 + startIndex).joined()
		let dashes = Array(repeating: "-", count: currentPosition - 1 - startIndex).joined()
		let whiteBeforeDescription = Array(repeating: " ", count: (literal.count) - (currentPosition - 1)).joined()
		let text = literal.dropFirst(startIndex).dropLast(literal.count - currentPosition)
		
		linesToPrint.append((index: startIndex, message: "//\(whiteSpaces)^\(dashes)\(whiteBeforeDescription)> \(text)"))
		state = 0
	}
	
	///Prints the generated lines and or errors/warnings out
	public func printOut(){
        print("let literal = \(ColoredParenthesis.colorcodedLiteral(literal: literal, colored: colored))")
		if(!failed){
			for line in linesToPrint.sorted(by: {$0.index < $1.index}){
				print(line.message)
			}
		}
		for message in messages{
			print(message)
		}
	}
}


/*
 let literal = /(a)+(b)/
 //            ^--------  :/(a)+(b)/
 //             ^---      :(a)+
 //                 ^--   :(b)
 */

/*
 Blocks:
 (: start block
 ): close block
 */
