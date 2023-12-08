//

import Foundation

public protocol CSVReaderDelegate: AnyObject {
	func csvReader(_ reader: CSVReader, didReadField field: String)
	func csvReader(_ reader: CSVReader, didReadRowTerminatedBy character: Character?)
	func csvReaderDidFinish(_ reader: CSVReader)
}
