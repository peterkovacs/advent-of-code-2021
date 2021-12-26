
import Foundation 
import ArgumentParser
import Algorithms

struct Day25: ParsableCommand {
    static let input = Array(stdin)
    func run() {
        var grid = Grid(Day25.input.joined(), maxX: Day25.input[0].count, maxY: Day25.input.count)!
        
        for i in 1... {
            guard let next = grid.step() else {
                print("Result", i)
                break
            }
            grid = next
        }
    }
}

fileprivate extension Coordinate {
    func right(wrapping maxX: Int) -> Coordinate {
        self.right.isValid(x: maxX, y: Int.max) ? self.right : Coordinate(x: 0, y: y)
    }
    func down(wrapping maxY: Int) -> Coordinate {
        self.down.isValid(x: Int.max, y: maxY) ? self.down : Coordinate(x: x, y: 0)
    }

}

fileprivate extension Grid where Element == Character {
    func step() -> Self? {
        var result = self
        var moved = false
        do {
            let step = self
            for (c, cucumber) in zip(indices, self) where cucumber == ">" {
                guard step[c.right(wrapping: maxX)] == "." else { continue }
                moved = true
                (result[c.right(wrapping: maxX)], result[c]) = (step[c], step[c.right(wrapping: maxX)])
            }
        }
        
        do {
            let step = result
            for (c, cucumber) in zip(indices, self) where cucumber == "v" {
                guard step[c.down(wrapping: maxY)] == "." else { continue }
                moved = true
                (result[c.down(wrapping: maxY)], result[c]) = (step[c], step[c.down(wrapping: maxY)])
            }
        }

        
        guard moved else { return nil }
        return result
    }
}
