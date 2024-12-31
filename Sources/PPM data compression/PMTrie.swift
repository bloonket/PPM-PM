//
//  PMTrie.swift
//  PPM data compression
//
//  Created by Pirita Minkkinen on 12/31/24.
//

class PMTrie {
    class Node {
        var children: [Node?]
        var frequencies: [Int]

        init(alphabetSize: Int?) {
            self.children = Array<Node?>(repeating: nil, count: alphabetSize ?? 0)
            self.frequencies = Array<Int>(repeating: 0, count: alphabetSize ?? 0)
        }
    }

    private let root: Node
    private let alphabetSize: Int?
    private let baseScalarValue: UInt32

    init(scalarRange: ClosedRange<UnicodeScalar>? = nil) {
        if let scalarRange = scalarRange{
            self.alphabetSize = Int(scalarRange.upperBound.value - scalarRange.lowerBound.value + 1)
            self.baseScalarValue = scalarRange.lowerBound.value
        }
        else{
            alphabetSize = nil
            baseScalarValue = ?
        }
        self.root = Node(alphabetSize: alphabetSize)
    }

    func insert(symbol: Character, context: [Character]) {
        guard let symbolScalar = symbol.unicodeScalars.first?.value else { return }
        let symbolIndex = Int(symbolScalar - baseScalarValue)
        let contextIndices = context.compactMap { $0.unicodeScalars.first?.value }.map { Int($0 - baseScalarValue) }

        guard symbolIndex >= 0 && symbolIndex < alphabetSize else { return } // Validate symbol index
        insert(index: symbolIndex, context: contextIndices)
    }

    private func insert(index symbolIndex: Int, context: [Int]) {
        var currentNode = root
        for ctxIndex in context {
            guard ctxIndex >= 0 && ctxIndex < alphabetSize else { return } // Validate context index
            if currentNode.children[ctxIndex] == nil {
                currentNode.children[ctxIndex] = Node(alphabetSize: alphabetSize)
            }
            currentNode = currentNode.children[ctxIndex]!
        }
        currentNode.frequencies[symbolIndex] += 1
    }

    func getFrequency(symbol: Character, context: [Character]) -> Int {
        guard let symbolScalar = symbol.unicodeScalars.first?.value else { return 0 }
        let symbolIndex = Int(symbolScalar - baseScalarValue)
        let contextIndices = context.compactMap { $0.unicodeScalars.first?.value }.map { Int($0 - baseScalarValue) }

        guard symbolIndex >= 0 && symbolIndex < alphabetSize else { return 0 } // Validate symbol index
        return getFrequency(index: symbolIndex, context: contextIndices)
    }

    private func getFrequency(index symbolIndex: Int, context: [Int]) -> Int {
        var currentNode = root
        for ctxIndex in context {
            guard ctxIndex >= 0 && ctxIndex < alphabetSize, let childNode = currentNode.children[ctxIndex] else {
                return 0
            }
            currentNode = childNode
        }
        return currentNode.frequencies[symbolIndex]
    }
}
