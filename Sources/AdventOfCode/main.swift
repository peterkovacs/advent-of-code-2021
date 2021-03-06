import ArgumentParser

var stdin = AnyIterator { readLine() }

struct AdventOfCode: ParsableCommand {
  static var configuration: CommandConfiguration = .init(
    abstract: "AdventOfCode 2021", 
    subcommands: [
        Day1.self, Day2.self, Day3.self, Day4.self, Day5.self, Day6.self, Day7.self, Day8.self, Day9.self,
        Day10.self, Day11.self, Day12.self, Day13.self, Day14.self, Day15.self, Day16.self, Day17.self, Day18.self, Day19.self,
        Day20.self, Day21.self, Day22.self, Day23.self, Day24.self, Day25.self
    ]
  )
}

AdventOfCode.main()
