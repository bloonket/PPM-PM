//
//  Trie.swift
//  PPM data compression
//
//  Created by Pirita Minkkinen on 12/26/24.
//


protocol Trie {
    associatedtype Symbol: Hashable // Support any type of symbol (e.g., Character, String)

    // Insert a symbol into the trie, given its context
    func insert(symbol: Symbol, context: [Symbol])

    // Get the frequency of a symbol in a given context
    func getFrequency(symbol: Symbol, context: [Symbol]) -> Int

    // Get all symbols in the given context, sorted by relevance (if applicable)
    func getSymbols(context: [Symbol]) -> [Symbol]

    // Update the frequency of a symbol in a context
    func updateFrequency(symbol: Symbol, context: [Symbol])

    // Reset the trie (optional, useful for testing or reinitialization)
    func reset()
}


/*
class TrieNode {
    var children: [Character: TrieNode] = [:]
    var frequencies: [Character: Int] = [:]
    var distinctCount: Int {
        return frequencies.count
    }
    var totalCount: Int {
        return frequencies.values.reduce(0, +)
    }
    var escapeProbability: Double {
        return Double(distinctCount) / Double(distinctCount + totalCount)
    }
}

func insert(context: [Character], symbol: Character) {
    var node = root
    for char in context {
        if let child = node.children[char] {
            node = child
        } else {
            let newNode = TrieNode()
            node.children[char] = newNode
            node = newNode
        }
    }
    node.frequencies[symbol, default: 0] += 1
}

func predict(context: [Character], symbol: Character) -> Double {
    var node = root
    for char in context.reversed() {
        if let child = node.children[char] {
            node = child
            if let frequency = node.frequencies[symbol] {
                return Double(frequency) / Double(node.totalCount + node.distinctCount)
            }
        }
    }
    return 1.0 / Double(alphabetSize) // Fallback probability
}

func escape(context: [Character]) -> Double {
    var node = root
    for char in context.reversed() {
        if let child = node.children[char] {
            node = child
            return node.escapeProbability
        }
    }
    return 1.0 // Always escape in the shortest context
}


*/
