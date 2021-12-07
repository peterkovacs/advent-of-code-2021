
import Foundation 
import ArgumentParser
import Algorithms
import Parsing

struct Day6: ParsableCommand {
    static let parser = Many(
        Int.parser()
            .skip(Optional.parser(of: ","))
    )
    
    static let input = parser.parse(stdin.joined(separator: ""))!
    
    func part1() {
        var ages = Dictionary(lanternFish: Self.input)
        for _ in 0..<80 {
            ages = ages.nextDay
        }
        
        print("Part 1", ages.values.reduce(0, +))
    }
    
    func part2() {
        var ages = Dictionary(lanternFish: Self.input)
        for _ in 0..<256 {
            ages = ages.nextDay
        }
        
        print("Part 2", ages.values.reduce(0, +))
    }

    func run() {
        part1()
        part2()
    }
}

fileprivate extension Dictionary where Key == Int, Value == Int {
    init(lanternFish input: [Int]) {
        self = input.reduce(into: [:]) {
            $0[$1, default: 0] += 1
        }
    }
    
    var nextDay: Self {
        reduce(into: Self()) {
            switch $1.key {
            case 0:
                $0[8, default: 0] += $1.value
                $0[6, default: 0] += $1.value
            default:
                $0[$1.key - 1, default: 0] += $1.value
            }
        }
    }
}
