//
//  File.swift
//  
//
//  Created by Peter Kovacs on 12/16/21.
//

import Foundation
import Parsing


fileprivate extension Int {
    static func binary(length: Int) -> Parsers.Map<Prefix<Substring>, Int> {
        return Prefix<Substring>(
            minLength: length, maxLength: length, while: { $0 == "0" || $0 == "1" }
        )
            .map { Int($0, radix: 2)! }
    }
}

enum Packet {
    case literal(version: Int, value: Int)
    indirect case sum(version: Int, op: [Packet])
    indirect case product(version: Int, op: [Packet])
    indirect case minimum(version: Int, op: [Packet])
    indirect case maximum(version: Int, op: [Packet])
    indirect case greaterThan(version: Int, lhs: Packet, rhs: Packet)
    indirect case lessThan(version: Int, lhs: Packet, rhs: Packet)
    indirect case equalTo(version: Int, lhs: Packet, rhs: Packet)
    
    var value: Int {
        switch self {
        case .literal(version: _, value: let value): return value
        case .sum(version: _, op: let op): return op.reduce(into: 0) { $0 += $1.value }
        case .product(version: _, op: let op): return op.reduce(into: 1) { $0 *= $1.value }
        case .minimum(version: _, op: let op): return op.map(\.value).min()!
        case .maximum(version: _, op: let op): return op.map(\.value).max()!
        case .greaterThan(version: _, lhs: let lhs, rhs: let rhs):
            return lhs.value > rhs.value ? 1 : 0
        case .lessThan(version: _, lhs: let lhs, rhs: let rhs):
            return lhs.value < rhs.value ? 1 : 0
        case .equalTo(version: _, lhs: let lhs, rhs: let rhs):
            return lhs.value == rhs.value ? 1 : 0
        }
    }

    static let literal = Many(
        StartsWith<Substring>("1").take( Int.binary(length: 4) ).eraseToAnyParser(),
        into: 0,
        { $0 = ($0 << 4) + $1 }
    )
        .skip("0")
        .take( Int.binary(length: 4) )
        .map { a, b in
            a << 4 + b
        }
        .eraseToAnyParser()
    
    static let numberOfPackets = Int.binary(length: 1).flatMap { lengthTypeID -> AnyParser<Substring, (Int, Int)> in
        switch lengthTypeID {
        case 0:
            return Int.binary(length: 15).map { (0, $0) }.eraseToAnyParser()
        case 1:
            return Int.binary(length: 11).map { (1, $0) }.eraseToAnyParser()
        default: fatalError()
        }
    }
    
    static func `operator`(length: Int) -> AnyParser<Substring, [Packet]> {
        return AnyParser { input in
            guard let result = Many( parser ).skip(End()).parse(input.prefix(length)) else { return nil }
            input = input.dropFirst(length)
            return result
        }
    }
    
    static func `operator`(count: Int) -> AnyParser<Substring, [Packet]> {
        Many( parser, atLeast: count, atMost: count ).eraseToAnyParser()
    }

    static let parser = Int.binary(length: 3)
            .take(
                Int.binary(length: 3)
            )
            .flatMap { (version, type) -> AnyParser<Substring, Packet> in
                switch type {
                case 4: // literal
                    return literal.map { Packet.literal(version: version, value: $0) }.eraseToAnyParser()
                default:
                    return numberOfPackets.flatMap { lengthType, n -> AnyParser<Substring, [Packet]> in
                        switch lengthType {
                        case 0: // total length in bits of subpackets.
                            return `operator`(length: n)
                        case 1: // number of sub-packets immediately contained by this packet.
                            return `operator`(count: n)
                        default: fatalError()
                        }
                    }
                    .map { packets -> Packet in
                        switch type {
                        case 0: return .sum(version: version, op: packets)
                        case 1: return .product(version: version, op: packets)
                        case 2: return .minimum(version: version, op: packets)
                        case 3: return .maximum(version: version, op: packets)
                        case 5: return .greaterThan(version: version, lhs: packets[0], rhs: packets[1])
                        case 6: return .lessThan(version: version, lhs: packets[0], rhs: packets[1])
                        case 7: return .equalTo(version: version, lhs: packets[0], rhs: packets[1])
                        default: fatalError()
                        }
                    }
                    .eraseToAnyParser()
                }
            }
            .eraseToAnyParser()
}

fileprivate extension String {
    func leftPadding<T: StringProtocol>(toLength: Int, withPad: T) -> Self {
        guard toLength > count else { return self }
        return "".padding(toLength: toLength - count, withPad: withPad, startingAt: 0) + self
    }
}

extension Packet {
    init?(hexadecimal: String) {
        let str = hexadecimal.map {
            String(Int(String($0), radix: 16)!, radix: 2).leftPadding(toLength: 4, withPad: "0")
        }
            .joined()
        
        guard let value = Packet.parser.parse(str) else { return nil }
        self = value
    }
}
