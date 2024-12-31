//
//  TrieTests.swift
//  PPM data compression
//
//  Created by Pirita Minkkinen on 12/26/24.
//

import XCTest

@testable import PPM_data_compression

import XCTest

final class TrieTests: XCTestCase {

    func testTrieProtocolImplementation<T: Trie>(trie: T) where T: AnyObject {
        trie.insert(symbol: "a", context: ["b", "c"])
        trie.insert(symbol: "b", context: ["b", "c"])
        trie.insert(symbol: "a", context: ["b", "c"])
        
        XCTAssertEqual(trie.getFrequency(symbol: "a", context: ["b", "c"]), 2)
        XCTAssertEqual(trie.getFrequency(symbol: "b", context: ["b", "c"]), 1)
        XCTAssertEqual(trie.getFrequency(symbol: "c", context: ["b", "c"]), 0)
        
        let symbols = trie.getSymbols(context: ["b", "c"])
        XCTAssertEqual(symbols, ["a", "b"]) // Sorted by frequency
        
        trie.reset()
        XCTAssertEqual(trie.getFrequency(symbol: "a", context: ["b", "c"]), 0)
    }

    func testBasicTrieConformsToProtocol() {
        let trie = BasicTrie()
        testTrieProtocolImplementation(trie: trie)
    }
    
    func testPMTrieConformsToProtocol() {
        let trie = PMTrie()
        testTrieProtocolImplementation(trie: trie)
    }
}
