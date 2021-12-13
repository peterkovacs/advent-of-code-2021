
import Foundation 
import ArgumentParser
import Algorithms
import Parsing

struct Day13: ParsableCommand {
    static let parser = Many(
        Int.parser()
            .skip(",")
            .take(Int.parser())
            .map(Coordinate.init(x:y:))
            .skip(Newline().pullback(\.utf8))
    )
        .skip(Whitespace().pullback(\.utf8))
        .take(
            Many(
                OneOfMany(
                    StartsWith("fold along x=")
                        .take(Int.parser()).map { Coordinate(x: $0, y: 0) },
                    StartsWith("fold along y=")
                        .take(Int.parser()).map { Coordinate(x: 0, y: $0) }
                )
                    .skip(Optional.parser(of: Newline().pullback(\.utf8)))
            )
        )
        .skip(End())
    
    static let (input, instructions) = parser.parse(stdin.joined(separator: "\n"))!

    func run() {
        let (maxX, maxY) = (Self.input.max(by: { $0.x < $1.x })!.x + 1, Self.input.max(by: { $0.y < $1.y })!.y + 1)
        var grid = Grid(repeatElement(" " as Character, count: maxX * maxY), maxX: maxX, maxY: maxY)!
        for i in Self.input { grid[i] = "█" as Character }
        
        grid = grid.fold(Self.instructions[0])
        print("Part 1", grid.filter { $0 == "█" }.count)

        grid = Self.instructions.dropFirst().reduce(grid) { $0.fold($1) }
        
        print("Part 2")
        print(grid)
    }
}

fileprivate extension Grid where Element == Character {
    func fold(_ coordinate: Coordinate) -> Self {
        let folded: Self
        var result: Self
        
        if coordinate.x > 0 {
            folded = self[x: (coordinate.x + 1) ..< maxX, y: 0..<maxY]!.mirrored
            result = self[x: 0..<(coordinate.x), y: 0..<maxY]!
        } else {
            folded = self[x: 0..<maxX, y: (coordinate.y + 1) ..< maxY]!.flipped
            result = self[x: 0..<maxX, y: 0..<coordinate.y]!
        }

        for i in folded.indices {
            result[i] = result[i] == "█" || folded[i] == "█" ? "█" : " "
        }
            
        return Grid(result, maxX: result.maxX, maxY: result.maxY)!
    }
}
