//
//  Logger.swift
//  ImageCompressionKit
//
//  Created by Jean-Nicolas on 27.10.2024.
//

import Foundation
import OSLog
@testable import ImageCompressionKit
import XCTest


extension Logger {
    static let subsystem = "\(Bundle.main.bundleIdentifier!)"
    static let test = Logger(subsystem: subsystem, category: "ImageCompressionTests")
}

struct TestImage {
    static var large: PlatformImage? {
        let bundle = Bundle.module
        let largeImageURL  = bundle.url(forResource: "large", withExtension: "png")!
        #if canImport(UIKit)
        return UIImage(contentsOfFile: largeImageURL.path)
        #elseif canImport(AppKit)
        return NSImage(contentsOf: largeImageURL)
        #endif
    }
    
    static var small: PlatformImage? {
        let bundle = Bundle.module
        let largeImageURL  = bundle.url(forResource: "small", withExtension: "jpeg")!
        #if canImport(UIKit)
        return UIImage(contentsOfFile: largeImageURL.path)
        #elseif canImport(AppKit)
        return NSImage(contentsOf: largeImageURL)
        #endif
    }

}

final class BundleImageTests: XCTestCase {
    func testAccessToImages() {
        let largeImage = TestImage.large
        XCTAssertNotNil(largeImage)
        let smallImage = TestImage.small
        XCTAssertNotNil(smallImage)
    }
}
