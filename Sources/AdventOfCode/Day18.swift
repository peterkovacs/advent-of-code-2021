
import Foundation 
import ArgumentParser
import Algorithms
import Parsing

enum SnailNumber: Equatable {
    case regular(Int)
    indirect case pair(SnailNumber, SnailNumber)
    
    // Pop pop!
    var magnitude: Int {
        switch self {
        case .regular(let value): return value
        case .pair(let left, let right):
            return 3 * left.magnitude + 2 * right.magnitude
        }
    }
}

struct Day18: ParsableCommand {
    static let input = stdin.map { SnailNumber.parser.parse($0)! }

    func run() {
        let part1 = Day18.input.dropFirst().reduce( Day18.input[0].reduce() ) {
            let value: SnailNumber = .pair($0, $1).reduce()
            return value
        }
        
        print("Part 1", part1.magnitude)
        
        let part2 = Day18.input.permutations(ofCount: 2).map {
            SnailNumber.pair($0[0], $0[1]).reduce().magnitude
        }.max()
        
        print("Part 2", part2 ?? 0)
    }
}

extension SnailNumber {
    static func inner() -> AnyParser<Substring, SnailNumber> {
        Int.parser().map { SnailNumber.regular($0) }
        .orElse( Lazy { SnailNumber.parser } )
        .eraseToAnyParser()
    }
    
    static let parser = StartsWith<Substring>("[")
        .take( SnailNumber.inner() )
        .skip(",")
        .take( SnailNumber.inner() )
        .skip("]")
        .map { SnailNumber.pair($0.0, $0.1) }
        .eraseToAnyParser()
    
    func reduce() -> Self {
        if let exploded = explode(depth: 0)?.0 {
            return exploded.reduce()
        }

        if let split = split() {
            return split.reduce()
        }
        
        return self
    }
    
    func adding(left: Int) -> Self {
        switch self {
        case .regular(let a): return .regular(a + left)
        case .pair(let a, let b): return .pair(a.adding(left: left), b)
        }
    }
    
    func adding(right: Int) -> Self {
        switch self {
        case .regular(let a): return .regular(a + right)
        case .pair(let a, let b): return .pair(a, b.adding(right: right))
        }
    }
    
    func explode(depth: Int) -> (Self, (left: Int?, right: Int?))? {
        switch self {
        case .regular: return nil
        case let .pair(.regular(left), .regular(right)) where depth > 3:
            return (.regular(0), (left: left, right: right))
        case let .pair(l, r):
            if let (left, values) = l.explode(depth: depth + 1) {
                return (
                    .pair(left, values.right.map { r.adding(left: $0) } ?? r),
                    (left: values.left, right: nil)
                )
            } else if let (right, values) = r.explode(depth: depth + 1) {
                return (
                    .pair(values.left.map { l.adding(right: $0) } ?? l, right),
                    (left: nil, right: values.right)
                )
            } else {
                return nil
            }
        }
    }
    
    func split() -> Self? {
        switch self {
        case .regular(let a) where a > 9:
            return .pair(
                .regular(Int((Double(a)/2).rounded(.down))),
                .regular(Int((Double(a)/2).rounded(.up)))
            )
        case .regular: return nil
        case .pair(let left, let right):
            if let left = left.split() {
                return .pair(left, right)
            } else if let right = right.split() {
                return .pair(left, right)
            } else {
                return nil
            }
        }
    }
}

extension SnailNumber: CustomStringConvertible {
    var description: String {
        switch self {
        case .regular(let a): return String(a)
        case .pair(let a, let b):
            return "[\(a),\(b)]"
        }
    }
}
