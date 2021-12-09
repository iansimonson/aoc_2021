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
    defer delete(numbers)


    fmt.println(part1(numbers, 80))
    fmt.println(part1(numbers, 256)) // part 2 was just part 1 with a larger number
}

part1 :: proc(numbers: []int, days: int) -> int {
    fish: Fish
    for n in numbers {
        fish[n] += 1
    }

    for i := days; i >= 0; i -= 1 {
        zero_fish := fish[0]
        copy(fish[0:8], fish[1:9])
        fish[6] += zero_fish
        fish[8] = zero_fish
    }

    return math.sum(fish[0:8])
}