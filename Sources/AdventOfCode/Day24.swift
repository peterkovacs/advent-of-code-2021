
import Foundation 
import ArgumentParser
import Algorithms
import Parsing

struct Day24: ParsableCommand {
    static let parser = Many(
        StartsWith<Substring>("inp w\nmul x 0\nadd x z\nmod x 26\ndiv z ")
            .take(Int.parser())
            .skip("\nadd x ")
            .take(Int.parser())
            .skip("\neql x w\neql x 0\nmul y 0\nadd y 25\nmul y x\nadd y 1\nmul z y\nmul y 0\nadd y w\nadd y ")
            .take(Int.parser())
            .skip("\nmul y x\nadd z y\n")
    )
        
    static let input = parser.parse(stdin.joined(separator: "\n") + "\n")!

    func run() {
        print(Self.input)
    }
    
    static let p = [
        0: (1, 15, 4),
        1: (1, 14, 16),
        2: (1, 11, 14),
        3: (26, -13, 3),
        4: (1, 14, 11),
        5: (1, 15, 13),
        6: (26, -7, 11),
        7: (1, 10, 7),
        8: (26, -12, 12),
        9: (1, 15, 15),
        10: (26, -16, 13),
        11: (26, -9, 1),
        12: (26, -8, 15),
        13: (26, -8, 4)
    ]
    
//    static let q = [
//        0: (input[0] + 4),
//        1: 26 * (input[0] + 4) + (input[1] + 16),
//        2: 26 * (26 * (input[0] + 4) + (input[1] + 16)) + (input[2] + 14),
//        3: (input[2] + 1 == input[3]) ? 26 * (input[0] + 4) + (input[1] + 16) : fatalError(),
//        4: 26 * (26 * (input[0] + 4) + (input[1] + 16)) + (input[4] + 11),
//        5: 26 * (26 * (26 * (input[0] + 4) + (input[1] + 16)) + (input[4] + 11)) + (input[5] + 13),
//        6: (input[5] + 6 == input[6]) ? (26 * (26 * (input[0] + 4) + (input[1] + 16)) + (input[4] + 11)) : fatalError(),
//        7: 26 * (26 * (26 * (input[0] + 4) + (input[1] + 16)) + (input[4] + 11)) + (input[7] + 7),
//        8: input[7] - 5 == input[8] ? 26 * (26 * (input[0] + 4) + (input[1] + 16)) + (input[4] + 11) : fatalError()
//        9: 26 * (26 * (26 * (input[0] + 4) + (input[1] + 16)) + (input[4] + 11)) + (input[9] + 15),
//        10: input[9] - 1 == input[10] ? 26 * (26 * (input[0] + 4) + (input[1] + 16)) + (input[4] + 11) : fatalError(),
//        11: input[4] + 2 == input[11] ? 26 * (input[0] + 4) + (input[1] + 16) : fatalError(),
//        12: input[1] + 8 == input[12] ? input[0] + 4 : fatalError(),
//        13: input[0] - 4 == input[13]
//    ]
    static let largest = [ // 91897399498995
    9, // 0
    1, // 1
    8, // 2
    9, // 3
    7, // 4
    3, // 5
    9, // 6
    9, // 7
    4, // 8
    9, // 9
    8, // 10
    9, // 11
    9, // 12
    5  // 13
    ]
    
    static let smallest  = [ // 51121176121391
        5, // 0
        1, // 1
        1, // 2
        2, // 3
        1, // 4
        1, // 5
        7, // 6
        6, // 7
        1, // 8
        2, // 9
        1, // 10
        3, // 11
        9, // 12
        1  // 13
    ]

    /* RULES:
     (input[2] + 1 == input[3])
     (input[5] + 6 == input[6])
     (input[7] - 5 == input[8])
     (input[9] - 1 == input[10])
     (input[4] + 2 == input[11])
     (input[1] + 8 == input[12])
     (input[0] - 4 == input[13])
     */
}
