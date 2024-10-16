//
//  -------------------------------------------------------------------
//  ---------------     JPGCompressorTests		 --------------
//  ---------------					 --------------
//  -------					-------
//  -------------------------------------------------------------------

import XCTest
import OSLog

@testable import ImageCompressionKit

final class ImageCompressionKitTests: XCTestCase {

    var largeImage: PlatformImage? {
        let bundle = Bundle.module
        let largeImageURL  = bundle.url(forResource: "large", withExtension: "png")!
        #if canImport(UIKit)
        return UIImage(contentsOfFile: largeImageURL.path)
        #elseif canImport(AppKit)
        return NSImage(contentsOf: largeImageURL)
        #endif
    }

    func testBundleAccessToImage() {
        let image = largeImage
        XCTAssertNotNil(image)
    }

    //MARK: JPGCompressor
    func testJPGCompressorLargeData() throws {
        let jpgQuality: CGFloat = 0.1
        let maxExpectedResultBytes: UInt64 = 520_000

        let image = try XCTUnwrap(largeImage)
        let originalSize = try XCTUnwrap(image.pngData()?.count)

        let compressedSize = try image.jpgCompressorData(
            compressionQuality: jpgQuality)
        let resultBytes = UInt64(try XCTUnwrap(compressedSize).count)
        XCTAssertLessThanOrEqual(resultBytes, maxExpectedResultBytes)
        Logger.test.info(
            """
            testJPGCompressorLargeData: 
            Original-Size: \(originalSize) 
            Compressed-Size: \(resultBytes)
            Factor: \(Double(originalSize) / (Double(resultBytes)))x smaller
            """
        )

    }

    //MARK: HEIC Compressor
    func testHEICLargeData() throws {
        let heicQuality: CGFloat = 0.1
        let maxExpectedResultBytes: UInt64 = 105_000

        let image = try XCTUnwrap(largeImage)
        let originalSize = try XCTUnwrap(image.pngData()?.count)

        let compressedSize = try image.heicData(compressionQuality: heicQuality)
        let resultBytes = UInt64(try XCTUnwrap(compressedSize).count)
        XCTAssertLessThanOrEqual(resultBytes, maxExpectedResultBytes)
        Logger.test.info(
            """
            testHEICLargeData: 
            Original-Size: \(originalSize) 
            Compressed-Size: \(resultBytes)
            Factor: \(Double(originalSize) / (Double(resultBytes)))x smaller
            """
        )

    }
}

extension Logger {
    fileprivate static let test = Logger(subsystem: subsystem, category: "ImageCompressionKitTests")
    
    
}
