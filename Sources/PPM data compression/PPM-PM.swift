//
//  PPM-PM.swift
//  PPM data compression
//
//  Created by Pirita Minkkinen on 12/31/24.
//

class PPM_PM {
    private let trie: PMTrie
    private let order: Int

    init(order: Int, alphabetSize: Int) {
        self.trie = PMTrie()
        self.order = order
    }

    func compress(input: String) -> [Int] {
        var context: [Character] = []
        var encoded: [Int] = []

        for char in input {
            var currentContext = context
            var found = false

            // Backoff loop: try shorter contexts if symbol not found
            while !found {
                let frequency = trie.getFrequency(symbol: char, context: currentContext)
                if frequency > 0 {
                    // Symbol found in current context
                    encoded.append(frequency)
                    found = true
                } else {
                    // Emit escape symbol for the current context
                    encoded.append(-1) // Example escape symbol, could be any reserved value
                    if currentContext.isEmpty {
                        // Fallback to flat order -1 model
                        encoded.append(0) // Emit symbol index or other fallback behavior
                        break
                    }
                    currentContext.removeFirst()
                }
            }

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
            if freq == -1 { // Escape symbol
                // Remove the oldest symbol to back off
                if !context.isEmpty {
                    context.removeFirst()
                }
                continue
            }

            let symbols = trie.getSymbols(context: context)
            guard let char = symbols.first(where: { trie.getFrequency(symbol: $0, context: context) == freq }) else {
                // Handle order -1 fallback (e.g., decode as-is or handle anomalies)
                decoded.append("?") // Example fallback character
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
