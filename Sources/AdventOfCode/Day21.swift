
import Foundation 
import ArgumentParser
import Algorithms

struct Pair<T> {
    var _1, _2: T
    
    init(_ _1: T, _ _2: T) {
        self._1 = _1
        self._2 = _2
    }
}

extension Pair: Equatable where T: Equatable {}
extension Pair: Hashable where T: Hashable {}
extension Pair: CustomStringConvertible where T: CustomStringConvertible {
    var description: String {
        "(\(_1), \(_2))"
    }
}

typealias Score = Pair<Int>
typealias Position = Pair<Int>
typealias Universes = Int

struct Day21: ParsableCommand {
    static let rolls = product(1...3, product(1...3, 1...3)).reduce(into: [Int: Universes]()) {
        $0[
            $1.1.1 + $1.1.0 + $1.0,
            default: 0
        ] += 1
    }

    func turn(prev previousTurn: [Score: [Position: Universes]]) -> [Score: [Position: Universes]]? {
        var nextTurn = [Score: [Position: Universes]]()
        
        // Only look at positions that have not yet won the game.
        for (prevScore, positions) in previousTurn where prevScore._1 < 21 && prevScore._2 < 21 {
            for (position, positionUniverses) in positions {
                for (roll1, roll1Universes) in Day21.rolls {
                    // Player 1 goes first.
                    var newPosition = Position(
                        (position._1 + roll1) % 10 == 0 ? 10 : (position._1 + roll1) % 10,
                        position._2
                    )
                    
                    var newScore = Score(
                        prevScore._1 + newPosition._1,
                        prevScore._2
                    )
                    
                    if newScore._1 >= 21 {
                        // This game ends without any more rolls.
                        nextTurn[newScore, default: [:]][newPosition, default: 0] += (positionUniverses * roll1Universes)
                        continue
                    }
                    
                    // Then player 2 goes.
                    for (roll2, roll2Universes) in Day21.rolls {
                        newPosition._2 = (position._2 + roll2) % 10 == 0 ? 10 : (position._2 + roll2) % 10
                        newScore._2 = prevScore._2 + newPosition._2
                        nextTurn[newScore, default: [:]][newPosition, default: 0] += (positionUniverses * roll1Universes * roll2Universes)
                    }
                    
                }
            }
        }
        
        if nextTurn.isEmpty { return nil }
        return nextTurn
    }
    
    func run() {
        // Part 1 was solved by hand by analyzing the repetitive nature of the game with a deterministic die.
        
        // Part 2:
        var turns: [[Score: [Position: Universes]]] = [[Score(0, 0): [Position(4, 5): 1]]]

        while true {
            guard let next = turn(prev: turns.last!) else { break }
            turns.append(next)
        }
        
        let scores = turns.map { $0.mapValues { $0.values.reduce(Universes(0), +) } }
        
        let wins = scores.reduce(into: (0, 0)) { result, value in
            result.0 += value.filter { $0.key._1 >= 21 }.values.reduce(0, +)
            result.1 += value.filter { $0.key._2 >= 21 && $0.key._1 < 21 }.values.reduce(0, +)
        }

        print("Part 2", max(wins.0, wins.1))
    }
}
