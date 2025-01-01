//
//  BasicTrie.swift
//  PPM data compression
//
//  Created by Pirita Minkkinen on 12/31/24.
//

//TODO: fix conformance and finish making this based off of pmtrie :)
class BasicTrie {
    func getSymbolsWithFrequencies(context: [Character]) -> [(Character, Int)] {
        
    }
    
    class Node {
        var children: [Character: Node] = [:]
        var frequencies: [Character: Int] = [:]

        func incrementFrequency(for symbol: Character) {
            frequencies[symbol, default: 0] += 1
        }
    }

    private let root = Node()

    // Insert a symbol into the trie with its context
    func insert(symbol: Character, context: [Character]) {
        var currentNode = root
        for ctxSymbol in context {
            if let childNode = currentNode.children[ctxSymbol] {
                currentNode = childNode
            } else {
                let newNode = Node()
                currentNode.children[ctxSymbol] = newNode
                currentNode = newNode
            }
        }
        currentNode.incrementFrequency(for: symbol)
    }

    // Get the frequency of a symbol in a given context
    func getFrequency(symbol: Character, context: [Character]) -> Int {
        var currentNode = root
        for ctxSymbol in context {
            guard let childNode = currentNode.children[ctxSymbol] else {
                return 0 // Context not found
            }
            currentNode = childNode
        }
        return currentNode.frequencies[symbol, default: 0]
    }

    // Retrieve all symbols in the given context, sorted by frequency
    func getSymbols(context: [Character]) -> [Character] {
        var currentNode = root
        for ctxSymbol in context {
            guard let childNode = currentNode.children[ctxSymbol] else {
                return [] // Context not found
            }
            currentNode = childNode
        }
        return currentNode.frequencies.keys.sorted {
            currentNode.frequencies[$0]! > currentNode.frequencies[$1]!
        }
    }

    // Reset the trie by clearing all nodes
    func reset() {
        root.children.removeAll()
        root.frequencies.removeAll()
    }
}
