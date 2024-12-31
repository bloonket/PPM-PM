import Testing
@testable import PPM_data_compression

@Test func example() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
}

/*
 import Foundation

 func generateRepetitiveData(targetRepetitiveness: Double, length: Int, alphabet: [Character]) -> String {
     let bufferSize = 100
     var recencyBuffer: [Character] = []
     var output: [Character] = []
     
     for _ in 0..<length {
         let isFromBuffer = Double.random(in: 0...1) < targetRepetitiveness
         var nextChar: Character
         
         if isFromBuffer && !recencyBuffer.isEmpty {
             // Weighted random selection from recency buffer
             nextChar = weightedRandomFromBuffer(buffer: recencyBuffer)
         } else {
             // Random character from the full alphabet
             nextChar = alphabet.randomElement()!
         }
         
         // Append to output and update recency buffer
         output.append(nextChar)
         recencyBuffer.append(nextChar)
         if recencyBuffer.count > bufferSize {
             recencyBuffer.removeFirst()
         }
     }
     
     return String(output)
 }

 func weightedRandomFromBuffer(buffer: [Character]) -> Character {
     // Define weights (e.g., exponential decay)
     let totalWeight = buffer.indices.reduce(0.0) { sum, index in
         sum + pow(0.9, Double(index))
     }
     
     let randomValue = Double.random(in: 0...totalWeight)
     var cumulativeWeight = 0.0
     
     for (index, char) in buffer.enumerated() {
         cumulativeWeight += pow(0.9, Double(index))
         if randomValue < cumulativeWeight {
             return char
         }
     }
     
     return buffer.last! // Fallback to the last character in the buffer
 }

 */
