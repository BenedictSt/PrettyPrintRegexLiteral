import Foundation
import ArgumentParser

struct PrettyPrintRegexLiteral: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "PrettyPrintRegexLiteral",
        abstract: "A command-line tool to pretty print regex literals.",
        subcommands: [])

    @Argument(help: "literal")
    private var literal: String
    
    func run() throws {
		let prettyPrinter = PrettyPrinter(input: literal)
		prettyPrinter.printOut()
    }
    
}

PrettyPrintRegexLiteral.main()
