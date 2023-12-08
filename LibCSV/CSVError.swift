// Source https://github.com/Bouke/CSV/blob/master/Sources/Error.swift

import Foundation

public enum CSVError: Error {
	case parse
	case noMemory
	case tooBig
	case invalid

	case openFailed(code: Int32)
	case notOpened
	case writeFailed(code: Int32)
	case notAscii

	init(error: Int32) {
		switch error {
		case CSV_EPARSE:
			self = .parse
		case CSV_ENOMEM:
			self = .noMemory
		case CSV_ETOOBIG:
			self = .tooBig
		case CSV_EINVALID:
			self = .invalid
		default:
			fatalError("Unknown error \(error)")
		}
	}
}
