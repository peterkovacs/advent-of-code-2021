
import Foundation 
import ArgumentParser
import Algorithms
import Parsing

struct Coord: Hashable {
    let x, y: Int
}

struct Day5: ParsableCommand {
    static let parser = Int.parser()
        .skip(",")
        .take(Int.parser())
        .skip(" -> ")
        .take(Int.parser())
        .skip(",")
        .take(Int.parser())
    
    static let input = stdin.compactMap(parser.parse)
    
    func run() {
        part1()
        part2()
    }
    
    func part1() {
        let grid = Self.input.filter {
            $0.0 == $0.2 || $0.1 == $0.3
        }.flatMap { (x1, y1, x2, y2) in
            x1 == x2 ?
            (min(y1, y2)...max(y1, y2)).map { Coord(x: x1, y: $0)} :
            (min(x1, x2)...max(x1, x2)).map { Coord(x: $0, y: y1)}
        }.reduce(into: [Coord: Int]()) {
            $0[$1, default: 0] += 1
        }
        
        print("Part 1:", grid.filter { $0.value > 1 }.count)
    }
    
    func part2() {
        let grid: [Coord: Int] = Self.input.flatMap { (x1, y1, x2, y2) -> [Coord] in
            if x1 == x2 {
                return (min(y1, y2)...max(y1, y2)).map { Coord(x: x1, y: $0)}
            } else if y1 == y2 {
                return (min(x1, x2)...max(x1, x2)).map { Coord(x: $0, y: y1)}
            } else {
                return zip(
                    x1 < x2 ? Array(x1...x2) : Array((x2...x1).reversed()),
                    y1 < y2 ? Array(y1...y2) : Array((y2...y1).reversed())
                ).map(Coord.init)
            }
        }.reduce(into: [Coord: Int]()) {
            $0[$1, default: 0] += 1
        }

        print("Part 2:", grid.filter { $0.value > 1 }.count)

    }
}
