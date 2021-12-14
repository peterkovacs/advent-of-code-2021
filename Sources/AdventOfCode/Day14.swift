
import Foundation 
import ArgumentParser
import Algorithms
import Parsing

struct Day14: ParsableCommand {
    static let parser = PrefixUpTo("\n").map { Array($0) }
        .skip("\n\n")
        .take(
            Many(
                PrefixUpTo(" -> ").map { Array($0) }
                    .skip(" -> ")
                    .take(First())
                    .skip(Optional.parser(of: Newline().pullback(\.utf8)))
            )
                .map { Dictionary(uniqueKeysWithValues: $0) }
        )
    static let (template, rules) = parser.parse(stdin.joined(separator: "\n"))!
    
    func part1() {
        var polymer = Self.template
        for _ in 0..<10 {
            polymer = polymer.expand(rules: Self.rules)
        }
        
        print("Part 1", polymer.score)
    }
    
    func part2() {
        let expansions = Dictionary(
            uniqueKeysWithValues: Self.rules.map {
                (String($0.key), (expansion: [String([$0.key[0], $0.value]), String([$0.value, $0.key[1]])], key: $0.value))
            }
        )
        
        var counts = Self.template.reduce(into: [Character:Int]()) {
            $0[$1, default: 0] += 1
        }

        var polymer = Dictionary(
            zip( Self.template, Self.template.dropFirst() ).map { (String([$0, $1]), 1) },
            uniquingKeysWith: { $0 + $1 }
        )
        
        for _ in 0..<40 {
            var next = [String: Int]()
            for (key, multiplier) in polymer {
                let (values, increment) = expansions[key]!
                counts[increment, default: 0] += multiplier

                for i in values {
                    next[i, default: 0] += multiplier
                }
            }
            polymer = next
        }
        
        let maxScore = counts.map(\.value).max()!
        let minScore = counts.map(\.value).min()!
        
        print("Part 2", maxScore - minScore)
    }
    
    func run() {
        part1()
        part2()
    }
}

fileprivate extension Array where Element == Character {
    func expand(rules: Dictionary<[Character], Character>) -> Self {
        var result = zip( self, dropFirst() ).flatMap { (a, b) -> [Character] in
            if let insertion = rules[[a, b]] {
                return [a, insertion]
            } else {
                fatalError()
            }
        }
        result.append(last!)
        return result
    }
    
    var frequencies: (min: Int, max: Int) {
        let frequencies = reduce(into: [Character:Int]()) {
            $0[$1, default: 0] += 1
        }
        
        return frequencies.values.minAndMax()!
    }
    
    var score: Int {
        let (min, max) = self.frequencies
        return max - min
    }
}
