import XCTest
@testable import LibCSV

class ParserTests: XCTestCase {
	func test_defaults() throws {
		let csv = "hello,world\nhello,gib\n"
		guard let data = csv.data(using: .utf8) else { XCTFail(); return }
		let output = try collect(parser: CSVParser(), data: data)
		XCTAssert(output == [["hello", "world"], ["hello", "gib"]])
	}

	func test_semicolon_delimiter() throws {
		let csv = "hello;world\nhello;gib\n"
		guard let data = csv.data(using: .utf8) else { XCTFail(); return }
		let parser = CSVParser()
		parser.delimiter = ";"
		let output = try collect(parser: parser, data: data)
		XCTAssert(output == [["hello", "world"], ["hello", "gib"]])
	}

	func test_tab_delimiter() throws {
		let csv = "hello\tworld\nhello\tgib\n"
		guard let data = csv.data(using: .utf8) else { XCTFail(); return }
		let parser = CSVParser()
		parser.delimiter = "\t"
		let output = try collect(parser: parser, data: data)
		XCTAssert(output == [["hello", "world"], ["hello", "gib"]])
	}

	func test_quoted() throws {
		let csv = "contains \"quotes\",\"\"quoted text\"\""
		guard let data = csv.data(using: .utf8) else { XCTFail(); return }
		let output = try collect(parser: CSVParser(), data: data)
		XCTAssert(output == [["contains \"quotes\"", "\"quoted text\""]])
	}
}

extension ParserTests {
	static var allTests : [(String, (ParserTests) -> () throws -> Void)] {
		return [
			("test_defaults", test_defaults),
			("test_semicolon_delimiter", test_semicolon_delimiter),
			("test_tab_delimiter", test_tab_delimiter),
			("test_quoted", test_quoted),
		]
	}
}


func collect(parser: CSVParser, data: Data) throws -> [[String]] {
	var rows = [[String]]()
	var row = [String]()
	parser.didReadField = { row.append($0) }
	parser.didReadRow = { _ in rows.append(row); row = [] }
	try parser.parse(data: data)
	return rows
}
