//
//  PPM-PM.swift
//  PPM data compression
//
//  Created by Pirita Minkkinen on 12/31/24.
//

//TODO: reduce sorting
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
                if let currentNode = trie.traverse(context: currentContext) {
                    let symbolScalar = char.unicodeScalars.first?.value ?? 0
                    let symbolIndex = Int(symbolScalar - trie.baseScalarValue)
                    let frequency = currentNode.frequencies[symbolIndex]
                    if frequency > 0 {
                        // Symbol found in current context
                        encoded.append(frequency)
                        found = true
                    } else {
                        // Emit escape symbol for the current context
                        encoded.append(-1) // Example escape symbol
                        if currentContext.isEmpty {
                            // Fallback to flat order -1 model
                            encoded.append(0) // Emit symbol index or other fallback behavior
                            break
                        }
                        currentContext.removeFirst()
                    }
                } else {
                    // Context not found
                    encoded.append(-1)
                    if currentContext.isEmpty {
                        encoded.append(0)
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

            guard let currentNode = trie.traverse(context: context) else {
                decoded.append("?") // Handle anomalies
                continue
            }

            // Retrieve symbols and frequencies from the current node
            let symbolsWithFrequencies: [(Character, Int)] = currentNode.frequencies.enumerated()
                .filter { $0.element > 0 }
                .sorted { $0.element > $1.element }
                .compactMap { (index: Int, frequency: Int) -> (Character, Int)? in
                    guard let unicodeScalar = UnicodeScalar(index + Int(trie.baseScalarValue)) else { return nil }
                    return (Character(unicodeScalar), frequency)
                }


            guard let char = symbolsWithFrequencies.first(where: { $0.1 == freq })?.0 else {
                decoded.append("?") // Handle anomalies
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
