//
//  PMTrie.swift
//  PPM data compression
//
//  Created by Pirita Minkkinen on 12/31/24.
//

//TODO: check the approach for any lenght operations
class PMTrie: Trie {
    class Node {
        var topFrequency: Int = 0
        var bottomFrequency: Int = 0
        var consideredCount: Int = 0
        var dropOffThreshold: Int = 5 // Start with a reasonable value
        //TODO: review if this is
        var initialPhase: Bool = true // Indicates if we're in the initial reduction phase

        var children: [Node?]
        var frequencies: [Int]
        var modifiers: [Int]
        var isConsidered: [Bool] // Tracks if a symbol is "likely"

        init(alphabetSize: Int?) {
            if let alphabetSize = alphabetSize {
                // Pre-allocate arrays for known alphabet size
                self.children = Array<Node?>(repeating: nil, count: alphabetSize)
                self.frequencies = Array<Int>(repeating: 0, count: alphabetSize)
                self.modifiers = Array<Int>(repeating: 0, count: alphabetSize)
                self.isConsidered = Array<Bool>(repeating: true, count: alphabetSize)
            } else {
                // Use empty arrays for unknown alphabet size
                self.children = []
                self.frequencies = []
                self.modifiers = []
                self.isConsidered = []

            }
        }

        func ensureCapacity(for index: Int) {
            // Dynamically resize children and frequencies if needed
            if index >= children.count {
                let newSize = max(index + 1, children.count * 2) // Double size for efficiency
                children.append(contentsOf: Array<Node?>(repeating: nil, count: newSize - children.count))
                frequencies.append(contentsOf: Array<Int>(repeating: 0, count: newSize - frequencies.count))
            }
        }
        
        func updateFrequency(index: Int, increment: Int) {
            // Update frequency
            frequencies[index] += increment
            
            // Update topFrequency and bottomFrequency
            if frequencies[index] > topFrequency {
                topFrequency = frequencies[index]
            }
            if isConsidered[index], frequencies[index] < bottomFrequency {
                bottomFrequency = frequencies[index]
            }
            
            // Update isConsidered for this index
            isConsidered[index] = frequencies[index] >= topFrequency - dropOffThreshold
            
            if initialPhase {
                handleInitialPhase()
            } else {
                // Adjust dropOffThreshold dynamically (standard logic)
                adjustThreshold()
            }
        }
        
        func handleInitialPhase() {
            // Set consideredCount to half the total symbols after the first addition
            if consideredCount == 0 {
                consideredCount = frequencies.count / 2
            } else {
                // Gradually reduce consideredCount by halving
                consideredCount = max(1, consideredCount / 2)
            }
            
            // Update isConsidered flags
            for (index, frequency) in frequencies.enumerated() {
                isConsidered[index] = frequency >= topFrequency - dropOffThreshold && consideredCount > 0
                if isConsidered[index] { consideredCount -= 1 }
            }

            // Exit the initial phase once consideredCount stabilizes or grows
            if consideredCount > frequencies.filter({ $0 > 0 }).count {
                initialPhase = false
            }
        }
        
        func adjustThreshold() {
            let currentlyConsidered = isConsidered.filter { $0 }.count

            // Too many symbols considered -> tighten threshold
            if currentlyConsidered > consideredCount {
                dropOffThreshold += 1
            }
            
            // Too few symbols considered -> loosen threshold
            else if currentlyConsidered < consideredCount && dropOffThreshold > 1 {
                dropOffThreshold -= 1
            }
            
            // Update consideredCount to reflect current state
            consideredCount = currentlyConsidered
        }


        
        func reset() {
            children.removeAll()
            frequencies.removeAll()
        }
    }

    private let root: Node
    private let alphabetSize: Int?
    private let baseScalarValue: UInt32

    init(scalarRange: ClosedRange<UnicodeScalar>? = nil) {
        if let scalarRange = scalarRange {
            self.alphabetSize = Int(scalarRange.upperBound.value - scalarRange.lowerBound.value + 1)
            self.baseScalarValue = scalarRange.lowerBound.value
        } else {
            self.alphabetSize = nil
            self.baseScalarValue = 0 // Default or handle dynamically later
        }
        self.root = Node(alphabetSize: alphabetSize)
    }

    func insert(symbol: Character, context: [Character]) throws {
        // Convert the symbol to its index
        guard let symbolScalar = symbol.unicodeScalars.first?.value else {
            throw PMTrieError.invalidSymbol(symbol) // Throw error for invalid symbol
        }
        let symbolIndex = Int(symbolScalar - baseScalarValue)
        
        // Convert the context characters to indices
        let contextIndices = context.compactMap { $0.unicodeScalars.first?.value }.map { Int($0 - baseScalarValue) }
        
        // Validate symbol index
        if let alphabetSize = alphabetSize {
            guard symbolIndex >= 0 && symbolIndex < alphabetSize else {
                throw PMTrieError.invalidSymbol(symbol) // Throw error for out-of-bounds symbol
            }
        }
        
        // Iterative insertion logic (as per earlier implementation)
        var currentNode = root
        for ctxIndex in contextIndices {
            if let alphabetSize = alphabetSize {
                guard ctxIndex >= 0 && ctxIndex < alphabetSize else {
                    throw PMTrieError.invalidContext(context) // Throw error for invalid context index
                }
            } else {
                currentNode.ensureCapacity(for: ctxIndex)
            }

            if currentNode.children[ctxIndex] == nil {
                currentNode.children[ctxIndex] = Node(alphabetSize: alphabetSize)
            }
            currentNode = currentNode.children[ctxIndex]!
        }

        if alphabetSize == nil {
            currentNode.ensureCapacity(for: symbolIndex)
        }
        currentNode.frequencies[symbolIndex] += 1 //TODO: add modifier to the increase
    }



