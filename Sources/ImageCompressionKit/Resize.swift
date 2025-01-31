//
//  Resize.swift
//  PDF-Reporting
//
//  Created by Jean-Nicolas on 30.01.2025.
//
// PlatformImage for macOS and iOS
#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
 #endif

extension PlatformImage {
    public func resized(to targetSize: CGSize, dpi: CGFloat = 72.0) -> PlatformImage? {
        let scaleFactor = dpi / 72.0
        let scaledSize = CGSize(width: targetSize.width * scaleFactor, height: targetSize.height * scaleFactor)
        
        #if canImport(UIKit)
        let renderer = UIGraphicsImageRenderer(size: scaledSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: scaledSize))
        }
        #elseif canImport(AppKit)
        let newImage = NSImage(size: scaledSize)
        newImage.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .high
        self.draw(in: NSRect(origin: .zero, size: scaledSize),
                  from: NSRect(origin: .zero, size: self.size),
                  operation: .copy,
                  fraction: 1.0)
        newImage.unlockFocus()
        return newImage
        #endif
    }
}
