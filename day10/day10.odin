package main

import "core:os"
import "core:strings"
import "core:fmt"
import "core:strconv"
import "core:slice"
import "core:math"

score_lookup := map[rune]int {
    ')' = 3,
    ']' = 57,
    '}' = 1197,
    '>' = 25137,
}

incomplete_lookup := map[rune]int {
    ')' = 1,
    ']' = 2,
    '}' = 3,
    '>' = 4,
}

// lookup open char given close char
open_lookup := map[rune]rune {
    ')' = '(',
    ']' = '[',
    '}' = '{',
    '>' = '<',
}

// lookup close char given open char
close_lookup := map[rune]rune {
    '(' = ')',
    '[' = ']',
    '{' = '}',
    '<' = '>',
}

main :: proc() {
	input, _ := os.read_entire_file("input")

    lines := strings.split(string(input), "\n")

    fmt.println(part1(lines))
    fmt.println(part2(lines))

}

opens_chunk :: proc(char: rune) -> bool {
    return char == '(' || char == '{' || char == '[' || char == '<'
}
closes_chunk :: proc(char: rune) -> bool {
    return char == ')' || char == ']' || char == '}' || char == '>'
}

part1 :: proc(lines: []string) -> int {

    stack := make([dynamic]rune, 0, 100)
    sum := 0
    outer: for line in lines {
        for c in line {
            if opens_chunk(c) {
                append(&stack, c)
            } else if closes_chunk(c) {
                if stack[len(stack) - 1] != open_lookup[c] {
                    sum += score_lookup[c]
                    continue outer
                } else {
                    pop(&stack)
                }
            } else {
                fmt.panicf("unknown symbol: %v", c)
            }
        }
    }

    return sum
}

part2 :: proc(lines: []string) -> int {
    stack := make([dynamic]rune, 0, 100)
    scores := make([dynamic]int, 0, 100)

    score_line :: proc(stack: ^[dynamic]rune) -> int {
        score := 0
        for ;len(stack) > 0; {
            score *= 5
            score += incomplete_lookup[close_lookup[stack[len(stack) - 1]]]
            pop(stack)
        }
        return score
    }
    outer: for line in lines {
        clear(&stack)
        for c in line {
            if opens_chunk(c) {
                append(&stack, c)
            } else if closes_chunk(c) {
                if stack[len(stack) - 1] != open_lookup[c] {
                    continue outer // invalid line - discarding
                } else {
                    pop(&stack)
                }
            } else {
                fmt.panicf("unknown symbol %v", c)
            }
        }
        if score := score_line(&stack); score != 0 {
            append(&scores, score)
        }
    }
    slice.sort(scores[:])
    return scores[len(scores) / 2]
}