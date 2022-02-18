import XCTest
import class Foundation.Bundle

final class PrettyPrintRegexLiteralTests: XCTestCase {
	
	///Test if literal completion works
	///e.g. "abc/" => "/abc/"
	func testLiteralCompletion() throws {
		// Some of the APIs that we use below are available in macOS 10.13 and above.
		guard #available(macOS 10.13, *) else {
			return
		}
		
		#if !targetEnvironment(macCatalyst)
		let inputOutput: [(in: String, out: String)] = [
			("abc", "/abc/"),
			("/foo", "/foo/"),
			("test/", "/test/"),
			("/anotherOne/", "/anotherOne/")
		]
		let fooBinary = productsDirectory.appendingPathComponent("PrettyPrintRegexLiteral")
		for test in inputOutput{
			let process = Process()
			process.executableURL = fooBinary
			process.arguments = [test.in]
			let pipe = Pipe()
			process.standardOutput = pipe
			try process.run()
			process.waitUntilExit()
			let data = pipe.fileHandleForReading.readDataToEndOfFile()
			let output = String(data: data, encoding: .utf8)
			XCTAssertEqual(output, "let literal = \(test.out)\n")
		}
		#endif
	}

    /// Returns path to the built products directory.
    var productsDirectory: URL {
      #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
      #else
        return Bundle.main.bundleURL
      #endif
    }
}
