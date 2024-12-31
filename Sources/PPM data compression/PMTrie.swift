//
//  PMTrie.swift
//  PPM data compression
//
//  Created by Pirita Minkkinen on 12/31/24.
//

class PMTrie: Trie {
    class Node {
        var children: [Node?]
        var frequencies: [Int]

        init(alphabetSize: Int?) {
            if let alphabetSize = alphabetSize {
                // Pre-allocate arrays for known alphabet size
                self.children = Array<Node?>(repeating: nil, count: alphabetSize)
                self.frequencies = Array<Int>(repeating: 0, count: alphabetSize)
            } else {
                // Use empty arrays for unknown alphabet size
                self.children = []
                self.frequencies = []
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

    func insert(symbol: Character, context: [Character]) {
        guard let symbolScalar = symbol.unicodeScalars.first?.value else { return }
        let symbolIndex = Int(symbolScalar - baseScalarValue)
        let contextIndices = context.compactMap { $0.unicodeScalars.first?.value }.map { Int($0 - baseScalarValue) }

        if let alphabetSize = alphabetSize {
            guard symbolIndex >= 0 && symbolIndex < alphabetSize else { return } // Validate symbol index
        }
        insert(index: symbolIndex, context: contextIndices)
    }

    private func insert(index symbolIndex: Int, context: [Int]) {
        var currentNode = root
        for ctxIndex in context {
            if let alphabetSize = alphabetSize {
                guard ctxIndex >= 0 && ctxIndex < alphabetSize else { return } // Validate context index
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

    func getFrequency(symbol: Character, context: [Character]) -> Int {
        guard let symbolScalar = symbol.unicodeScalars.first?.value else { return 0 }
        let symbolIndex = Int(symbolScalar - baseScalarValue)
        let contextIndices = context.compactMap { $0.unicodeScalars.first?.value }.map { Int($0 - baseScalarValue) }

        if let alphabetSize = alphabetSize {
            guard symbolIndex >= 0 && symbolIndex < alphabetSize else { return 0 } // Validate symbol index
        }
        return getFrequency(index: symbolIndex, context: contextIndices)
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
    func getSymbols(context: [Character]) -> [Character] {
        let contextIndices = context.compactMap { $0.unicodeScalars.first?.value }.map { Int($0 - baseScalarValue) }
        var currentNode = root

        for ctxIndex in contextIndices {
            guard ctxIndex >= 0 else { return [] }
            if alphabetSize == nil {
                currentNode.ensureCapacity(for: ctxIndex)
            }
            guard ctxIndex < currentNode.children.count, let childNode = currentNode.children[ctxIndex] else {
                return []
            }
            currentNode = childNode
        }

        // Retrieve all symbols sorted by their frequencies
        return currentNode.frequencies.enumerated()
            .filter { $0.element > 0 } // Only include symbols with non-zero frequencies
            .sorted { $0.element > $1.element } // Sort by frequency descending
            .map { Character(UnicodeScalar($0.offset + Int(baseScalarValue))!) }
    }

    // Reset the trie
    func reset() {
        root.reset()
    }
}
