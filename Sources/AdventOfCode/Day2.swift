
import Foundation 
import ArgumentParser
import Algorithms
import Parsing

struct Day2: ParsableCommand {
    static let parser = OneOfMany(
        StartsWith("forward ").take(Int.parser()).map { ($0, 0) },
        StartsWith("up ").take(Int.parser()).map { (0, -$0) },
        StartsWith("down ").take(Int.parser()).map { (0, $0) }
    )
    static let input = stdin.compactMap { parser.parse($0) }
    
    func run() {
        let part1 = Self.input.reduce(into: (0, 0)) {
            $0.0 += $1.0
            $0.1 += $1.1
        }
        
        print("Part 1: \(part1.0 * part1.1)")
        
        let part2 = Self.input.reduce(into: (horizontal: 0, depth: 0, aim: 0)) {
            $0.aim += $1.1
            $0.horizontal += $1.0
            $0.depth += $1.0 * $0.aim
        }
        
        print("Part 2: \(part2.horizontal * part2.depth)")
    }
}
