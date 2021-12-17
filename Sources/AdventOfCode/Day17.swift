
import Foundation 
import ArgumentParser
import Algorithms

struct Day17: ParsableCommand {
    static let target = (x: 281...311, y: (-74)...(-54))
    
    func hitsTarget(x0: Int, y0: Int, 𝚫x: Int, 𝚫y: Int) -> Int? {
        if Self.target.x.contains(x0) && Self.target.y.contains(y0) { return y0 }
        guard y0 > Self.target.y.lowerBound && x0 < Self.target.x.upperBound else { return nil }
        
        if let yt = hitsTarget(x0: x0 + 𝚫x, y0: y0 + 𝚫y, 𝚫x: max(𝚫x - 1, 0), 𝚫y: 𝚫y - 1) {
            if y0 > yt { return y0 }
            else { return yt }
        }
        
        return nil
    }
    
    func run() {
        let velocities = product(1...1000, -1000...1000).compactMap { hitsTarget(x0: 0, y0: 0, 𝚫x: $0, 𝚫y:$1) }
        print("Part 1", velocities.max() as Any)
        print("Part 2", velocities.count)
    }
}
