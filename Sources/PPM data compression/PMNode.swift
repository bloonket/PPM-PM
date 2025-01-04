//
//  PMNode.swift
//  PPM data compression
//
//  Created by Pirita Minkkinen on 1/4/25.
//

class PMNode {
    var topFrequency: Int = 0
    var bottomFrequency: Int = 0
    var consideredCount: Int = 0
    var dropOffThreshold: Int = 5 // Start with a reasonable value
    //TODO: review if this is needed/good
    var starterPhase: Bool = true // Indicates if we're in the initial reduction phase

    var children: [PMNode?]
    var frequencies: [Int]
    var modifiers: [Float] //TODO: consider different float values
    var isConsidered: [Bool] // Tracks if a symbol is "likely"

    init(alphabetSize: Int?) {
        if let alphabetSize = alphabetSize {
            // Pre-allocate arrays for known alphabet size
            self.children = Array<PMNode?>(repeating: nil, count: alphabetSize)
            self.frequencies = Array<Int>(repeating: 0, count: alphabetSize)
            self.modifiers = Array<Float>(repeating: 1, count: alphabetSize)
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
        // Dynamically resize children and frequencies if needed
        if index >= children.count {
            let newSize = max(index + 1, children.count * 2) // Double size for efficiency
            children.append(contentsOf: Array<PMNode?>(repeating: nil, count: newSize - children.count))
            frequencies.append(contentsOf: Array<Int>(repeating: 0, count: newSize - frequencies.count))
        }
    }
    
    
    
    func updateFrequency(index: Int) {
        let increase = Int(1 * modifiers[index])  //TODO: change the default value to more calculated one
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
                //TODO: add modifier increase here
            }
            //increase modifier slowly, since it being bigger than 1 already causes the increase to frequencies to be exponential
            //but tbh modifier should be increased more the higher it is, so if the difference is very big (like in big data) the newly frequent letter can be bounced to top as fast as needed
            //i guess i could just double the modifier every time :D
        }
        //frecuency gets updated by 1 * modifier, the modifier is 1 first and will gratually rise to idk to what, it needs to be something meanigfull since indexes are ints at least for now, i need to consider tho having them as floats and if that even is possible :)
        // when modifier doesnt get used it decause a bit, i guess it would need to decay more and more to 1, tbh i need to consider if the decay is not taking too much to do, since it would require me to iterate trough 1 array everytime i do adjustment, i think its not worth it, i think its ok if the boosting effect stays in the memory, since it will eventually get reset and the the "error" will be corrected when the number falls from the considered list if it is not useful
        //if the frecuency causes the node to go from being not considered to considered, the modifier would need to go to 1 instatntly
        //the modifier only increases if the charachter is not considered
        
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
