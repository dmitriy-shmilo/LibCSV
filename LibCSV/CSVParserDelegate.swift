//

import Foundation

public protocol CSVParserDelegate: AnyObject {
	func csvParser(_ parser: CSVParser, didReadField field: String)
	func csvParser(_ parser: CSVParser, didReadRowTerminatedBy character: Character?)
	func csvParserDidFinish(_ parser: CSVParser)
}
