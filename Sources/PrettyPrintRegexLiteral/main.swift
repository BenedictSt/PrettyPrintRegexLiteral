import Foundation
import ArgumentParser

struct PrettyPrintRegexLiteral: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "PrettyPrintRegexLiteral",
        abstract: "A command-line tool to pretty print regex literals.",
        subcommands: [])

    @Argument(help: "literal")
    private var literal: String
    
//    @Flag(name: .short, inversion: "c", exclusivity: "abc", help: "Need to work on")
//    private var colored: Bool
    
    @Flag(name: [.short, .long], help: "Colorcode matching parenthesis")
    var colored = false
    
    func run() throws {
        let prettyPrinter = PrettyPrinter(input: literal, colored: colored)
		prettyPrinter.printOut()
    }
    
}

PrettyPrintRegexLiteral.main()
