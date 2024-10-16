//
//  -------------------------------------------------------------------
//  ---------------     JPGCompressorTests		 --------------
//  ---------------					 --------------
//  -------					-------
//  -------------------------------------------------------------------

import XCTest

@testable import ImageCompressionKit

final class CompressionToDataTestsswift: XCTestCase {

    var largeImage: PlatformImage? {
        #if canImport(UIKit)
            return PlatformImage(named: "large", in: Bundle.module, with: nil)
        #elseif canImport(AppKit)
            // Manually specify the test bundle for macOS
            return Bundle.module.image(forResource: "large")
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
        print(
            "testJPGCompressorLargeData: Original-Size:", originalSize,
            "Compressed-Size:", resultBytes)

    }

    //MARK: HEIC Compressor
    func testHEICLargeData() throws {
        let heicQuality: CGFloat = 0.1
        let maxExpectedResultBytes: UInt64 = 500_000

        let image = try XCTUnwrap(largeImage)
        let originalSize = try XCTUnwrap(image.pngData()?.count)

        let compressedSize = try image.heicData(compressionQuality: heicQuality)
        let resultBytes = UInt64(try XCTUnwrap(compressedSize).count)
        XCTAssertLessThanOrEqual(resultBytes, maxExpectedResultBytes)
        print(
            "testHEICLargeData: Original-Size:", originalSize,
            "Compressed-Size:", resultBytes)

    }
}
