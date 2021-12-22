
import Foundation 
import ArgumentParser
import Algorithms
import Parsing

extension Coordinate3D {
    typealias Transform = (Coordinate3D) -> Coordinate3D

    static let flips: [Transform] = [
        { .init(x: $0.x,  y: $0.y,  z: $0.z) },
        { .init(x: -$0.x, y: $0.y,  z: $0.z) },
        { .init(x: $0.x,  y: -$0.y, z: $0.z) },
        { .init(x: $0.x,  y: $0.y,  z: -$0.z) },
        { .init(x: -$0.x, y: -$0.y, z: $0.z) },
        { .init(x: -$0.x, y: $0.y,  z: -$0.z) },
        { .init(x: $0.x,  y: -$0.y, z: -$0.z) },
        { .init(x: -$0.x, y: -$0.y, z: -$0.z) },
    ]

    static let rotations: [Transform] = [
        { .init(x: $0.x, y: $0.y, z: $0.z) },
        { .init(x: $0.x, y: $0.z, z: $0.y) },
        { .init(x: $0.y, y: $0.x, z: $0.z) },
        { .init(x: $0.y, y: $0.z, z: $0.x) },
        { .init(x: $0.z, y: $0.x, z: $0.y) },
        { .init(x: $0.z, y: $0.y, z: $0.x) },
    ]

    static let orientations: [Transform] = flips.flatMap { flip in
        rotations.map { rotation in
            { rotation(flip($0)) }
        }
    }
}

struct Day19: ParsableCommand {
    
    static let parser = Many(
        StartsWith("--- scanner ")
            .skip(Int.parser())
            .skip(" ---\n")
            .take(
                Many(
                    Int.parser()
                        .skip(",")
                        .take(Int.parser())
                        .skip(",")
                        .take(Int.parser())
                        .map(Coordinate3D.init(x:y:z:)),
                    separator: "\n"
                )
                    .map(Scanner.init)
            )
            .skip(Whitespace().pullback(\.utf8))
        )
        .skip(End())
        .eraseToAnyParser()
    
    static let input = parser.parse(String(stdin.joined(by: "\n")) + "\n")!
        
    func run() {
        var solved = Day19.input[0]
        var unsolved = Day19.input[1...]
        var scanners = [Coordinate3D(x: 0, y: 0, z: 0)]

        while !unsolved.isEmpty {
            let solution = unsolved.indices
                .lazy
                .compactMap { (index) in solved.solve(unsolved[index]).map { (index: index, element: $0) } }
                .first
            
            if let (index, (translation, orientation)) = solution {
                solved.append(unsolved[index], translation: translation, orientation: orientation)
                scanners.append(translation)
                unsolved.remove(at: index)
            } else {
                fatalError()
            }
        }
        
        print("Part 1", solved.beacons.count)
        print("Part 2", scanners.combinations(ofCount: 2).map { abs($0[0].x - $0[1].x) + abs($0[0].y - $0[1].y) + abs($0[0].z - $0[1].z)}.max()!)
    }
}


struct Scanner {
    var beacons: Set<Coordinate3D>
    var distances: [[Coordinate3D]: Int]
    
    init<S>(_ beacons: S) where S: Sequence, S.Element == Coordinate3D {
        self.beacons = Set(beacons)
        self.distances = Dictionary(
            uniqueKeysWithValues: self.beacons.combinations(ofCount: 2).map { i -> ([Coordinate3D], Int) in
                let (x, y, z): (Int, Int, Int) = (i[0].x - i[1].x, i[0].y - i[1].y, i[0].z - i[1].z)
                return (i, x * x + y * y + z * z)
            }
        )
    }
    
    mutating func append(_ other: Scanner, translation: Coordinate3D, orientation: Coordinate3D.Transform) {
        for i in (other.beacons.map(orientation) + translation) {
            for j in beacons {
                let (x, y, z): (Int, Int, Int) = (i.x - j.x, i.y - j.y, i.z - j.z)
                distances[[i, j]] = x * x + y * y + z * z
            }
            beacons.insert(i)
        }
    }
    
    func solve(_ other: Self) -> (translation: Coordinate3D, orientation: Coordinate3D.Transform)? {
        let intersection = Set(distances.values).intersection(other.distances.values)
        if intersection.count > 11 {
            let beacons = Set(distances.filter { intersection.contains($0.value) }.flatMap(\.key))
            let otherBeacons = Set(other.distances.filter { intersection.contains($0.value) }.flatMap(\.key))
            
            for orientation in Coordinate3D.orientations {
                let oriented = otherBeacons.map(orientation)
                for reference in beacons {
                    for i in oriented {
                        let translation = reference - i
                        if beacons.intersection(oriented + translation).count > 11 {
                            return (translation: translation, orientation: orientation)
                        }
                    }
                }
            }
        }

        return nil
    }
}

extension Array where Element == Coordinate3D {
    static func +(lhs: Self, rhs: Coordinate3D) -> Self {
        lhs.map { $0 + rhs }
    }
    
    static func -(lhs: Self, rhs: Coordinate3D) -> Self {
        lhs.map { $0 - rhs }
    }
}
