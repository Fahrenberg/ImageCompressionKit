//
//  ------------------------------------------------
//  -----------   PerformanceTestHEICCompressor -----------------
//  ------------------------------------------------
//
    
import XCTest
@testable import ImageCompressionKit
import OSLog

final class PerformanceTestHEICCompressor: XCTestCase {
   
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
            _ = try? image.jpgCompressorData(
                compressionQuality: jpgQuality)
        }
    }
    
    
    func testPerformanceHEICCompressorLargeData() throws {
        let heicQuality: CGFloat = 0.1
        let image = try XCTUnwrap(largeImage)
        
        self.measure(options: measureOnlyOnce) { // 0.267
            _ = try? image.heicData(
                compressionQuality: heicQuality)
        }
    }
    
     
}
