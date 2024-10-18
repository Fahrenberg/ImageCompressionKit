//
//  ------------------------------------------------
//  -----------   PerformanceTestHEICCompressor -----------------
//  ------------------------------------------------
//
    
import XCTest
@testable import ImageCompressionKit
import OSLog
import CollectionConcurrencyKit

final class ImageCompressionPerformanceTests: XCTestCase {
   
    var measureOnlyOnce: XCTMeasureOptions {
        let option = XCTMeasureOptions()
        option.iterationCount = 1
        return option
    }
    
    var largeImage: PlatformImage? {
        let bundle = Bundle.module
        let largeImageURL  = bundle.url(forResource: "large", withExtension: "png")!
        #if canImport(UIKit)
        return UIImage(contentsOfFile: largeImageURL.path)
        #elseif canImport(AppKit)
        return NSImage(contentsOf: largeImageURL)
        #endif
    }
   
    
    
    func testPerformanceJPGCompressorLargeData() throws {
        let jpgQuality: CGFloat = 0.1
        let image = try XCTUnwrap(largeImage)
        
        self.measure(options: measureOnlyOnce) { // 0.026,
            _ = image.jpgDataCompression(compressionQuality: jpgQuality)
        }
    }
    
    
    func testPerformanceHEICCompressorLargeData() throws {
        let heicQuality: CGFloat = 0.1
        let image = try XCTUnwrap(largeImage)
        
        self.measure(options: measureOnlyOnce) { // 0.267
            _ = image.heicDataCompression(compressionQuality: heicQuality)
        }
    }
    
    func testPerformance4HEICCompressionsConcurrent() async throws {
        let heicQuality: CGFloat = 0.5
        let image = try XCTUnwrap(largeImage)
        
        let images = Array(repeating: image, count: 4)
        
        self.measure(options: measureOnlyOnce) {
            let expectation = XCTestExpectation(description: "Concurrent HEIC compression completed")

            Task {
                await images.concurrentForEach { image in
                    _ =  image.heicDataCompression(compressionQuality: heicQuality)
                }
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 10.0)  // Adjust the timeout as necessary
        }
    }

    func testPerformance4HEICCompressionsSync() async throws {
        let heicQuality: CGFloat = 0.5
        let image = try XCTUnwrap(largeImage)
        
        let images = Array(repeating: image, count: 4)
        
        self.measure(options: measureOnlyOnce){
            images.forEach { image in
                    _ =  image.heicDataCompression(compressionQuality: heicQuality)
            }
        }
    }

    func testPerformance4JPGCompressionsConcurrent() async throws {
        let heicQuality: CGFloat = 0.5
        let image = try XCTUnwrap(largeImage)
        
        let images = Array(repeating: image, count: 4)
        
        self.measure(options: measureOnlyOnce) {
            let expectation = XCTestExpectation(description: "Concurrent HEIC compression completed")

            Task {
                await images.concurrentForEach { image in
                    _ = image.jpgDataCompression(compressionQuality: heicQuality)
                }
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 10.0)  // Adjust the timeout as necessary
        }
    }
    
    func testPerformance4JPGCompressionsSync() async throws {
        let heicQuality: CGFloat = 0.5
        let image = try XCTUnwrap(largeImage)
        
        let images = Array(repeating: image, count: 4)
        
        self.measure {
             images.forEach { image in
                    _ = image.jpgDataCompression(compressionQuality: heicQuality)
            }
        }
    }
    
    
     
}
