
import Foundation 
import ArgumentParser
import Algorithms
import Parsing

// the first three bits encode the packet version,
// the next three bits encode the packet type ID
// all numbers encoded in any packet are represented as binary with the most significant bit first
// Packets with type ID 4 represent a literal value:
//  The binary number is padded with leading zeroes until its length is a multiple of four bits,
//  and then it is broken into groups of four bits. Each group is prefixed by a 1 bit except the
//  last group, which is prefixed by a 0 bit. These groups of five bits immediately follow the
//  packet header.

// D2FE28 -> 110100101111111000101000
//           VVVTTTAAAAABBBBBCCCCC

fileprivate extension Packet {
    var sumOfVersion: Int {
        switch self {
        case .literal(version: let v, value: _): return v
        case .sum(version: let version, op: let op),
                .product(version: let version, op: let op),
                .minimum(version: let version, op: let op),
                .maximum(version: let version, op: let op):
            return op.reduce(into: version) { $0 += $1.sumOfVersion }
        case .greaterThan(version: let version, lhs: let lhs, rhs: let rhs),
                .lessThan(version: let version, lhs: let lhs, rhs: let rhs),
                .equalTo(version: let version, lhs: let lhs, rhs: let rhs):
            return version + lhs.sumOfVersion + rhs.sumOfVersion
        }
    }
}

struct Day16: ParsableCommand {
    static let packet = Packet(hexadecimal: stdin.joined())!
    func run() {
        print("Part 1", Self.packet.sumOfVersion)
        print("Part 2", Self.packet.value)
    }
}
