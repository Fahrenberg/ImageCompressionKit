//
//  -------------------------------------------------------------------
//  ---------------     JPGCompressorTests		 --------------
//  ---------------					 --------------
//  -------					-------
//  -------------------------------------------------------------------


import XCTest
@testable import CompressorKit

final class JPGCompressorTests: XCTestCase {

    func testBundleAccessToImage() {
        let image = UIImage(named: "large", in: Bundle.module, with: nil)
        
        XCTAssertNotNil(image)
    }
    
    //MARK: JPGCompressor
    func testJPGCompressorLargeData()  throws {
        let imageName = "large"
        let jpgQuality: CGFloat = 0.1
        let maxExpectedResultBytes: UInt64 = 520_000
        
        let image = try XCTUnwrap(UIImage(named: imageName, in: Bundle.module, with: nil))
        let originalSize = try XCTUnwrap(image.pngData()?.count)
        
        let compressedSize = try image.jpgCompressorData(compressionQuality: jpgQuality)
        let resultBytes = UInt64(try XCTUnwrap(compressedSize).count)
        XCTAssertLessThanOrEqual(resultBytes, maxExpectedResultBytes)
        print("testJPGCompressorLargeData: Original-Size:", originalSize, "Compressed-Size:", resultBytes)
        
    }

    func test5ImagesToJPGCompressorWithData() throws {
        let imageCount = 5
        let imageName = "large"
        let jpgQuality: CGFloat = 0.1
        let maxExpectedResultBytes: UInt64 = 520_000
        let expectedBytes = maxExpectedResultBytes * UInt64(imageCount)
        
        let image = try XCTUnwrap(UIImage(named: imageName, in: Bundle.module, with: nil))
        let originalBytes = try XCTUnwrap(image.pngData()?.count) * imageCount
        
        let images = Array(repeating: image, count: imageCount)
        
        let data = JPGCompressor.compressToJPGData(for: images, compressionQuality: jpgQuality)
        XCTAssertFalse(data.isEmpty)
        XCTAssertEqual(data.count, images.count)
        let jpgCompressedBytes = UInt64(data.reduce(0) { $0 + $1.count})
        print("test5JPGCompressorImagesData originalSize \(originalBytes), jpg compressed size \(jpgCompressedBytes)")
        XCTAssertLessThanOrEqual(jpgCompressedBytes, expectedBytes)
    }

    func test5JPGCompressorImagesDataAsync() async throws {
        let imageCount = 5
        let imageName = "large"
        let jpgQuality: CGFloat = 0.1
        let maxExpectedResultBytes: UInt64 = 520_000
        let expectedBytes = maxExpectedResultBytes * UInt64(imageCount)
        
        let image = try XCTUnwrap(UIImage(named: imageName, in: Bundle.module, with: nil))
        let originalBytes = try XCTUnwrap(image.pngData()?.count) * imageCount
        
        let images = Array(repeating: image, count: imageCount)
        
        let data = await JPGCompressor.compressToHEICDataAsync(for: images, compressionQuality: jpgQuality)
        XCTAssertFalse(data.isEmpty)
        XCTAssertEqual(data.count, images.count)
        let jpgCompressedBytes = UInt64(data.reduce(0) { $0 + $1.count})
        print("test5JPGCompressorImagesDataAsync originalSize \(originalBytes), jpg compressed size \(jpgCompressedBytes)")
        XCTAssertLessThanOrEqual(jpgCompressedBytes, expectedBytes)
    }

}
