package main

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:os"
import "core:sort"

main :: proc() {
    input, success := os.read_entire_file("input");
    if !success {
        return;
    }
    defer delete(input)

    fmt.println(part1(strings.clone(string(input))))
    fmt.println(part2(strings.clone(string(input))))
}

part1 :: proc(input: string) -> int {
    defer delete(input)
    lines := strings.split(string(input), "\n")
    defer delete(lines)

    previous, err := strconv.parse_int(lines[0])
    assert(err)
    count := 0
    for line in lines[1:] {
        depth, ok := strconv.parse_int(line) 
        if !ok {
            panic(line)
        }
        if depth > previous {
            count += 1
        }
        previous = depth
    }
    return count
}

Window :: distinct [3]int

sum :: proc(window: Window) -> int {
    return window.x + window.y + window.z
}

part2 :: proc(input: string) -> int {
    defer delete(input)
    lines := strings.split(string(input), "\n")
    defer delete(lines)

    v1, v1_ok := strconv.parse_int(lines[0])
    assert(v1_ok)
    v2, v2_ok := strconv.parse_int(lines[1])
    assert(v2_ok)
    v3, v3_ok := strconv.parse_int(lines[2])
    window := Window{v1, v2, v3}
    count := 0
    for line in lines[3:] {
        depth, ok := strconv.parse_int(line) 
        assert(ok)

        prev_sum := sum(window)
        window.xyz = window.yzx
        window.z = depth
        new_sum := sum(window)
        if new_sum > prev_sum {
            count += 1
        }
    }
    return count
}