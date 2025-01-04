//
//  PMTrie.swift
//  PPM data compression
//
//  Created by Pirita Minkkinen on 12/31/24.
//

//TODO: check the approach for any lenght operations
//TODO: check naming, possibly specify some names like currentNode :)
class PMTrie: Trie {

    private let root: PMNode
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
        self.root = PMNode(alphabetSize: alphabetSize)
    }

    func traverse(context: [Character], modificationEnabled: Bool = false) -> PMNode? {
        let contextIndices = context.compactMap { $0.unicodeScalars.first?.value }.map { Int($0 - baseScalarValue) }
        var currentNode = root

        for ctxIndex in contextIndices {
            if ctxIndex < 0 || (alphabetSize != nil && ctxIndex >= alphabetSize!) {
                return nil // Invalid context index
            }

            if currentNode.children[ctxIndex] == nil {
                //create new node if missing
               currentNode.children[ctxIndex] = PMNode(alphabetSize: alphabetSize)
            }

            if modificationEnabled {
                // Trigger frequency update for the current child
                currentNode.updateFrequency(index: ctxIndex)
            }

            currentNode = currentNode.children[ctxIndex]!
        }

        return currentNode
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
        
        //Traverse the context
        guard let currentNode = traverse(context: context) else {
                throw PMTrieError.invalidContext(context)
        }
        
        if alphabetSize == nil {
            currentNode.ensureCapacity(for: symbolIndex)
        }
        currentNode.promoteSymbol(at: symbolIndex)
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
        
        //Traverse the tree
        guard let currentNode = traverse(context: context) else {
                return 0 // Context not found
        }
        
        // Return the frequency of the symbol in the final node
        if alphabetSize == nil && symbolIndex >= currentNode.frequencies.count {
            return 0 // Handle dynamic alphabet case
        }
        return currentNode.frequencies[symbolIndex]
    }
    
    

    private func getFrequency(index symbolIndex: Int, context: [Int]) -> Int {
        guard let currentNode = traverse(context: context.map { Character(UnicodeScalar($0 + Int(baseScalarValue))!) }) else {
                return 0
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

//TODO: Consider location of this class
//MARK: - Node of the PMTrie

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
