//
//  Trie.swift
//  PPM data compression
//
//  Created by Pirita Minkkinen on 12/26/24.
//


protocol Trie {
    // Insert a symbol with context
    func insert(symbol: Character, context: [Character])

    // Get the frequency of a symbol within a context
    func getFrequency(symbol: Character, context: [Character]) -> Int

    // Get symbols in a given context
    func getSymbols(context: [Character]) -> [Character]

    // Reset the trie
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
