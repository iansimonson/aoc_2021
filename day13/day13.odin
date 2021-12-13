package main

import "core:os"
import "core:strings"
import "core:fmt"
import "core:strconv"
import "core:slice"
import "core:math"

main :: proc() {
    when #config(example, -1) == 0 {
        input := example_input
    } else {
        input, _ := os.read_entire_file("input")
    }

    lines := strings.split(string(input), "\n")
    coord_str, instructions := divide_input(lines)
    coords := slice.mapper(coord_str, parse_coord)

    fmt.println(part1(coords, instructions))
    part2(coords, instructions)
}

part1 :: proc(coords: []Point, instructions:[]string) -> int {
    max_p := max_point(coords)

    board := Board{
        board = make([dynamic]bool, (max_p.x + 1) * (max_p.y + 1)),
        row_width = max_p.x + 1,
        max_row = max_p.y + 1,
        max_col = max_p.x + 1,
    }
    for coord in coords {
        board.board[coord.y * board.row_width + coord.x] = true
    }

    instruction := instructions[0]
    pair := strings.split(instruction, "=")
    fold_row := pair[0][len(pair[0]) - 1] == 'y'
    row_col := strconv.atoi(pair[1])

    fold_along := Point{}
    if fold_row {
        fold_along.y = row_col
    } else {
        fold_along.x = row_col
    }
    // print_board(&board)
    fold(&board, fold_along)
    // print_board(&board)
    count := 0
    for i := 0; i < board.max_row * board.row_width; {
        if board.board[i] {
            count += 1
        }
        col := i % board.row_width
        if col == board.max_col - 1 {
            i += board.row_width - col
        } else {
            i += 1
        }
    }

    return count
}

part2 :: proc(coords: []Point, instructions:[]string) {
    max_p := max_point(coords)

    board := Board{
        board = make([dynamic]bool, (max_p.x + 1) * (max_p.y + 1)),
        row_width = max_p.x + 1,
        max_row = max_p.y + 1,
        max_col = max_p.x + 1,
    }
    for coord in coords {
        board.board[coord.y * board.row_width + coord.x] = true
    }

    for instruction in instructions {
        pair := strings.split(instruction, "=")
        fold_row := pair[0][len(pair[0]) - 1] == 'y'
        row_col := strconv.atoi(pair[1])

        fold_along := Point{}
        if fold_row {
            fold_along.y = row_col
        } else {
            fold_along.x = row_col
        }
        // print_board(&board)
        fold(&board, fold_along)
    }
    print_board(&board)
}

print_board :: proc(board: ^Board) {
    fmt.println("Board:")
    for i := 0; i < board.max_row * board.row_width; {
        if i % board.row_width == 0 {
            fmt.println()
        }
        to_print := '#' if board.board[i] else '.'
        fmt.print(to_print)
        
        col := i % board.row_width
        if col == board.max_col - 1 {
            i += board.row_width - col
        } else {
            i += 1
        }
    }
    fmt.println()
    fmt.println("Done")
}

fold :: proc(board: ^Board, fold_along: Point) {
    fold_row := fold_along.y != 0
    l_coord := fold_along.y if fold_row else fold_along.x
    max_y := board.max_row * board.row_width
    max_x := board.max_col

    if fold_row {
        line := l_coord * board.row_width
        // NOTE: technically we should also only iterate on the
        // half that is "active" but it doesn't actually matter
        for i := (l_coord + 1) * board.row_width; i < max_y; i += 1 {
            offset := (i - line) / board.row_width
            if board.board[i] {
                board.board[i - (2 * offset * board.row_width)] = true
            }
        }
        board.max_row = l_coord
    } else {
        line := l_coord
        for i := 0; i < max_y; {
            col := i % board.row_width
            if col > line {
                offset := col - line
                if board.board[i] {
                    board.board[i - 2 * offset] = true
                }
            }

            if col == board.max_col - 1 {
                i += board.row_width - col
            } else {
                i += 1
            }
        }
        board.max_col = l_coord
    }
}

Point :: [2]int

Board :: struct {
    board: [dynamic]bool,
    row_width: int,
    max_row, max_col: int,
}

parse_coord :: proc(coord: string) -> Point {
    coords := strings.split(coord, ",")
    result := Point{strconv.atoi(coords[0]), strconv.atoi(coords[1])}
    return result
}

divide_input :: proc(lines: []string) -> ([]string, []string) {
    for line, i in lines {
        if len(line) == 0 {
            return lines[0:i], lines[i+1:]
        }
    }
    return lines, nil
}

max_point :: proc(coords: []Point) -> Point {
    result: Point
    for coord in coords {
        result.x = max(result.x, coord.x)
        result.y = max(result.y, coord.y)
    }
    return result
}

example_input :=`6,10
0,14
9,10
0,3
10,4
4,11
6,0
6,12
4,1
0,13
10,12
3,4
3,0
8,4
1,10
2,14
8,10
9,0

fold along y=7
fold along x=5`