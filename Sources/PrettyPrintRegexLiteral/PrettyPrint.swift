//
//  PrettyPrint.swift
//  
//
//  Created by Benedict on 18.02.22.
//

import Foundation

class PrettyPrinter{
	let literal: String
	
	var linesToPrint: [String] = []
	var messages: [String] = []
	var failed = false
	
	//MARK: working variables
	var startingBlocks: [(startingChar: String, index: Int)] = []
	var currentPosition = 0
	var closingElementMatches: String = ""
	var state = 0
	
	init(input: String){
		var tmpLiteral = input
		if(!input.hasPrefix("/")){
			tmpLiteral = "/" + input
		}
		if(!input.hasSuffix("/")){
			tmpLiteral += "/"
		}
		self.literal = tmpLiteral
		
		generateLines()
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
		
		linesToPrint.append("//\(whiteSpaces)^\(dashes)\(whiteBeforeDescription)> \(text)")
		state = 0
	}
	
	///Prints the generated lines and or errors/warnings out
	public func printOut(){
		print("let literal = \(literal)")
		if(!failed){
			for line in linesToPrint.reversed(){
				print(line)
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
