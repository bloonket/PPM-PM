//
//  BasicPPM.swift
//  PPM data compression
//
//  Created by Pirita Minkkinen on 12/31/24.
//

class BasicPPM {
    private let trie: BasicTrie
    private let order: Int // Context size

    init(order: Int) {
        self.trie = BasicTrie()
        self.order = order
    }

    func compress(input: String) -> [Int] {
        var context: [Character] = []
        var encoded: [Int] = []

        for char in input {
            let frequency = trie.getFrequency(symbol: char, context: context)
            encoded.append(frequency) // Store frequency or use an encoder
            trie.insert(symbol: char, context: context)
            if context.count == order {
                context.removeFirst()
            }
            context.append(char)
        }
        return encoded
    }

    func decompress(encoded: [Int]) -> String {
        var context: [Character] = []
        var decoded: String = ""

        for freq in encoded {
            let symbols = trie.getSymbols(context: context)
            guard let char = symbols.first(where: { trie.getFrequency(symbol: $0, context: context) == freq }) else {
                continue
            }
            decoded.append(char)
            trie.insert(symbol: char, context: context)
            if context.count == order {
                context.removeFirst()
            }
            context.append(char)
        }
        return decoded
    }

    func reset() {
        trie.reset()
    }
}
