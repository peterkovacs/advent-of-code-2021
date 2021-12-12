
import Foundation 
import ArgumentParser
import Algorithms
import Parsing
import DequeModule

fileprivate enum Cave: Hashable {
    case start
    case end
    case big(String)
    case small(String)
    
    static let caveParser = OneOfMany(
        StartsWith("start").map { _ in Cave.start }.eraseToAnyParser(),
        StartsWith("end").map { _ in .end }.eraseToAnyParser(),
        Prefix(minLength: 2, maxLength: 2, while: \.isUppercase).map { .big(String($0)) }.eraseToAnyParser(),
        Prefix(minLength: 2, maxLength: 2, while: \.isLowercase).map { .small(String($0)) }.eraseToAnyParser()
    )
    static let parser = caveParser
        .skip("-")
        .take(caveParser)
        .skip(End())
}

struct Day12: ParsableCommand {
    fileprivate static let input = stdin.map { Cave.parser.parse($0)! }
    func part1() {
        let edges = Dictionary(grouping: Self.input + Self.input.map { ($0.1, $0.0) }, by: \.0).mapValues { $0.map(\.1) }
        var paths = 0
        struct Path {
            var last: Cave
            var visited: Set<Cave>
        }
        
        var queue = Deque([Path(last: .start, visited: .init())])
        
        while !queue.isEmpty {
            let workingOn = queue.removeFirst()
            for node in edges[workingOn.last]! {
                switch node {
                case .end:
                    paths += 1
                case .start: break
                case .small:
                    var nextStep = workingOn
                    nextStep.last = node
                    let (newMember, _) = nextStep.visited.insert(node)
                    if newMember {
                        queue.append(nextStep)
                    }
                case .big:
                    var nextStep = workingOn
                    nextStep.last = node

                    queue.append(nextStep)
                }
            }
        }
        
        print("Part 1", paths)
    }
    
    func part2() {
        let edges = Dictionary(grouping: Self.input + Self.input.map { ($0.1, $0.0) }, by: \.0).mapValues { $0.map(\.1) }
        var paths = 0
        struct Path {
            var small: Cave?
            var last: Cave
            var visited: Set<Cave>
        }
        
        var queue = Deque([Path(small: nil, last: .start, visited: .init())])
        
        while !queue.isEmpty {
            let workingOn = queue.removeFirst()
            for node in edges[workingOn.last]! {
                switch node {
                case .end:
                    paths += 1
                case .start: break
                case .small:
                    var nextStep = workingOn
                    nextStep.last = node
                    let (newMember, _) = nextStep.visited.insert(node)
                    if newMember {
                        queue.append(nextStep)
                    } else if nextStep.small == nil {
                        nextStep.small = node
                        queue.append(nextStep)
                    }
                case .big:
                    var nextStep = workingOn
                    nextStep.last = node

                    queue.append(nextStep)
                }
            }
        }
        
        print("Part 2", paths)
    }

    
    func run() {
        part1()
        part2()
    }
}
