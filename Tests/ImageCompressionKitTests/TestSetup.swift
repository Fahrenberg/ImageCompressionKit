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

enum ImageType: String {
    case small, medium, large, small_center
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

extension PlatformImage {
    var sizeDescription: String {
        let width = Int(self.size.width)
        let height = Int(self.size.height)
        return "w:\(width) x h:\(height)"
    }
}

extension PlatformImage {
    func writeToDisk(filename: String) throws {
        let testDir: URL
        let fileURL: URL
        // write image to disk for preview
        let subDirPath = Bundle.module.bundleIdentifier ?? "test"
        if #available(iOS 16.0, *) {
            testDir = FileManager().temporaryDirectory.appending(path: subDirPath)
            fileURL = testDir.appending(path: "\(filename)")
        } else {
            testDir = FileManager().temporaryDirectory.appendingPathComponent(subDirPath)
            fileURL = testDir.appendingPathComponent("\(filename)")
        }
        try FileManager.default.createDirectory(at: testDir, withIntermediateDirectories: true)
        guard let data = self.pngData() else {
            throw "Cannot save image to URL:\n\(fileURL.absoluteString)"
        }
        try data.write(to: fileURL)
        Logger.test.info("Saved Image to URL:\n\(fileURL.absoluteString)")
    }
    
}
