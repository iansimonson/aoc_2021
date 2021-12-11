package main

import "core:os"
import "core:strings"
import "core:fmt"
import "core:strconv"
import "core:slice"
import "core:math"

rows :: 10
cols :: 10
cavern_size :: 12
Cavern :: [cavern_size * cavern_size]int
full_size :: cavern_size * cavern_size

cave: Cavern

main :: proc() {
    input, _ := os.read_entire_file("input")

    lines := strings.split(string(input), "\n")
    cave = parse_cavern(lines)
    fmt.println(part1(&cave))
    fmt.println(part2(&cave))

}

part1 :: proc(c: ^Cavern) -> int {
    cave := c^ // clone
    count_flashes := 0
    for i in 0..<100 {
        step(&cave)
        for c in &cave {
            if c >= 10 {
                c = 0
                count_flashes += 1
            }
        }
    }
    return count_flashes
}

part2 :: proc(c: ^Cavern) -> int {
    cave := c^
    simulate: for count := 1;; count += 1 {
        step(&cave)
        for i in 1..rows {
            for j in 1..cols {
                if cave[i * cavern_size + j] < 10 {
                    for v in &cave {
                        if v >= 10 {
                            v = 0
                        }
                    }
                    continue simulate
                }
            }
        }
        return count
    }
}

parse_cavern :: proc(lines: []string) -> (result: Cavern) {
    for oct in &result {
        oct = min(int)
    }

    for line, i in lines {
        row := i + 1
        numbers := slice.mapper(strings.split(line, ""), strconv.atoi)
        for n, j in numbers {
            col := j + 1
            result[row * cavern_size + col] = n
        }
    }

    return
}

neighbor_indices :: proc(index: int) -> [8]int {
    result := [8]int{
        index - cavern_size - 1,
        index - cavern_size,
        index - cavern_size + 1,
        index - 1,
        index + 1,
        index + cavern_size - 1,
        index + cavern_size,
        index + cavern_size + 1,
    }
    return result
}

step :: proc(cave: ^Cavern) {
    for octopus in cave {
        octopus += 1
    }
    visited: [full_size]bool

    for octopus, i in cave {
        if octopus >= 10 && !visited[i] {
            visited[i] = true
            flash(cave, &visited, i)
        }
    }
}

flash :: proc(cave: ^Cavern, visited: ^[full_size]bool, idx: int) {
    neighbors := neighbor_indices(idx)
    for n in neighbors {
        cave[n] += 1
        if cave[n] >= 10 && !visited[n] {
            visited[n] = true
            flash(cave, visited, n)
        }
    }
}