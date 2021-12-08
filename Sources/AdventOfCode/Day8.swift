
import Foundation 
import ArgumentParser
import Algorithms
import Parsing

fileprivate enum Segment: String {
    case a, b, c, d, e, f, g
}

struct Day8: ParsableCommand {
    fileprivate static let parser = Many(
        Many( Prefix<Substring>(1) { $0.isLetter }.map { Segment(rawValue: String($0))! }, atLeast: 2, atMost: 7 ).map(Set.init)
            .skip(Optional.parser(of: Whitespace().pullback(\.utf8))),
        atMost: 10
    )
        .skip("| ")
        .take(
            Many(
                Many( Prefix<Substring>(1) { $0.isLetter }.map { Segment(rawValue: String($0))! }, atLeast: 2, atMost: 7 ).map(Set.init)
                    .skip(Optional.parser(of: Whitespace().pullback(\.utf8))),
                atMost: 4
            )
        )
        .skip(End())

    fileprivate static let input = stdin.compactMap { parser.parse($0) }

    func part1() {
        let result = Self.input.reduce(into: 0) {
            $0 += $1.1.reduce(into: 0) {
                $0 += [2, 3, 4, 7].contains($1.count ) ? 1 : 0
            }
        }

        print("Part 1", result)
    }
    
    fileprivate func determine(_ input: [Set<Segment>]) -> [Set<Segment>] {
        var data = Set(input)
        var result = [Set<Segment>](repeating: .init(), count: 10)
        
        result[1] = data.first(where: { $0.count == 2})!
        data.remove(result[1])

        result[4] = data.first(where: { $0.count == 4})!
        data.remove(result[4])

        result[7] = data.first(where: { $0.count == 3})!
        data.remove(result[7])

        result[8] = data.first(where: { $0.count == 7})!
        data.remove(result[8])

        result[9] = data.first(where: { $0.count == 6 && $0.isStrictSuperset(of: result[7].union(result[4])) })!
        data.remove(result[9])

        result[6] = data.first(where: { $0.count == 6 && $0.isStrictSuperset(of: result[8].subtracting(result[7])) })!
        data.remove(result[6])

        result[0] = data.first(where: { $0.count == 6 })!
        data.remove(result[0])

        result[5] = data.first(where: { $0.count == 5 && $0.isStrictSubset(of: result[6]) })!
        data.remove(result[5])

        result[3] = data.first(where: { $0.count == 5 && $0.isStrictSuperset(of: result[1]) })!
        data.remove(result[3])

        result[2] = data.first!
        
        return result
    }
    
    func part2() {
        let result = Self.input.reduce(0) { (result, data) in
            let order = determine(data.0)
            let digits = data.1.map {
                order.firstIndex(of: $0)!
            }
            return result + 1000 * digits[0] + 100 * digits[1] + 10 * digits[2] + digits[3]
        }
        
        print("Part 2", result)
    }
    

    func run() {
        part1()
        part2()
    }
}
