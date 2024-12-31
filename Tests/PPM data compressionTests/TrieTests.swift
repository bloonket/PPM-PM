//
//  TrieTests.swift
//  PPM data compression
//
//  Created by Pirita Minkkinen on 12/26/24.
//

import XCTest

@testable import PPM_data_compression

final class TrieTests: XCTestCase {

    func testInsertAndContains() {
        let trie = Trie()
        
        // Insert words
        trie.insert(val: "apple")
        trie.insert(val: "app")
        
        // Check contains
        XCTAssertTrue(trie.contains(val: "apple"))
        XCTAssertTrue(trie.contains(val: "app"))
        XCTAssertFalse(trie.contains(val: "appl"))
        XCTAssertFalse(trie.contains(val: "banana"))
    }

    func testPrefixSearch() {
        let trie = Trie()
        
        // Insert words
        trie.insert(val: "hello")
        trie.insert(val: "help")
        trie.insert(val: "hell")
        
        // Check prefixes
        XCTAssertTrue(trie.contains(prefix: "he"))
        XCTAssertTrue(trie.contains(prefix: "hell"))
        XCTAssertFalse(trie.contains(prefix: "hey"))
    }
    
    func testFindWordsWithPrefix() {
        let trie = Trie()
        
        // Insert words
        trie.insert(val: "cat")
        trie.insert(val: "caterpillar")
        trie.insert(val: "catch")
        
        // Find words with prefix
        let words = trie.find(prefix: "cat")
        XCTAssertTrue(words.contains("cat"))
        XCTAssertTrue(words.contains("caterpillar"))
        XCTAssertTrue(words.contains("catch"))
        XCTAssertFalse(words.contains("dog"))
    }
    
    func testEdgeCases() {
        let trie = Trie()
        
        // Insert empty string
        trie.insert(val: "")
        XCTAssertFalse(trie.contains(val: ""))
        
        // Insert special characters
        trie.insert(val: "123")
        trie.insert(val: "!@#")
        XCTAssertTrue(trie.contains(val: "123"))
        XCTAssertTrue(trie.contains(val: "!@#"))
    }
    
    func testDuplicateInsertions() {
        let trie = Trie()
        
        // Insert duplicates
        trie.insert(val: "test")
        trie.insert(val: "test")
        
        // Check contains
        XCTAssertTrue(trie.contains(val: "test"))
    }
}
