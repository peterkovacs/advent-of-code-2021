
import Foundation 
import ArgumentParser
import Algorithms

struct Day1: ParsableCommand {
    static let input = stdin.compactMap(Int.init)
    func run() {

        let part1 = zip(Self.input, Self.input.dropFirst()).reduce(0) { $0 + (($1.0 < $1.1) ? 1 : 0)}
        print("Part 1: \(part1)")

        let part2 =
        zip(
            Self.input.indices.dropLast(2).map{ Self.input[$0..<$0+3].reduce(0,+) },
            Self.input.indices.dropLast(2).dropFirst().map{ Self.input[$0..<$0+3].reduce(0,+) }
        ).reduce(0) { $0 + (($1.0 < $1.1) ? 1 : 0)}

        print("Part 2: \(part2)")
    }
}
