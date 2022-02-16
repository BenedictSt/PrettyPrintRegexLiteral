import Foundation
import ArgumentParser

struct PrettyPrintRegexLiteral: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "PrettyPrintRegexLiteral",
        abstract: "A command-line tool to pretty print regex literals.",
        subcommands: [])

    @Argument(help: "literal")
    private var literal: String
    
    mutating func run() throws {
        if(!literal.hasPrefix("/")){
            literal = "/" + literal
        }
        if(!literal.hasSuffix("/")){
            literal += "/"
        }
        try dumpPrint()
    }
    
    ///Prints based on opening / closing Parenthesis
    mutating func dumpPrint() throws{
        var startingBlocks: [Int] = []
        var linesToPrint: [String] = []
        var currentPosition = 0
        //MARK: - create Lines to print
        for currentChar in literal{
            switch currentChar {
            case "(":
                startingBlocks.append(currentPosition)
            case ")":
                guard let startIndex = startingBlocks.popLast() else{
                    throw "Too many closing Paranthesis"
                }
                let whiteSpaces = Array(repeating: " ", count: 12 + startIndex).joined()
                let dashes = Array(repeating: "-", count: currentPosition - startIndex).joined()
                let whiteBeforeDescription = Array(repeating: " ", count: (literal.count) - currentPosition).joined()
                let text = literal.dropFirst(startIndex).dropLast(literal.count - currentPosition - 1)
                
                linesToPrint.append("//\(whiteSpaces)^\(dashes)\(whiteBeforeDescription)> \(text)")
            default:
                break
            }
            currentPosition += 1
        }
        //MARK: - Print out
        print("let literal = \(literal)")
        for line in linesToPrint.reversed(){
            print(line)
        }
    }
}

PrettyPrintRegexLiteral.main()

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
