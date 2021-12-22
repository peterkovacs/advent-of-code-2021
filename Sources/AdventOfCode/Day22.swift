
import Foundation 
import ArgumentParser
import Algorithms
import Parsing

struct Day22: ParsableCommand {
    static let range = Int.parser()
        .skip("..")
        .take(Int.parser())
        .map { $0.0...$0.1 }
        .eraseToAnyParser()

    static let parser =
    OneOfMany(
        StartsWith<Substring>("on ").map { true },
        StartsWith("off ").map { false }
    )
        .skip("x=")
        .take(range)
        .skip(",y=")
        .take(range)
        .skip(",z=")
        .take(range)
        .eraseToAnyParser()
    
    static let input = stdin.map { parser.parse($0)! }
    
    func part1() {
        let targetArea = -50...50
        let (count, _) = Self.input.reduce(into: (0, InfiniteGrid3D([], maxX: 0, maxY: 0, defaultValue: false))) {
            let x = $1.1.clamped(to: targetArea)
            let y = $1.2.clamped(to: targetArea)
            let z = $1.3.clamped(to: targetArea)

            var iterator = InfiniteGrid3D<Bool>.CoordinateIterator(
                minX: x.lowerBound,
                maxX: x.upperBound,
                minY: y.lowerBound,
                maxY: y.upperBound,
                minZ: z.lowerBound,
                maxZ: z.upperBound,
                coordinate: .init(x: x.lowerBound, y: y.lowerBound, z: z.lowerBound)
            )

            while let next = iterator.next() {
                if $0.1[next], !$1.0 { $0.0 -= 1 }
                if !$0.1[next], $1.0 { $0.0 += 1 }

                
                $0.1[next] = $1.0
            }
        }
        
        print("Part 1", count)
    }
    
    func part2() {
        let lightsOn = Self.input.map {
            Cube(
                state: $0.0,
                lowerBound: .init(x: $0.1.lowerBound,
                                  y: $0.2.lowerBound,
                                  z: $0.3.lowerBound),
                upperBound: .init(x: $0.1.upperBound,
                                  y: $0.2.upperBound,
                                  z: $0.3.upperBound)
            )
        }
            .reduce(into: (0, [Cube]())) { result, cube in
                if cube.state {
                    result.0 += cube.volume
                }
                
                result.0 -= result.1[...].volumeAlreadyTurnedOn(cube)
                result.1.append(cube)
            }
            .0
        
        print("Part 2", lightsOn)
    }
    
    func run() {
        part1()
        part2()
    }
}

fileprivate extension ArraySlice where Element == Cube {
    func volumeAlreadyTurnedOn(_ cube: Cube) -> Int {
        guard let last = last else { return 0 }
        
        if let intersection = cube.intersection(last) {
            return (
                // If we're intersecting with a volume that's already one, include it.
                (intersection.state ? intersection.volume : 0) -
                // But don't include the volume that will be returned by intersections with earlier commands.
                dropLast().volumeAlreadyTurnedOn(intersection) +
                // Recurse -- include the volume that intersects with earlier commands.
                dropLast().volumeAlreadyTurnedOn(cube)
            )
        }
        
        return dropLast().volumeAlreadyTurnedOn(cube)
    }
}

struct Cube {
    var state: Bool
    var lowerBound: Coordinate3D
    var upperBound: Coordinate3D
}

extension Cube {
    func overlaps(_ other: Cube) -> Bool {
        guard self.upperBound.x >= other.lowerBound.x,
              self.lowerBound.x <= other.upperBound.x,
              self.upperBound.y >= other.lowerBound.y,
              self.lowerBound.y <= other.upperBound.y,
              self.upperBound.z >= other.lowerBound.z,
              self.lowerBound.z <= other.upperBound.z
        else { return false }
        
        return true
    }
    
    func intersection(_ other: Cube) -> Cube? {
        guard overlaps(other) else {
            return nil
        }
        
        return Cube(
            state: other.state,
            lowerBound: .init(
                x: max(lowerBound.x, other.lowerBound.x),
                y: max(lowerBound.y, other.lowerBound.y),
                z: max(lowerBound.z, other.lowerBound.z)
            ),
            upperBound: .init(
                x: min(upperBound.x, other.upperBound.x),
                y: min(upperBound.y, other.upperBound.y),
                z: min(upperBound.z, other.upperBound.z)
            )
        )
    }
    
    var volume: Int {
        (upperBound.x - lowerBound.x + 1) *
        (upperBound.y - lowerBound.y + 1) *
        (upperBound.z - lowerBound.z + 1)
    }
}

extension Cube: CustomStringConvertible {
    var description: String {
        "[\(lowerBound) -> \(upperBound)]"
    }
}
