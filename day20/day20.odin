package main

import "core:os"
import "core:strings"
import "core:fmt"
import "core:strconv"
import "core:slice"
import "core:math"

example :: #config(example, -1)

main :: proc() {
    when example == 0 {
        input := example_input
    } else {
        input, _ := os.read_entire_file("input")
    }

    lines := strings.split(string(input), "\n")
    algo := lines[0]
    pic := lines[2:]
    fmt.println(solve(algo, pic, 2))
    fmt.println(solve(algo, pic, 50))
}

solve :: proc(algo: string, pic: []string, steps: int) -> int {
    row_width := len(pic[0])
    height := len(pic)
    picture := next_canvas(row_width, height, 0)
    for r, h in pic {
        for c, w in r {
            picture[h+1][w+1] = u8(c)
        }
    }

    for step := 1; step <= steps; step += 1 {
        width, height := len(picture[0]), len(picture)
        expanded, next := next_canvas(width, height, step - 1), next_canvas(width, height, step)
        for r, h in &picture {
            for c, w in &r {
                expanded[h+1][w+1] = c
            }
        }
        for r := 1; r < len(expanded) - 1; r += 1 {
            for c := 1; c < len(expanded[0]) - 1; c += 1 {
                idx := lookup(expanded[:], r, c)
                next[r][c] = u8(algo[idx])
            }
        }
        picture = next
    }

    count := 0
    for r in picture {
        for c in r {
            // fmt.print(rune(c))
            if c == u8('#') {
                count += 1
            }
        }
        // fmt.println()
    }
    return count
}

lookup :: proc(pic: [][dynamic]u8, r, c: int) -> int {
    offsets := [9][2]int{
        {-1, -1}, {0, -1}, {1, -1},
        {-1, 0}, {0, 0}, {1, 0},
        {-1, 1}, {0, 1}, {1, 1},
    }

    bin := strings.make_builder()
    for o in offsets {
        strings.write_byte(&bin, '1' if pic[r + o.y][c + o.x] == u8('#') else u8('0'))
    }
    value, _ := strconv.parse_int(strings.to_string(bin), 2)
    return value
}

Picture :: [dynamic][dynamic]u8

next_canvas :: proc(width, height, step: int) -> Picture {
    picture := make([dynamic][dynamic]u8, height + 2)
    for p in &picture {
        p = make([dynamic]u8, width + 2)
        for c in &p {
            when example == 0 {
                char := u8('.')
            } else {
                char := u8('.') if step % 2 == 0 else '#'
            }
            c = char
        }
    }
    return picture
}

example_input := `..#.#..#####.#.#.#.###.##.....###.##.#..###.####..#####..#....#..#..##..###..######.###...####..#..#####..##..#.#####...##.#.#..#.##..#.#......#.###.######.###.####...#.##.##..#..#..#####.....#.#....###..#.##......#.....#..#..#..##..#...##.######.####.####.#.#...#.......#..#.#.#...####.##.#......#..#...##.#.##..#...##.#.##..###.#......#.#.......#.#.#.####.###.##...#.....####.#..#..#.##.#....##..#.####....##...##..#...#......#.#.......#.......##..####..#...#.#.#...##..#.#..###..#####........#..####......#..#

#..#.
#....
##..#
..#..
..###`