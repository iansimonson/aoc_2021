package main
import "core:strings"
import "core:fmt"
import "core:strconv"
import "core:os"
example :: #config(example, -1)

main :: proc() {
    when example == 0 {
        input := example_input
    } else {
        input, _ := os.read_entire_file("input")
    }

    lines := strings.split(string(input), "\n")
    p1_strs, p2_strs := strings.split(lines[0], " "), strings.split(lines[1], " ")
    p1 := strconv.atoi(strings.trim_space(p1_strs[len(p1_strs)-1])) - 1
    p2 := strconv.atoi(strings.trim_space(p2_strs[len(p2_strs)-1])) - 1
    if p1 < 0 {
        p1 = p1 + 10
    }
    if p2 < 0 {
        p2 = p2 + 10
    }

    fmt.println(part1(p1, p2))
    fmt.println(part2(p1, p2))
}

part1 :: proc(p1, p2: int) -> int {
    fmt.println("start: ", p1, p2)
    p1, p2 := p1, p2
    die: int
    rolls: int
    p1_score, p2_score: int
    turn := true
    for p1_score < 1000 && p2_score < 1000 {
        roll := die + (die + 1) % 1000 + (die + 2) % 1000 + 3 // offset
        if turn {
            p1 = (p1 + roll) % 10
            p1_score += p1 + 1
        } else {
            p2 = (p2 + roll) % 10
            p2_score += p2 + 1
        }
        turn = !turn
        die = (die + 3) % 1000
        rolls += 3
    }

    fmt.println("scores:", p1_score, p2_score, rolls)

    return min(p1_score, p2_score) * rolls
}

part2 :: proc(p1, p2: int) -> int {
    p1, p2 := p1, p2
    die: int
    rolls: int
    p1_score, p2_score: int
    turn := true

    cache := make(map[State]int)
    return count_dfs(p1, p2, p1_score, p2_score, 0, 0, true, &cache)
}

State :: struct {
    p1, p2, p1_score, p2_score: int,
    total_die, rolls: int,
    turn: bool,
}

count_dfs :: proc(p1, p2, p1_score, p2_score, total_die, rolls: int, turn: bool, cache: ^map[State]int) -> int {
    state := State{p1, p2, p1_score, p2_score, total_die, rolls, turn}
    if state in cache {
        return cache[state]
    }

    if rolls == 3 { 
        if turn {
            p1, p1_score := p1, p1_score
            p1 = (p1 + total_die) % 10
            p1_score = p1_score + (p1 + 1)
            if p1_score >= 21 {
                cache[state] = 1
                return 1
            }
            return count_dfs(p1, p2, p1_score, p2_score, 0, 0, !turn, cache)
        } else {
            p2, p2_score := p2, p2_score
            p2 = (p2 + total_die) % 10
            p2_score = p2_score + (p2 + 1)
            if p2_score >= 21 {
                cache[state] = 0
                return 0
            }
            return count_dfs(p1, p2, p1_score, p2_score, 0, 0, !turn, cache)
        }
    } else {
        count := 0
        for i in 1..3 {
            count += count_dfs(p1, p2, p1_score, p2_score, total_die + i, rolls + 1, turn, cache)
        }
        cache[state] = count
        return count
    }

}

example_input := `Player 1 starting position: 4
Player 2 starting position: 8`