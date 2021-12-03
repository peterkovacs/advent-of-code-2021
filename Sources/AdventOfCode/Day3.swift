
import Foundation 
import ArgumentParser
import Algorithms

struct Day3: ParsableCommand {
    static let input = stdin.map { Array($0) }
    
    func frequencies(of input: [[String.Element]]) -> [(Int, Int)] {
        input[0].indices.map { i in
            input.map { $0[i] }.reduce(into: (0, 0)) {
                $0.0 += $1 == "0" ? 1 : 0
                $0.1 += $1 == "1" ? 1 : 0
            }
        }
    }
    
    func scrubber(index i: Int, of input: [[String.Element]], comparison: ((Int, Int)) -> Character) -> Int {
        let keep = comparison(frequencies(of: input)[i])
        let filtered = input.filter { $0[i] == keep }
        if filtered.count == 1 {
            return Int(String(filtered[0]), radix: 2)!
        } else {
            return scrubber(index: i + 1, of: filtered, comparison: comparison)
        }
    }
    
    func run() {
        let gamma = Int(String(frequencies(of: Self.input).map { $0.1 > $0.0 ? "1" : "0" }), radix: 2)!
        let epsilon = Int(String(frequencies(of: Self.input).map { $0.1 < $0.0 ? "1" : "0" }), radix: 2)!
        
        print("Part 1: \(gamma * epsilon)")
        
        let o2 = scrubber(index: 0, of: Self.input) { $0.0 > $0.1 ? "0" : "1" }
        let co2 = scrubber(index: 0, of: Self.input) { $0.0 <= $0.1 ? "0" : "1" }
    
        print("Part 2: \(o2 * co2)")
    }
}
