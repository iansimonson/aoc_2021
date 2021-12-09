package main

import "core:os"
import "core:strings"
import "core:fmt"
import "core:strconv"
import "core:slice"
import "core:math"


main :: proc() {
	input, _ := os.read_entire_file("input")

    lines := strings.split(string(input), "\n")

    rows, cols := len(lines), len(lines[0])
    row_width := cols + 2
    floor := make([dynamic]int, (rows + 2) * (cols + 2))
    slice.fill(floor[:], 9) // highest value is 9

    for line,i in lines {
        for v, j in line {
            value := int(v - '0')
            floor[(i + 1) * row_width + (j + 1)] = value
        }
    }

    fmt.println(part1(floor[:], rows, cols))
    fmt.println(part2(floor[:], rows, cols))

}

part1 :: proc(floor: []int, rows, cols: int) -> int {
    row_width := cols + 2

    risk_level := 0
    for i := 1; i < rows + 1; i += 1 {
        for j := 1; j < cols + 1; j += 1 {
            idx := (i * row_width) + j
            v := floor[idx]
            a, b, c, d := neighbors(floor, row_width, idx)
            if is_low_point(v, a, b, c, d) {
                risk_level += v + 1
            }
        }
    }
    return risk_level
}

part2 :: proc(floor: []int, rows, cols: int) -> int {

    largest_basins := [3]int{0, 0, 0}
    row_width := cols + 2

    visited := make([dynamic]int) // indices visited
    for i := 1; i < rows + 1; i += 1 {
        for j := 1; j < cols + 1; j += 1 {
            idx := (i * row_width) + j
            v := floor[idx]
            a, b, c, d := neighbors(floor, row_width, idx)
            if is_low_point(v, a, b, c, d) {
                clear(&visited)
                size := basin_size(floor, rows, cols, idx, &visited)
                if size >= largest_basins.x {
                    largest_basins.yzx = largest_basins.xyz
                    largest_basins.x = size
                } else if size >= largest_basins.y {
                    largest_basins.z = largest_basins.y
                    largest_basins.y = size
                } else if size > largest_basins.z {
                    largest_basins.z = size
                }
            }
        }
    }

    return largest_basins.x * largest_basins.y * largest_basins.z
}

basin_size :: proc(floor: []int, rows, cols, idx: int, visited: ^[dynamic]int) -> int {
    append(visited, idx)
    if floor[idx] == 9 { return 0 }

    basin_size_for :: proc(floor: []int, rows, cols, idx: int, visited: ^[dynamic]int) -> int {
        if _, found := slice.linear_search(visited[:], idx); !found {
            return basin_size(floor, rows, cols, idx, visited)
        } else {
            return 0
        }
    }

    size := 1

    n1, n2, n3, n4 := idx - 1, idx + 1, idx - (cols + 2), idx + (cols + 2)

    size += basin_size_for(floor, rows, cols, n1, visited)
    size += basin_size_for(floor, rows, cols, n2, visited)
    size += basin_size_for(floor, rows, cols, n3, visited)
    size += basin_size_for(floor, rows, cols, n4, visited)

    return size
}

is_low_point :: proc(v, a, b, c, d: int) -> bool {
    return v < a && v < b && v < c && v < d
}

neighbors :: proc(floor: []int, row_width, idx: int) -> (int, int, int, int) {
    return floor[idx - 1], floor[idx + 1], floor[idx - row_width], floor[idx + row_width]
}