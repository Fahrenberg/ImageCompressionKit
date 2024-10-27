import Foundation
import OSLog


extension Logger {
    static let subsystem = "\(Bundle.main.bundleIdentifier!)"
    static let source = Logger(subsystem: subsystem, category: "ImageCompression")
}