    func getFrequency(symbol: Character, context: [Character]) -> Int {
        // Convert symbol to its index
        guard let symbolScalar = symbol.unicodeScalars.first?.value else { return 0 }
        let symbolIndex = Int(symbolScalar - baseScalarValue)
        
        // Convert context characters to their indices
        let contextIndices = context.compactMap { $0.unicodeScalars.first?.value }.map { Int($0 - baseScalarValue) }
        
        // Validate symbol index
        if let alphabetSize = alphabetSize {
            guard symbolIndex >= 0 && symbolIndex < alphabetSize else { return 0 }
        }
        
        // Use an iterative approach to traverse the trie
        var currentNode = root
        for ctxIndex in contextIndices {
            // Ensure context index is valid and node exists
            if let alphabetSize = alphabetSize, ctxIndex < 0 || ctxIndex >= alphabetSize {
                return 0 // Invalid index
            }
            if ctxIndex >= currentNode.children.count || currentNode.children[ctxIndex] == nil {
                return 0 // Context not found
            }
            currentNode = currentNode.children[ctxIndex]!
        }
        
        // Return the frequency of the symbol in the final node
        if alphabetSize == nil && symbolIndex >= currentNode.frequencies.count {
            return 0 // Handle dynamic alphabet case
        }
        return currentNode.frequencies[symbolIndex]
    }
    
    

    private func getFrequency(index symbolIndex: Int, context: [Int]) -> Int {
        var currentNode = root
        for ctxIndex in context {
            guard ctxIndex >= 0 else { return 0 }
            if alphabetSize == nil {
                currentNode.ensureCapacity(for: ctxIndex)
            }
            guard ctxIndex < currentNode.children.count, let childNode = currentNode.children[ctxIndex] else {
                return 0
            }
            currentNode = childNode
        }

        if alphabetSize == nil {
            currentNode.ensureCapacity(for: symbolIndex)
        }
        return currentNode.frequencies[symbolIndex]
    }

    // Get symbols in a given context
    func getSymbolsWithFrequencies(context: [Character]) -> [(Character, Int)] {
        // Convert the context characters to their indices
        let contextIndices = context.compactMap { $0.unicodeScalars.first?.value }.map { Int($0 - baseScalarValue) }
        var currentNode = root

        // Traverse the trie iteratively
        for ctxIndex in contextIndices {
            guard ctxIndex >= 0 else { return [] }
            if alphabetSize == nil {
                currentNode.ensureCapacity(for: ctxIndex)
            }
            guard ctxIndex < currentNode.children.count, let childNode = currentNode.children[ctxIndex] else {
                return [] // Context not found
            }
            currentNode = childNode
        }

        // Collect symbols and their frequencies
        var symbolsWithFrequencies: [(Character, Int)] = []
        for (index, frequency) in currentNode.frequencies.enumerated() {
            if frequency > 0 { // Include only symbols with non-zero frequency
                if let unicodeScalar = UnicodeScalar(index + Int(baseScalarValue)) {
                    symbolsWithFrequencies.append((Character(unicodeScalar), frequency))
                }
            }
        }

        // Sort by frequency descending
        symbolsWithFrequencies.sort { $0.1 > $1.1 }
        return symbolsWithFrequencies
    }


    // Reset the trie
    func reset() {
        root.reset()
    }
}

enum PMTrieError: Error {
    case invalidSymbol(Character)
    case invalidContext([Character])
}

//MARK: - Code for asserting in insert instead , for later to decide how the errors are best handled
/*
 func insert(symbol: Character, context: [Character]) {
     // Convert the symbol to its index
     guard let symbolScalar = symbol.unicodeScalars.first?.value else {
         assertionFailure("Invalid symbol: \(symbol)")
         return
     }
     let symbolIndex = Int(symbolScalar - baseScalarValue)
     
     // Convert the context characters to indices
     let contextIndices = context.compactMap { $0.unicodeScalars.first?.value }.map { Int($0 - baseScalarValue) }
     
     // Validate symbol index
     if let alphabetSize = alphabetSize {
         assert(symbolIndex >= 0 && symbolIndex < alphabetSize, "Invalid symbol: \(symbol)")
     }
     
     // Iterative insertion logic (as per earlier implementation)
     var currentNode = root
     for ctxIndex in contextIndices {
         if let alphabetSize = alphabetSize {
             assert(ctxIndex >= 0 && ctxIndex < alphabetSize, "Invalid context index: \(ctxIndex) in context \(context)")
         } else {
             currentNode.ensureCapacity(for: ctxIndex)
         }

         if currentNode.children[ctxIndex] == nil {
             currentNode.children[ctxIndex] = Node(alphabetSize: alphabetSize)
         }
         currentNode = currentNode.children[ctxIndex]!
     }

     if alphabetSize == nil {
         currentNode.ensureCapacity(for: symbolIndex)
     }
     currentNode.frequencies[symbolIndex] += 1
 }

 */
