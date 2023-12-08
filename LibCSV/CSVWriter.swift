//

import Foundation

public class CSVWriter {
	public var delimeter: Character = ","
	public var quote: Character = "\""
	public var endLine: Character = "\n"
	public var encoding = String.Encoding.utf8

	private var fileHandle: UnsafeMutablePointer<FILE>?

	public init() {

	}

	public func start(opening url: URL) throws {
		guard url.isFileURL else {
			throw CSVError.openFailed(code: 0)
		}

		if #available(iOS 16.0, *) {
			fileHandle = fopen(url.path(percentEncoded: false), "wb")
		} else {
			fileHandle = fopen(url.path, "wb")
		}

		guard fileHandle != nil else {
			throw CSVError.openFailed(code: errno)
		}
	}

	public func write(field: String, lastInRow last: Bool)  throws {
		guard let fileHandle = fileHandle else {
			throw CSVError.notOpened
		}

		guard let data = field.data(using: encoding) else {
			throw CSVError.invalid
		}

		try data.withUnsafeBytes { bytes in
			guard csv_fwrite(self.fileHandle, bytes.baseAddress, bytes.count) == 0 else {
				throw CSVError.writeFailed(code: errno)
			}

			guard ferror(self.fileHandle) == 0 else {
				throw CSVError.writeFailed(code: errno)
			}
		}

		if last {
			return
		}

		guard let delimeter = delimeter.asciiValue  else {
			throw CSVError.notAscii
		}

		guard fputc(Int32(delimeter), fileHandle) != EOF else {
			throw CSVError.writeFailed(code: errno)
		}

		guard ferror(self.fileHandle) == 0 else {
			throw CSVError.writeFailed(code: errno)
		}
	}

	public func writeRow() throws {
		guard let endLine = endLine.asciiValue else {
			throw CSVError.notAscii
		}

		guard fputc(Int32(endLine), fileHandle) != EOF else {
			throw CSVError.writeFailed(code: ferror(self.fileHandle))
		}

		guard ferror(self.fileHandle) == 0 else {
			throw CSVError.writeFailed(code: errno)
		}
	}

	public func finish() throws {
		guard let fileHandle = fileHandle else {
			throw CSVError.notOpened
		}

		guard fclose(fileHandle) == 0 else {
			throw CSVError.writeFailed(code: errno)
		}
		self.fileHandle = nil
	}

	deinit {
		guard let fileHandle = fileHandle else {
			return
		}
		fclose(fileHandle)
	}
}
