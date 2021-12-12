
import Foundation 
import ArgumentParser
import Algorithms
import DequeModule

struct Day11: ParsableCommand {
    static let input = stdin.joined(separator: "").map { Int(String($0))! }
    func part1() {
        var grid = Grid.square(Self.input)!
        assert(grid.maxX == 10 && grid.maxY == 10)
        
        var flashes = 0
        for _ in 0..<100 {
            let (a, b) = grid.step
            flashes += a
            grid = b
        }
        
        print(grid)
        print("Part 1", flashes)
    }
    
    func part2() {
        var grid = Grid.square(Self.input)!
        for i in 0... {
            let (a, b) = grid.step
            if a == grid.maxY * grid.maxX {
                print("Part 2", i + 1)
                break
            }
            grid = b
        }
    }
    func run() {
        part1()
        part2()
    }
}

fileprivate extension Grid where Element == Int {
    var step: (Int, Self) {
        var result = self.map { $0 + 1 }
        var flashes = Deque( self.indices.filter { result[$0] > 9 } )
        var count = flashes.count

        while !flashes.isEmpty {
            for i in result.neighbors8(flashes.removeFirst()) {
                result[i] += 1
                if result[i] == 10 {
                    count += 1
                    flashes.append(i)
                }
            }
        }
        
        return (count, result.map { $0 > 9 ? 0 : $0 })
    }
}
