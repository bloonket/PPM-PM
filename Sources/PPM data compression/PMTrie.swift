//
//  PMTrie.swift
//  PPM data compression
//
//  Created by Pirita Minkkinen on 12/31/24.
//

class PMTrie<Symbol: Hashable>: Trie {
    class Node {
        var children: [Symbol: Node] = [:]
        var frequencies: [Symbol: Int] = [:]
        var weights: [Symbol: Double] = [:] // Additional feature for PPM-PM

        func incrementFrequency(for symbol: Symbol) {
            frequencies[symbol, default: 0] += 1
        }

        func updateWeight(for symbol: Symbol, multiplier: Double) {
            weights[symbol, default: 1.0] *= multiplier
        }
    }

    private let root = Node()
    private let dropOffThreshold: Double
    private let maxSymbolsToTest: Int

    init(dropOffThreshold: Double = 0.5, maxSymbolsToTest: Int = 10) {
        self.dropOffThreshold = dropOffThreshold
        self.maxSymbolsToTest = maxSymbolsToTest
    }

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

        // Apply drop-off mechanism
        let sortedSymbols = currentNode.frequencies.keys.sorted { currentNode.frequencies[$0]! > currentNode.frequencies[$1]! }
        var relevantSymbols: [Symbol] = []
        var previousFrequency: Int? = nil

        for symbol in sortedSymbols {
            guard let currentFrequency = currentNode.frequencies[symbol] else { continue }
            if let prev = previousFrequency {
                let dropOff = Double(prev - currentFrequency) / Double(prev)
                if dropOff > dropOffThreshold {
                    break
                }
            }
            relevantSymbols.append(symbol)
            previousFrequency = currentFrequency
        }

        return Array(relevantSymbols.prefix(maxSymbolsToTest))
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
        root.weights.removeAll()
    }
}
