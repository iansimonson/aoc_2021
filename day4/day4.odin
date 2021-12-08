package main

import "core:os"
import "core:strings"
import "core:fmt"
import "core:strconv"
import "core:slice"
import "core:math/linalg"

Board :: [5][5]int
check_vector :: [5]int{-5, -5, -5, -5, -5}

main :: proc() {
	input, _ := os.read_entire_file("input")

    lines := strings.split(string(input), "\n")

    number_str := strings.split(lines[0], ",")
    numbers := slice.mapper(number_str, strconv.atoi)

    boards := parse_boards(lines[1:])

    fmt.println(part1(numbers[:], boards[:]))
    fmt.println(part2(numbers[:], &boards))
    
}

part1 :: proc(numbers: []int, b: []Board) -> int {
    boards := b
    for number in numbers {
        for board in &boards {
            mark(&board, number)
            if is_winning(board) {
                return score(board) * number
            }
        }
    }
    return -1
}

part2 :: proc(numbers: []int, boards: ^[dynamic]Board) -> int {
    for number in numbers {
        for i := 0; i < len(boards); {
            mark(&boards[i], number)
            if is_winning(boards[i]) {
                if len(boards) == 1 {
                    return score(boards[0]) * number
                }
                unordered_remove(boards, i)
            } else {
                i += 1
            }
        }
    }
    return -1
}

mark :: proc(board: ^Board, value: int) {
    for i in 0..<5 {
        for j in 0..<5 {
            if board[i][j] == value {
                board[i][j] = -1
                return // based on bingo rules we know values are unique to a board
            }
        }
    }
}

score :: proc(board: Board) -> int {
    sum := 0
    for row in board {
        for col in row {
            if col != -1 {
                sum += col
            }
        }
    }
    return sum
}

is_winning :: proc(board: Board) -> bool {
    all_neg :: proc(vec: [5]int) -> bool {
        for v in vec {
            if v > 0 {
                return false
            }
        }
        return true
    }

    for i in 0..<5 {
        row := board[i]
        if all_neg(row) {
            return true
        }
    }

    for j in 0..<5 {
        col: [5]int
        for i in 0..<5 {
            col[i] = board[i][j]
        }
        if all_neg(col) {
            return true
        }
    }
    return false
}

is_not_empty :: proc(s: string) -> bool {
    return len(s) != 0
}

parse_boards :: proc(lines: []string) -> [dynamic]Board {
    parse_board :: proc(lines: []string) -> Board {
        board: Board
        row: int
        for line in lines {
            if len(line) == 0 {
                assert(row == 5)
                break
            }
            values := slice.mapper(slice.filter(strings.split(line, " "), is_not_empty), strconv.atoi)
            for v, i in values {
                board[row][i] = v
            }
            row += 1
        }
        return board
    }

    boards := make([dynamic]Board)
    for start := 0; start < len(lines); {
        if len(lines[start]) != 0 {
            board := parse_board(lines[start:])
            append(&boards, board)
            start += 5
        } else {
            start += 1
        }
    }

    return boards
}