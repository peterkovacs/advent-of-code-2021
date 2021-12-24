
import Foundation
import ArgumentParser
import Algorithms
import Collections

struct Day23: ParsableCommand {
    // static let input = Array(stdin)
    // #############
    // #...........#
    // ###B#C#C#B###
    //   #D#D#A#A#
    //   #########
//    static let input = """
//    #############\
//    #.B.A.....BA#\
//    ###.#.#C#D###\
//      #.#.#C#D#  \
//      #########
//    """

    static let grid = Grid(Array(stdin).joined(), maxX: 13, maxY: 7)!
    func run() {
        print(solve())
    }
    
    struct State: Comparable, Hashable, CustomStringConvertible {
        var grid: Grid<Character>
        var cost: Int
        var previous: [State] = []
        
        var description: String {
            return """
            \(previous.map(\.description).joined(separator: "\n"))

            \(grid.description)
            COST: \(cost)
            """
        }
        
        static func <(lhs: Self, rhs: Self) -> Bool {
            return lhs.cost < rhs.cost
        }
    }
    
    func solve() -> Int {
        var visited: [Grid<Character>: Int] = .init()
        var queue: Heap<State> = [ State(grid: Self.grid, cost: 0) ]
        var lowestCost = Int.max
        
        while !queue.isEmpty {
            let state = queue.removeMin()
            if state.cost > lowestCost { continue }
            
            for (room, amphipod) in state.grid.movements() {
                let moves = state.grid.indices.compactMap { state.grid.movement(from: room, to: $0) }
                for (move, steps) in moves {
                    var newState = state
                    (newState.grid[move], newState.grid[room]) = (amphipod, ".")
                    newState.cost += amphipod.cost * steps
                    newState.previous.append(state)
                    
                    if visited[newState.grid, default: Int.max] > newState.cost {
                        visited[newState.grid] = newState.cost
                        
                        if newState.grid.isWinning, newState.cost < lowestCost {
                            print("FOUND NEW LOWEST COST", newState.cost)
                            lowestCost = newState.cost
                        } else {
                            queue.insert(newState)
                        }
                    }
                }
            }
        }
        
        return lowestCost
    }

}

extension Grid: Equatable where Element: Equatable {
    
}

extension Grid: Hashable where Element: Hashable {
    public func hash(into hasher: inout Hasher) {
        grid.hash(into: &hasher)
    }
}

fileprivate extension Character {
    var cost: Int {
        switch self {
        case "A": return 1
        case "B": return 10
        case "C": return 100
        case "D": return 1000
        default: fatalError()
        }
    }
}

fileprivate extension Grid where Element == Character {
    var isWinning: Bool {
        func isLetter(_ letter: Character, at x: Int) -> Bool {
            var i = Coordinate(x: x, y: 2)
            while self[i] != "#" {
                guard self[i] == letter else { return false }
                i = i.down
            }
            
            return true
        }
        
        return isLetter("A", at: 3) && isLetter("B", at: 5) && isLetter("C", at: 7) && isLetter("D", at: 9)
    }
    
    func movements() -> [(Coordinate, Character)] {
        return zip(indices, grid).filter { (i, amphipod) in
            guard amphipod.isLetter else { return false }

            switch (i.x, amphipod) {
                
            case (3, "A"), (5, "B"), (7, "C"), (9, "D"):
                guard i.y > 1 else { return false }
                var i = i
                while self[i] != "#" {
                    guard self[i] == amphipod else { return true }
                    i = i.down
                }
                return false
            default: return self.neighbors(i).contains { self[$0] == "." }
            }
        }
    }
    
    // TODO: Do this once between each pair of valid points so that we don't have to pathfind every single time.
    func movement(from: Coordinate, to: Coordinate) -> (Coordinate, Int)? {
        guard self[to] == "." else { return nil }
        
        precondition(self[from].isLetter)
        
        // Amphipods must make a turn in their movement.
        if from.y == 1, to.y == 1 { return nil }
        if to.y == 1, self[to.down] != "#" { return nil }
        if from.y > 1, to.x == from.x { return nil }
        if to.y > 1 {
            switch (to.x, self[from]) {
            case (3, "A"), (5, "B"), (7, "C"), (9, "D"):
                guard self[to.down] == "#" || self[to.down] == self[from] else { return nil }
            default: return nil
            }
        }

        var visited = Set<Coordinate>()
        var queue: Deque = [(from, 0)]
        
        while !queue.isEmpty {
            let (i, steps) = queue.removeFirst()
            guard i != to else { return (to, steps) }
            visited.insert(i)
            queue.append(
                contentsOf: neighbors(i)
                    .filter { !visited.contains($0) }
                    .filter { self[$0] == "." }
                    .map { ($0, steps + 1) }
            )
        }
        
        return nil
    }
}
