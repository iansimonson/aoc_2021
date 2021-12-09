package main

import "core:os"
import "core:strings"
import "core:fmt"
import "core:strconv"
import "core:slice"
import "core:math"

Fish :: [10]int

main :: proc() {
	input, _ := os.read_entire_file("input")

    numbers :=  slice.mapper(strings.split(string(input), ","), strconv.atoi)

    fmt.println(part1(numbers))
    fmt.println(part2(numbers))
}

// doing this a crap way because I'm just trying to catch up
part1 :: proc(numbers: []int) -> int {
    max_pos := slice.max(numbers) or_else 0
    fuel := make([dynamic]int, max_pos + 1)

    for n in numbers {
        for f, i in &fuel {
            f += abs(n - i)
        }
    }

    res := slice.min(fuel[:]) or_else 0
    return res
}

part2 :: proc(numbers: []int) -> int {
    max_pos := slice.max(numbers) or_else 0
    fuel := make([dynamic]int, max_pos + 1)

    for n in numbers {
        for f, i in &fuel {
            sum := 0
            for i in 0..abs(n-i) {
                sum += i
            }
            f += sum
        }
    }

    res := slice.min(fuel[:]) or_else 0
    return res
}