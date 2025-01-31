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
        let imageURL  = bundle.url(forResource: "large", withExtension: "png")!
        #if canImport(UIKit)
        return UIImage(contentsOfFile: largeImageURL.path)
        #elseif canImport(AppKit)
        return NSImage(contentsOf: imageURL)
        #endif
    }
    
    static var small: PlatformImage? {
        let bundle = Bundle.module
        let imageURL  = bundle.url(forResource: "small", withExtension: "jpeg")!
        #if canImport(UIKit)
        return UIImage(contentsOfFile: largeImageURL.path)
        #elseif canImport(AppKit)
        return NSImage(contentsOf: imageURL)
        #endif
    }

     static var medium: PlatformImage? {
        let bundle = Bundle.module
        let imageURL  = bundle.url(forResource: "medium", withExtension: "jpeg")!
        #if canImport(UIKit)
        return UIImage(contentsOfFile: largeImageURL.path)
        #elseif canImport(AppKit)
        return NSImage(contentsOf: imageURL)
        #endif
    }

}

final class BundleImageTests: XCTestCase {
    func testAccessToImages() {
        let largeImage = TestImage.large
        XCTAssertNotNil(largeImage)
        Logger.test.info("largeImage  size: \(largeImage?.sizeDescription ?? "nil", privacy: .public)")
        let mediumImage = TestImage.medium
        XCTAssertNotNil(mediumImage)
        Logger.test.info("mediumImage size: \(mediumImage?.sizeDescription ?? "nil", privacy: .public)")
        let smallImage = TestImage.small
        XCTAssertNotNil(smallImage)
        Logger.test.info("smallImage  size: \(smallImage?.sizeDescription ?? "nil", privacy: .public)")
    }
}

extension PlatformImage {
    var sizeDescription: String {
        let width = Int(self.size.width)
        let height = Int(self.size.height)
        return "w:\(width) x h:\(height)"
    }
}