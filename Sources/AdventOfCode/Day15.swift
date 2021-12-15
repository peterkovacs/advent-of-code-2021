
import Foundation 
import ArgumentParser
import Algorithms
import Collections

struct Day15: ParsableCommand {
    static let input = Array(stdin)
    
    func dijkstra(grid: Grid<Int>) -> Int {
        var q = Set<Coordinate>(grid.indices)
        var prev = [Coordinate: Coordinate]()
        var dist = [Coordinate: Int]()
        var heap = Heap<Node>([.init(coordinate: .zero, cost: 0)])
        dist[.zero] = 0
        
        while true {
            guard let u = heap.popMin() else { break }
            guard dist[u.coordinate] == u.cost else { continue }
            q.remove(u.coordinate)
            
            for v in grid.neighbors(u.coordinate) where q.contains(v) {
                let alt = dist[u.coordinate].map { grid[v] + $0 } ?? Int.max
                if alt < dist[v] ?? Int.max {
                    heap.insert(.init(coordinate: v, cost: alt))
                    dist[v] = alt
                    prev[v] = u.coordinate
                }
            }
        }

        var result = [Coordinate]()
        var u = Coordinate(x: grid.maxX - 1, y: grid.maxY - 1) as Coordinate?
        while u != nil {
            result.append(u!)
            u = prev[u!]
        }
        
        return result.map { grid[$0] }.reduce(0, +) - grid[.zero]
    }
    
    func part1() {
        let grid = Grid(
            Self.input.joined().map { Int(String($0))! },
            maxX: Self.input[0].count,
            maxY: Self.input.count
        )!
        
        print("Part 1", dijkstra(grid: grid))
    }
    
    struct Node: Comparable {
        
        let coordinate: Coordinate
        let cost: Int
        static func <(lhs: Node, rhs: Node) -> Bool {
            lhs.cost < rhs.cost
        }
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
        
        print("Part 2", dijkstra(grid: grid))

    }
    
    func run() {
        part1()
        part2()
    }
}
