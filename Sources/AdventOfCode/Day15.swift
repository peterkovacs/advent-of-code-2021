
import Foundation 
import ArgumentParser
import Algorithms
import Collections

struct Day15: ParsableCommand {
    static let input = Array(stdin)
    func part1() {
        let grid = Grid(
            Self.input.joined().map { Int(String($0))! },
            maxX: Self.input[0].count,
            maxY: Self.input.count
        )!
        
        var q = Set<Coordinate>()
        var prev = [Coordinate: Coordinate]()
        var dist = [Coordinate: Int]()
        dist[.zero] = 0
        
        while true {
            guard let u = dist.filter( { !q.contains($0.key) }).min(by: { $0.value < $1.value })?.key else { break }
            q.insert(u)
            
            for v in grid.neighbors(u) where !q.contains(v) {
                let alt = dist[u].map { grid[v] + $0 } ?? Int.max
                if alt < dist[v] ?? Int.max {
                    dist[v] = alt
                    prev[v] = u
                }
            }
        }
        
        var result = [Coordinate]()
        var u = Coordinate(x: grid.maxX - 1, y: grid.maxY - 1) as Coordinate?
        while u != nil {
            result.append(u!)
            u = prev[u!]
        }
        
        let part1 = result.map { grid[$0] }.reduce(0, +) - grid[.zero]
        print("Part 1", part1)
    }
    
    func part2() {
        let baseGrid = Self.input.joined().map { Int(String($0))! }
        let maxX = Self.input[0].count
        let maxY = Self.input.count
        
        let grid = Grid(
            product(0..<(maxY * 5), 0..<(maxX * 5)).map { y, x -> Int in
                let offsetX = (x % maxX)
                let offsetY = (y % maxY)
                let value = baseGrid[offsetY * maxX + offsetX] + (x / maxX) + (y / maxY)
                return value > 9 ? value - 9 : value
            },
            maxX: maxX * 5,
            maxY: maxY * 5
        )!
        
        var q = Set<Coordinate>()
        var prev = [Coordinate: Coordinate]()
        var dist = [Coordinate: Int]()
        dist[.zero] = 0
        
        while true {
            guard let u = dist.filter( { !q.contains($0.key) }).min(by: { $0.value < $1.value })?.key else { break }
            q.insert(u)
            
            for v in grid.neighbors(u) where !q.contains(v) {
                let alt = dist[u].map { grid[v] + $0 } ?? Int.max
                if alt < dist[v] ?? Int.max {
                    dist[v] = alt
                    prev[v] = u
                }
            }
        }
        
        var result = [Coordinate]()
        var u = Coordinate(x: grid.maxX - 1, y: grid.maxY - 1) as Coordinate?
        while u != nil {
            result.append(u!)
            u = prev[u!]
        }
        
        let part1 = result.map { grid[$0] }.reduce(0, +) - grid[.zero]
        print("Part 2", part1)

    }
    
    func run() {
        part1()
        part2()
    }
}
