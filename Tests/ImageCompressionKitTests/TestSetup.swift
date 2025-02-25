//
//  Logger.swift
//  ImageCompressionKit
//
//  Created by Jean-Nicolas on 27.10.2024.
//

import Foundation
import OSLog
import Extensions

@testable import ImageCompressionKit
import XCTest


extension Logger {
    static let subsystem = "\(Bundle.main.bundleIdentifier!)"
    static let test = Logger(subsystem: subsystem, category: "ImageCompressionTests")
}

enum ImageType: String, CaseIterable {
    case large, medium, small, small_center, small_left, small_right
    
    var imageAlignment: PlatformImage.ImageAlignment {
        switch self {
        case .small_center:
            return .center
        case .small_left:
            return .left
        case .small_right:
            return .right
        default:
            return .center
        }
    }
}

struct TestImage {
    static func image(size type: ImageType) -> PlatformImage? {
        let bundle = Bundle.module
        guard let imageURL = bundle.url(forResource: type.rawValue, withExtension: "bmp") else {
            return nil
        }
        #if canImport(UIKit)
        return UIImage(contentsOfFile: imageURL.path)
        #elseif canImport(AppKit)
        return NSImage(contentsOf: imageURL)
        #endif
    }
}


final class BundleImageTests: XCTestCase {
    func testAccessToImages() {
        let largeImage = TestImage.image(size: .large)
        XCTAssertNotNil(largeImage)
        Logger.test.info("largeImage  size: \(largeImage?.sizeDescription ?? "nil", privacy: .public)")

        let mediumImage = TestImage.image(size: .medium)
        XCTAssertNotNil(mediumImage)
        Logger.test.info("mediumImage size: \(mediumImage?.sizeDescription ?? "nil", privacy: .public)")

        let smallImage = TestImage.image(size: .small)
        XCTAssertNotNil(smallImage)
        Logger.test.info("smallImage  size: \(smallImage?.sizeDescription ?? "nil", privacy: .public)")
    }
}
