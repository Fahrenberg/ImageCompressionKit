//
//  ------------------------------------------------
//  -----------   HEICCompressorUnitTests -----------------
//  ------------------------------------------------
//
    

import XCTest
@testable import CompressorKit


final class UnitTestsHEICCompressor: XCTestCase {

    func testBundleAccessToImage() {
        let image = UIImage(named: "large", in: Bundle.module, with: nil)
        
        XCTAssertNotNil(image)
    }
    
    
//MARK: HEIC Compressor
func testHEICLargeData()  throws {
    let imageName = "large"
    let heicQuality: CGFloat = 0.1
    let maxExpectedResultBytes: UInt64 = 500_000
    
    let image = try XCTUnwrap(UIImage(named: imageName, in: Bundle.module, with: nil))
    let originalSize = try XCTUnwrap(image.pngData()?.count)
    
    let compressedSize = try image.heicData(compressionQuality: heicQuality)
    let resultBytes = UInt64(try XCTUnwrap(compressedSize).count)
    XCTAssertLessThanOrEqual(resultBytes, maxExpectedResultBytes)
    print("testHEICLargeData: Original-Size:", originalSize, "Compressed-Size:", resultBytes)
    
}

func test5HEICImagesData() throws {
    let imageCount = 5
    let imageName = "large"
    let heicQuality: CGFloat = 0.1
    let expectedBytes = 500_000 * imageCount
    
    let image = try XCTUnwrap(UIImage(named: imageName, in: Bundle.module, with: nil))
    let originalBytes = try XCTUnwrap(image.pngData()?.count) * imageCount
    
    let images = Array(repeating: image, count: imageCount)
    
    let data = HEICCompressor.compressToHEICData(for: images, compressionQuality: heicQuality)
    XCTAssertFalse(data.isEmpty)
    XCTAssertEqual(data.count, images.count)
    let heicCompressedBytes = data.reduce(0) { $0 + $1.count}
    print("test5HEICImagesData originalSize \(originalBytes), heic compressed size \(heicCompressedBytes)")
    XCTAssertLessThanOrEqual(heicCompressedBytes, expectedBytes)
}

func test5HEICImagesDataAsync() async throws {
    let imageCount = 5
    let imageName = "large"
    let heicQuality: CGFloat = 0.1
    let expectedBytes = 500_000 * imageCount
    
    let image = try XCTUnwrap(UIImage(named: imageName, in: Bundle.module, with: nil))
    let originalBytes = try XCTUnwrap(image.pngData()?.count) * imageCount
    
    let images = Array(repeating: image, count: imageCount)
    
    let data = await HEICCompressor.compressToHEICDataAsync(for: images, compressionQuality: heicQuality)
    XCTAssertFalse(data.isEmpty)
    XCTAssertEqual(data.count, images.count)
    let heicCompressedBytes = data.reduce(0) { $0 + $1.count}
    print("test5HEICImagesDataAsync originalSize \(originalBytes), heic compressed size \(heicCompressedBytes)")
    XCTAssertLessThanOrEqual(heicCompressedBytes, expectedBytes)
}

    

}
