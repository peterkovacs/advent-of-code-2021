
import Foundation 
import ArgumentParser
import Algorithms

struct Day20: ParsableCommand {
    static let input = Array(stdin)
    static let algorithm = Array(input[0])
    static let instructions = InfiniteGrid(input[2...].joined(), maxX: input[2].count, defaultValue: ".")
    
    func run() {
        let part1 = Self.instructions
            .enhance(Self.algorithm)
            .enhance(Self.algorithm)
            .reduce(into: 0) { $0 += $1 == "#" ? 1 : 0 }
        print("Part 1", part1)
        
        let part2 = (0..<50)
            .reduce(into: Self.instructions) { r, _ in
                r = r.enhance(Self.algorithm)
            }
            .reduce(into: 0) {
                $0 += $1 == "#" ? 1 : 0
            }
        print("Part 2", part2)
    }
}

fileprivate extension Coordinate {
    var input: [Coordinate] {
        [ left.up, up, right.up, left, self, right, left.down, down, right.down ]
    }
}

fileprivate extension InfiniteGrid where Element == Character {
    func enhance(_ instructions: [Character]) -> Self {
        var result = InfiniteGrid([], maxX: 0, defaultValue: defaultValue == "#" ? "." : "#")
        let iterator = CoordinateIterator(
            minX: minX - 1,
            maxX: maxX + 1,
            minY: minY - 1,
            maxY: maxY + 1,
            coordinate: .init(x: minX - 1, y: minY - 1)
        )
                
        for c in iterator {
            let index = c.input.reversed().enumerated().reduce(into: 0) {
                if self[$1.element] == "#" {
                    $0 = $0 | (1 << $1.offset)
                }
            }
            
            result[c] = instructions[index]
        }
        
        return result
    }
}
