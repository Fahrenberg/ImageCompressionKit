import XCTest
@testable import CompressorKit

final class UnitTestsImageCompressor: XCTestCase {
    
    func testBundleAccessToImage() {
        let image = UIImage(named: "large", in: Bundle.module, with: nil)
        
        XCTAssertNotNil(image)
    }
  
    
//MARK: Image Bytes Compressor
    func testCompressLarge()  throws{
        let imageName = "large"
        let maxBytes: UInt64 = 2_000_000
        let expectedBytes: UInt64 = 1_000_000
        
        let image = try XCTUnwrap(UIImage(named: imageName, in: Bundle.module, with: nil))
        let originalSize = try XCTUnwrap(image.pngData()?.count)
        
        let compressedImage = ImageCompressor.compress(image: image, maxBytes: maxBytes)
        
        let resultImage = try XCTUnwrap(compressedImage)
        
        XCTAssertNotNil(resultImage)
        let imageSize = resultImage.pngData()?.count
        let resultSize = UInt64(try XCTUnwrap(imageSize))
        XCTAssertLessThanOrEqual(resultSize, maxBytes)
        XCTAssertLessThanOrEqual(resultSize, expectedBytes)
        print("testCompressLarge \(imageName) - maxBytes \(maxBytes)): Original-Size:", originalSize, "Compressed-Size:", resultSize)
    }
    
    func testCompressLargeWith0_5Compression() throws {
        let imageName = "large"
        let maxBytes: UInt64 = 2_000_000
        let startCompression = 0.5
        let expectedBytes: UInt64 = 1_000_000
        
        let image = try XCTUnwrap(UIImage(named: imageName, in: Bundle.module, with: nil))
        let originalSize = try XCTUnwrap(image.pngData()?.count)
        
        let compressedImage = ImageCompressor.compress(image: image,
                                                       maxBytes: maxBytes,
                                                       startCompression: startCompression)
        
        let resultImage = try XCTUnwrap(compressedImage)
        
        XCTAssertNotNil(resultImage)
        let imageSize = resultImage.pngData()?.count
        let resultSize = UInt64(try XCTUnwrap(imageSize))
        XCTAssertLessThanOrEqual(resultSize, maxBytes)
        XCTAssertLessThanOrEqual(resultSize, expectedBytes)
        print("testCompressLargeWith0_5Compression \(imageName) - maxBytes \(maxBytes)): Original-Size:", originalSize, "Compressed-Size:", resultSize)
    }
    
}
