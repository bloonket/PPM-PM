//
//  BasicTrie.swift
//  PPM data compression
//
//  Created by Pirita Minkkinen on 12/31/24.
//

class BasicTrie<Symbol: Hashable>: Trie {
    class Node {
        var children: [Symbol: Node] = [:]
        var frequencies: [Symbol: Int] = [:]

        func incrementFrequency(for symbol: Symbol) {
            frequencies[symbol, default: 0] += 1
        }
    }

    private let root = Node()

    func insert(symbol: Symbol, context: [Symbol]) {
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

    func getFrequency(symbol: Symbol, context: [Symbol]) -> Int {
        var currentNode = root
        for ctxSymbol in context {
            guard let childNode = currentNode.children[ctxSymbol] else {
                return 0 // Context not found
            }
            currentNode = childNode
        }
        return currentNode.frequencies[symbol, default: 0]
    }

    func getSymbols(context: [Symbol]) -> [Symbol] {
        var currentNode = root
        for ctxSymbol in context {
            guard let childNode = currentNode.children[ctxSymbol] else {
                return [] // Context not found
            }
            currentNode = childNode
        }
        return currentNode.frequencies.keys.sorted { currentNode.frequencies[$0]! > currentNode.frequencies[$1]! }
    }

    func updateFrequency(symbol: Symbol, context: [Symbol]) {
        var currentNode = root
        for ctxSymbol in context {
            guard let childNode = currentNode.children[ctxSymbol] else {
                return // Context not found
            }
            currentNode = childNode
        }
        currentNode.incrementFrequency(for: symbol)
    }

    func reset() {
        root.children.removeAll()
        root.frequencies.removeAll()
    }
}
