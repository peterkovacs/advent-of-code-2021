
import Foundation 
import ArgumentParser
import Algorithms
import Parsing

struct Day4: ParsableCommand {
    static let parser = Many(
        Int.parser()
            .skip(Optional.parser(of: StartsWith<Substring>(",")))
    )
        .skip(Newline().pullback(\.utf8))
        .skip(Newline().pullback(\.utf8))
        .take(
            Many(
                Many(
                    Int.parser()
                        .skip(Whitespace().pullback(\.utf8)),
                    atLeast: 25,
                    atMost: 25
                ),
                atLeast: 1
            )
        )
        .skip(End())
        .eraseToAnyParser()
    
    static let (numbers, cards) = parser.parse(String(stdin.joined(by: "\n")))!
    
    func part1() -> Int {
        let (card, turn) = Self.cards.map { ($0, $0.winningTurn(called: Self.numbers)) }.sorted { $0.1 < $1.1 }.first!
        return Set(card).subtracting(Self.numbers[0...turn]).reduce(0, +) * Self.numbers[turn]
    }
    
    func part2() -> Int {
        let (card, turn) = Self.cards.map { ($0, $0.winningTurn(called: Self.numbers)) }.sorted { $0.1 > $1.1 }.first!
        return Set(card).subtracting(Self.numbers[0...turn]).reduce(0, +) * Self.numbers[turn]
   }
    
    func run() {
        print("Part 1", part1())
        print("Part 2", part2())
    }
}

extension Array where Element == Int {
    var bingoLines: [Set<Int>] {
        [
            Set([self[0+0], self[0+1], self[0+2], self[0+3], self[0+4]]),
            Set([self[5+0], self[5+1], self[5+2], self[5+3], self[5+4]]),
            Set([self[10+0], self[10+1], self[10+2], self[10+3], self[10+4]]),
            Set([self[15+0], self[15+1], self[15+2], self[15+3], self[15+4]]),
            Set([self[20+0], self[20+1], self[20+2], self[20+3], self[20+4]]),
            
            Set([self[0+0], self[0+5], self[0+10], self[0+15], self[0+20]]),
            Set([self[1+0], self[1+5], self[1+10], self[1+15], self[1+20]]),
            Set([self[2+0], self[2+5], self[2+10], self[2+15], self[2+20]]),
            Set([self[3+0], self[3+5], self[3+10], self[3+15], self[3+20]]),
            Set([self[4+0], self[4+5], self[4+10], self[4+15], self[4+20]]),
        ]
    }
    
    func winningTurn(called: [Int]) -> Int {
        for i in 4..<called.count {
            if bingoLines.contains(where: { $0.isStrictSubset(of: Set(called[0...i])) }) {
                return i
            }
        }
        
        fatalError()
    }
}
