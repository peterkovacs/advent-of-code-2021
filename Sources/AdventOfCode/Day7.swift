
import Foundation 
import ArgumentParser
import Algorithms
import Parsing

struct Day7: ParsableCommand {
    static let parser = Many(
        Int.parser()
            .skip(Optional.parser(of: ","))
    )
    
    static let input = parser.parse(stdin.joined(separator: ""))!
    
    func part1() {
        let min = Self.input.min()!
        let max = Self.input.max()!
        let part1 = (min...max).map { i in
            Self.input.map { abs($0 - i) }.reduce(0,+)
        }.min()!
        print("Part 1:", part1)
    }
    
    func part2() {
        let min = Self.input.min()!
        let max = Self.input.max()!
        let part2 = (min...max).map { i in
            Self.input.map { (position) -> Int in
                let steps = abs(position - i)
                return (steps * (steps + 1)) / 2
            }.reduce(0,+)
        }.min()!
        print("Part 2:", part2)
    }


    func run() {
        part1()
        part2()
    }
}
