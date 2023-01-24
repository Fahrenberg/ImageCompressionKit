//
//  ------------------------------------------------
//  ----   PerformanceTestsForImageCompressor ------
//  ------------------------------------------------
//

import XCTest
@testable import CompressorKit

final class PerformanceTestsForImageCompressor: XCTestCase {
    
    var measureOnlyOnce: XCTMeasureOptions {
        let option = XCTMeasureOptions()
        option.iterationCount = 1
        return option
    }
    
    private func compress(imageName: String, maxBytes: UInt64) throws {
        let image = try XCTUnwrap(UIImage(named: imageName, in: Bundle.module, with: nil))
        let originalSize = try XCTUnwrap(image.pngData()?.count)
        
        self.measure(options: measureOnlyOnce)  { // 1.89 s , [imagethumbnaik 1.847609]
            let _ =  ImageCompressor.compress(image: image, maxBytes: maxBytes)
        }
        print("testPerformanceCompress\(imageName) - maxBytes \(maxBytes) Original-Size: \(originalSize)")
       
    }
    
    
    func testPerformanceCompressLarge()  throws {
        let maxBytes: UInt64 = 2_000_000
        let imageName = "large"
        try compress(imageName: imageName, maxBytes: maxBytes)
       
    }
    
    func testPerformanceCompressMedium()  throws {
        let maxBytes: UInt64 = 1_000_000
        let imageName = "medium"
        try compress(imageName: imageName, maxBytes: maxBytes)
    }
    
    
    func testPerformanceCompressFourImages() throws {
        let imageName = "large"
        let maxBytes: UInt64 = 2_000_000
        let image = try XCTUnwrap(UIImage(named: imageName, in: Bundle.module, with: nil))
        let images = Array(repeating: image, count: 4)
        
        
        self.measure { // 8.18
             _ =  images.compactMap { image in
                return ImageCompressor.compress(image: image, maxBytes: maxBytes)
            }
        }
        
    }
    
    
    
  
}
