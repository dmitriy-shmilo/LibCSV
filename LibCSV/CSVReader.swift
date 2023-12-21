// Source https://github.com/Bouke/CSV/blob/master/Sources/Parser.swift

import Foundation

public class CSVReader {
	private static let bufferSize = 4096;
	private var currentRow = [String]()
	private var parser = csv_parser()

	public init() {
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

	public weak var delegate: CSVReaderDelegate?

	public func parse(data: Data) throws {
		let context = Unmanaged.passUnretained(self).toOpaque()
		try data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> () in
			guard csv_parse(&parser, bytes.baseAddress, data.count, cb1, cb2, context) == data.count else {
				throw CSVError(error: csv_error(&parser))
			}
			csv_fini(&parser, cb1, cb2, context)
			delegate?.csvReaderDidFinish(self)
		}
	}

	public func parse(url: URL) throws {
		guard url.isFileURL else {
			throw CSVError.openFailed(code: 0)
		}

		var fileHandle: UnsafeMutablePointer<FILE>?
		if #available(iOS 16.0, *) {
			fileHandle = fopen(url.path(percentEncoded: false), "rb")
		} else {
			fileHandle = fopen(url.path, "rb")
		}

		guard fileHandle != nil else {
			throw CSVError.openFailed(code: errno)
		}

		let context = Unmanaged.passUnretained(self).toOpaque()
		let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Self.bufferSize)
		defer { buffer.deallocate() }

		var parser = csv_parser()
		precondition(csv_init(&parser, UInt8(CSV_APPEND_NULL)) == 0)
		csv_fparse(&parser, fileHandle, buffer, Self.bufferSize, cb1, cb2, context)
		csv_fini(&parser, cb1, cb2, context)

		guard parser.status == 0 else {
			throw CSVError(error: csv_error(&parser))
		}

		fclose(fileHandle)
		delegate?.csvReaderDidFinish(self)
	}
}

private func cb1(bytes: UnsafeMutableRawPointer?, length: Int, context: UnsafeMutableRawPointer?) {
	guard let context = context else {
		fatalError("CSVParser, missing context in the field read callback.")
	}

	let reader = Unmanaged<CSVReader>.fromOpaque(context).takeUnretainedValue()
	guard let delegate = reader.delegate else {
		return
	}

	guard let bytes = bytes?.bindMemory(to: CChar.self, capacity: length) else {
		fatalError("CSVParser, failed to bind parsed field memory.")
	}
	let string = String(cString: bytes)
	delegate.csvReader(reader, didReadField: string)
}


private func cb2(char: Int32, context: UnsafeMutableRawPointer?) -> Void {
	guard let context = context else {
		fatalError("CSVParser, missing context in the row read callback.")
	}
	
	let reader = Unmanaged<CSVReader>.fromOpaque(context).takeUnretainedValue()
	guard let delegate = reader.delegate else {
		return
	}

	guard char != -1, let scalar = UnicodeScalar(Int(char)) else {
		delegate.csvReader(reader, didReadRowTerminatedBy: nil)
		return
	}

	delegate.csvReader(reader, didReadRowTerminatedBy: Character(scalar))
}
