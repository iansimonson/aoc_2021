package main

import "core:os"
import "core:strings"
import "core:fmt"
import "core:strconv"
import "core:slice"
import "core:math/linalg"


Point :: distinct [2]int
Segment :: struct {
    t0,t1: Point,
}

main :: proc() {
	input, _ := os.read_entire_file("input")

    lines := strings.split(string(input), "\n")
    segments := make([dynamic]Segment)
    defer delete(segments)

    for line in lines {
        if len(line) == 0 { continue }
        segment := process_segment(line)
        append(&segments, segment)
    }

    max_point := Point{}
    for segment in segments {
        max_point.x = max(max_point.x, segment.t0.x, segment.t1.x)
        max_point.y = max(max_point.y, segment.t0.y, segment.t1.y)
    }
    


    fmt.println(part1(segments[:], max_point))
    fmt.println(part2(segments[:], max_point))
}

part1 :: proc(segments: []Segment, max_point: Point) -> int {
    board := make([dynamic]int, (max_point.x + 1) * (max_point.y + 1))

    for segment in segments {
        if segment.t0.x == segment.t1.x {
            start,end := min(segment.t0.y, segment.t1.y), max(segment.t0.y, segment.t1.y)
            for i in start..end {
                board[i * (max_point.x + 1) + segment.t0.x] += 1
            }
        } else if segment.t0.y == segment.t1.y {
            start,end := min(segment.t0.x, segment.t1.x), max(segment.t0.x, segment.t1.x)
            for i in start..end {
                board[segment.t0.y * (max_point.x + 1) + i] += 1
            }
        }
    }
    // for v, i in board {
    //     if i % (max_point.x + 1) == 0 {
    //         fmt.println()
    //     }
    //     fmt.print(v, " ")
    // }
    // fmt.println()

    count := slice.reduce(board[:], 0, g2)

    return count
}

part2 :: proc(segments: []Segment, max_point: Point) -> int {
    board := make([dynamic]int, (max_point.x + 1) * (max_point.y + 1))
    
    for segment in segments {
        start_y, end_y := min(segment.t0.y, segment.t1.y), max(segment.t0.y, segment.t1.y)
        start_x, end_x := min(segment.t0.x, segment.t1.x), max(segment.t0.x, segment.t1.x)
        if start_x == end_x {
            for ;start_y <= end_y; start_y += 1 {
                board[start_y * (max_point.x+1) + start_x] += 1
            }
        } else if start_y == end_y {
            for ;start_x <= end_x; start_x += 1 {
                board[start_y * (max_point.x+1) + start_x] += 1
            }
        } else {
            stride_x := -1 if segment.t0.x > segment.t1.x else 1
            stride_y := -1 if segment.t0.y > segment.t1.y else 1
            start_y, end_y = segment.t0.y, segment.t1.y
            start_x, end_x = segment.t0.x, segment.t1.x
            for {
                board[start_y * (max_point.x+1) + start_x] += 1
                if start_x == end_x && start_y == end_y { break }
                start_y += stride_y
                start_x += stride_x
            }
        }
    }
    // for v, i in board {
    //     if i % (max_point.x + 1) == 0 {
    //         fmt.println()
    //     }
    //     fmt.print(v)
    // }
    // fmt.println()

    count := slice.reduce(board[:], 0, g2)

    return count
}

g2 :: proc(sum, val: int) -> int {
    if val >= 2 {
        return sum + 1
    } else {
        return sum
    }
}

process_segment :: proc(line: string) -> Segment {
    points := strings.split(line, "->")
    segment: Segment
    p1 := strings.split(points[0], ",")
    segment.t0.x = strconv.atoi(strings.trim_space(p1[0]))
    segment.t0.y = strconv.atoi(strings.trim_space(p1[1]))
    p2 := strings.split(points[1], ",")
    segment.t1.x = strconv.atoi(strings.trim_space(p2[0]))
    segment.t1.y = strconv.atoi(strings.trim_space(p2[1]))
    return segment
}