
import Foundation 
import ArgumentParser
import Algorithms

fileprivate extension String {
    var score: Int {
        var stack: [Element] = .init()
        for c in self {
            switch c {
            case "(", "<", "{", "[":
                stack.append(c)
            case ")":
                guard stack.popLast() == "(" else { return 3 }
            case "]":
                guard stack.popLast() == "[" else { return 57 }
            case "}":
                guard stack.popLast() == "{" else { return 1197 }
            case ">":
                guard stack.popLast() == "<" else { return 25137 }
            default:
                fatalError()
            }
        }
        
        return 0
    }
    
    var complete: Int {
        var stack: [Element] = .init()
        for c in self {
            switch c {
            case "(", "<", "{", "[":
                stack.append(c)
            case ")", "]", "}", ">":
                _ = stack.popLast()
            default:
                fatalError()
            }
        }

        return stack.reversed().reduce(into: 0) {
            $0 *= 5
            switch $1 {
            case "(": $0 += 1
            case "[": $0 += 2
            case "{": $0 += 3
            case "<": $0 += 4
            default: fatalError()
            }
        }
    }
}

fileprivate extension Array {
    var middle: Element {
        self[(count / 2)]
    }
}

struct Day10: ParsableCommand {
    static let input = Array(stdin)
    
    func run() {
        print("Part 1", Self.input.map(\.score).reduce(0, +))
        print("Part 2", Self.input.filter { $0.score == 0 }.map(\.complete).sorted().middle)
    }
}
