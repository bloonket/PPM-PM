//
//  PMNode.swift
//  PPM data compression
//
//  Created by Pirita Minkkinen on 1/4/25.
//


//TODO: add function for finding the Node and its value we looking for based on how likely
//TODO: consider running to max integer limit lmao
class PMNode {
    var topFrequency: Int = 0
    var bottomFrequency: Int = 0
    var consideredCount: Int = 0
    var dropOffThreshold: Int = 5 // Start with a reasonable value
    //TODO: review if this is needed/good
    var starterPhase: Bool = true // Indicates if we're in the initial reduction phase

    var children: [PMNode?]
    var frequencies: [Int]
    var modifiers: [Int] //TODO: consider different float values
    var isConsidered: [Bool] //TODO: add more use for this even outside the class if needed

    init(alphabetSize: Int?) {
        if let alphabetSize = alphabetSize {
            // Pre-allocate arrays for known alphabet size
            self.children = Array<PMNode?>(repeating: nil, count: alphabetSize)
            self.frequencies = Array<Int>(repeating: 0, count: alphabetSize)
            self.modifiers = Array<Int>(repeating: 1, count: alphabetSize)
            self.isConsidered = Array<Bool>(repeating: true, count: alphabetSize)
        } else {
            // Use empty arrays for unknown alphabet size
            self.children = []
            self.frequencies = []
            self.modifiers = []
            self.isConsidered = []
        }
    }

    func ensureCapacity(for index: Int) {
        // Dynamically resize arrays if needed
        if index >= children.count {
            let newSize = max(index + 1, children.count * 2) // Double size for efficiency
            
            // Resize children
            children.append(contentsOf: Array<PMNode?>(repeating: nil, count: newSize - children.count))
            
            // Resize frequencies
            frequencies.append(contentsOf: Array<Int>(repeating: 0, count: newSize - frequencies.count))
            
            // Resize modifiers
            modifiers.append(contentsOf: Array<Int>(repeating: 1, count: newSize - modifiers.count)) // Default modifier to 1
            
            // Resize isConsidered
            isConsidered.append(contentsOf: Array<Bool>(repeating: true, count: newSize - isConsidered.count)) // Default isConsidered to true
        }
    }

    
    
    
    func updateFrequency(index: Int) {
        let increase = 1 * modifiers[index]  //TODO: change the default value to more calculated one
        if increase + frequencies[index] > topFrequency {
            frequencies[index] = topFrequency + 1
            topFrequency = frequencies[index]
        }
        else {
            frequencies[index] += increase
        }
        
        if !isConsidered[index] {
            if frequencies[index] > bottomFrequency{
                //after being promoted to one of the considered ones, remove modifier
                isConsidered[index] = true
                modifiers[index] = 1
                adjustThreshold()
            }
            else{
                modifiers[index] *= 2 //TODO: test if its not too agressive or not agressive enough
            }
        }
        
        //TODO: check if this is needed
        if isConsidered[index], frequencies[index] < bottomFrequency {
            bottomFrequency = frequencies[index]
        }
        
        // Update isConsidered for this index
        isConsidered[index] = frequencies[index] >= topFrequency - dropOffThreshold
        
        if starterPhase {
            handleStarterPhase()
        } else {
            // Adjust dropOffThreshold dynamically (standard logic)
            adjustThreshold()
        }
    }
    
    func handleStarterPhase() {
        // Set consideredCount to half the total symbols after the first addition
        if consideredCount == 0 {
            consideredCount = frequencies.count / 2
        } else {
            // Gradually reduce consideredCount by halving
            consideredCount = max(1, consideredCount / 2)
        }
        
        // Update isConsidered flags
        for (index, frequency) in frequencies.enumerated() {
            isConsidered[index] = frequency >= topFrequency - dropOffThreshold && consideredCount > 0
            if isConsidered[index] { consideredCount -= 1 }
        }

        // Exit the initial phase once consideredCount stabilizes or grows
        if consideredCount > frequencies.filter({ $0 > 0 }).count {
            starterPhase = false
        }
    }
    
    //TODO: check if this is ok
    func adjustThreshold() {
        let currentlyConsidered = isConsidered.filter { $0 }.count

        // Too many symbols considered -> tighten threshold
        if currentlyConsidered > consideredCount {
            dropOffThreshold += 1
        }
        
        // Too few symbols considered -> loosen threshold
        else if currentlyConsidered < consideredCount && dropOffThreshold > 1 {
            dropOffThreshold -= 1
        }
        
        // Update consideredCount to reflect current state
        consideredCount = currentlyConsidered
    }

    //TODO: make this
    func promoteSymbol(at index: Int){
        print("Symbol at \(index) needs to be promoted" )
    }
    
    func reset() {
        children.removeAll()
        frequencies.removeAll()
    }
}
