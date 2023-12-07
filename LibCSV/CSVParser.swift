// Source https://github.com/Bouke/CSV/blob/master/Sources/Parser.swift

import Foundation

public class CSVParser {
	private var currentRow = [String]()
	private var parser: csv_parser

	public init() {
		parser = csv_parser()
		precondition(csv_init(&parser, UInt8(CSV_APPEND_NULL)) == 0)
	}

	deinit { csv_free(&parser) }

	public var delimiter: Character {
		get {
			return Character(UnicodeScalar(csv_get_delim(&parser)))
		}
		set {
			csv_set_delim(&parser, String(newValue).utf8.first!)
		}
	}

	public var quote: Character {
		get {
			return Character(UnicodeScalar(csv_get_quote(&parser)))
		}
		set {
			csv_set_quote(&parser, String(newValue).utf8.first!)
		}
	}

	public var didReadField: ((String) -> ())?
	public var didReadRow: ((Character?) -> ())?

	public func parse(data: Data) throws {
		let context = Unmanaged.passUnretained(self).toOpaque()
		try data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> () in
			guard csv_parse(&parser, bytes.baseAddress, data.count, cb1, cb2, context) == data.count else {
				throw CSVError(error: csv_error(&parser))
			}
			csv_fini(&parser, cb1, cb2, context)
		}
	}
}

private func cb1(bytes: UnsafeMutableRawPointer?, length: Int, context: UnsafeMutableRawPointer?) {
	guard let context = context else { abort() }
	let parser = Unmanaged<CSVParser>.fromOpaque(context).takeUnretainedValue()
	guard let didReadField = parser.didReadField else { return }

	guard let bytes = bytes?.bindMemory(to: CChar.self, capacity: length) else { abort() }
	let string = String(cString: bytes)
	didReadField(string)
}


private func cb2(char: Int32, context: UnsafeMutableRawPointer?) -> Void {
	guard let context = context else { abort() }
	let parser = Unmanaged<CSVParser>.fromOpaque(context).takeUnretainedValue()
	guard let didReadRow = parser.didReadRow else { return }

	let character: Character?
	switch char {
	case -1: character = nil
	default: character = Character(UnicodeScalar(Int(char))!)
	}

	didReadRow(character)
}
