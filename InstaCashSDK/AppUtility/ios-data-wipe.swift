import Foundation

class SecureDataWipe {
    /// Performs a three-pass secure data wipe on a file or directory
    /// - Parameters:
    ///   - path: The file path or directory to be securely wiped
    ///   - completion: A closure called when the wipe process is complete, with a boolean indicating success
    static func threePassWipe(at path: String, completion: @escaping (Bool) -> Void) {
        // Ensure the path exists
        guard FileManager.default.fileExists(atPath: path) else {
            completion(false)
            return
        }
        
        // Queue the wipe operation on a background thread
        DispatchQueue.global(qos: .background).async {
            do {
                // Get file/directory attributes
                let attributes = try FileManager.default.attributesOfItem(atPath: path)
                let fileSize = (attributes[.size] as? Int64) ?? 0
                
                // Perform three passes of overwriting
                for pass in 1...3 {
                    try self.overwriteData(at: path, withPattern: self.getOverwritePattern(for: pass))
                }
                
                // Optional: Remove the file after secure wipe
                try FileManager.default.removeItem(atPath: path)
                
                // Call completion on main queue
                DispatchQueue.main.async {
                    completion(true)
                }
            } catch {
                print("Secure wipe error: \(error.localizedDescription)")
                
                // Call completion on main queue
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    /// Generate an overwrite pattern based on the pass number
    /// - Parameter pass: The current pass number (1-3)
    /// - Returns: Data to use for overwriting
    private static func getOverwritePattern(for pass: Int) -> Data {
        switch pass {
        case 1:
            // First pass: Overwrite with zeros
            return Data(repeating: 0x00, count: 1024)
        case 2:
            // Second pass: Overwrite with ones
            return Data(repeating: 0xFF, count: 1024)
        case 3:
            // Third pass: Overwrite with random data
            var randomData = Data(count: 1024)
            randomData.withUnsafeMutableBytes { rawBufferPointer in
                let unsafeRawBufferPointer = rawBufferPointer.baseAddress!
                _ = SecRandomCopyBytes(kSecRandomDefault, 1024, unsafeRawBufferPointer)
            }
            return randomData
        default:
            // Fallback to zeros if pass is out of range
            return Data(repeating: 0x00, count: 1024)
        }
    }
    
    /// Overwrite file or directory contents with a specific pattern
    /// - Parameters:
    ///   - path: The file path or directory to overwrite
    ///   - pattern: The data pattern to use for overwriting
    private static func overwriteData(at path: String, withPattern pattern: Data) throws {
        // Check if it's a directory
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) else {
            throw NSError(domain: "SecureWipeError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Path does not exist"])
        }
        
        if isDirectory.boolValue {
            // If it's a directory, recursively wipe all contents
            let enumerator = FileManager.default.enumerator(atPath: path)
            while let filePath = enumerator?.nextObject() as? String {
                let fullPath = (path as NSString).appendingPathComponent(filePath)
                try overwriteData(at: fullPath, withPattern: pattern)
            }
        } else {
            // Open file for writing
            guard let fileHandle = FileHandle(forWritingAtPath: path) else {
                throw NSError(domain: "SecureWipeError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Cannot open file for writing"])
            }
            
            defer {
                fileHandle.closeFile()
            }
            
            // Get file size
            let fileSize = fileHandle.seekToEndOfFile()
            fileHandle.seek(toFileOffset: 0)
            
            // Write pattern repeatedly to cover entire file
            for _ in 0..<(fileSize / UInt64(pattern.count) + 1) {
                fileHandle.write(pattern)
            }
            
            // Ensure all data is written to disk
            fileHandle.synchronizeFile()
        }
    }
    
    // Example usage
    static func exampleUsage() {
        let filePath = "/path/to/sensitive/file"
        threePassWipe(at: filePath) { success in
            if success {
                print("Secure wipe completed successfully")
            } else {
                print("Secure wipe failed")
            }
        }
    }
}
