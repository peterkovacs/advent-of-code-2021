
import Foundation 
import ArgumentParser
import Algorithms

struct Day9: ParsableCommand {
    static let input = stdin.joined(separator: "").map { Int(String($0))! }
    static let grid = Grid.square(input)!
    
    func part1() {
        let riskLevels = Self.grid.indices.filter { c in
            Self.grid.neighbors(c).allSatisfy { Self.grid[$0] > Self.grid[c] }
        }.reduce(0) { $0 + Self.grid[$1] + 1 }
        
        print("Part 1", riskLevels)
    }
    
    func part2() {
        var visited = Grid.square(repeatElement(false, count: Self.grid.maxY * Self.grid.maxX))!
        var basinSizes = [Int]()
        var currentSize = 0
        
        func flood(index: Coordinate) {
            guard !visited[index] && Self.grid[index] != 9 else { return }
            
            visited[index] = true
            currentSize += 1
            
            for neighbor in visited.neighbors(index) {
                flood(index: neighbor)
            }
        }

        Self.grid.indices.forEach {
            if !visited[$0] && Self.grid[$0] != 9 {
                flood(index: $0)
                basinSizes.append(currentSize)
                currentSize = 0
            }
        }
        
        let basins = basinSizes.sorted().reversed().prefix(3).reduce(1, *)
        print("Part 2", basins)
    }
    
    func run() {
        part1()
        part2()
    }
}
