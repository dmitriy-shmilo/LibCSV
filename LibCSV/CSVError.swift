// Source https://github.com/Bouke/CSV/blob/master/Sources/Error.swift

import Foundation

public enum CSVError: Error {
	case parse
	case noMem
	case tooBig
	case invalid

	init(error: Int32) {
		switch error {
		case CSV_EPARSE: self = .parse
		case CSV_ENOMEM: self = .noMem
		case CSV_ETOOBIG: self = .tooBig
		case CSV_EINVALID: self = .invalid
		default: fatalError("Unknown error \(error)")
		}
	}
}
