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

    fmt.println(part1(lines))
    fmt.println(part2(lines))
}

Pair :: [2]u8
SwapBuffer :: struct {
    a, b: [dynamic]u8,
    a_b: bool,
}

/*
No way this works for part 2, seems like maybe it can be
lanternfish-esque?
*/
part1 :: proc(lines: []string) -> int {
    chain: SwapBuffer
    chain.a = make([dynamic]u8)
    chain.b = make([dynamic]u8)
    
    lookup := make(map[Pair]u8)

    for c in lines[0] {
        append(&chain.a, u8(c))
    }

    // skip blank line
    for line in lines[2:] {
        mapping := strings.split(line, "->")
        trimmed := strings.trim_space(mapping[0])
        lookup[Pair{trimmed[0], trimmed[1]}] = strings.trim_space(mapping[1])[0]
    }

    fmt.println(chain)
    fmt.println(lookup)

    for i := 0; i < 10; i += 1 {
        from := &chain.a if !chain.a_b else &chain.b
        to := &chain.b if !chain.a_b else &chain.a

        for c in from {
            if len(to) == 0 {
                append(to, c)
                continue
            }

            insert := lookup[Pair{to[len(to) - 1], c}]
            append(to, insert, c)
        }
        chain.a_b = !chain.a_b
        clear(from)
    }

    frequencies := make(map[u8]int)
    list := &chain.a if !chain.a_b else &chain.b
    for c in list {
        frequencies[c] += 1
    }
    mx := 0
    mn := max(int)
    for _, v in frequencies {
        mx = max(mx, v)
        mn = min(mn, v)
    }
    return mx - mn

}

part2 :: proc(lines: []string) -> int {
    frequencies := make(map[Pair]int) // pairs
    per_frequency := make(map[u8]int) // per letter
    lookup := make(map[Pair]u8)

    init := lines[0]
    previous := u8(init[0])
    per_frequency[previous] = 1
    for c in init[1:] {
        frequencies[Pair{previous, u8(c)}] += 1
        per_frequency[u8(c)] += 1
        previous = u8(c)
    }
    
    // skip blank line
    for line in lines[2:] {
        mapping := strings.split(line, "->")
        trimmed := strings.trim_space(mapping[0])
        lookup[Pair{trimmed[0], trimmed[1]}] = strings.trim_space(mapping[1])[0]
    }

    for i := 0; i < 40; i += 1 {
        next := make(map[Pair]int)
        defer delete(next)
        for k, v in frequencies {
            in_between := lookup[k]
            per_frequency[in_between] += v
            next[Pair{k[0], in_between}] += v
            next[Pair{in_between, k[1]}] += v
        }
        frequencies, next = next, frequencies
    }

    mx := 0
    mn := max(int)
    for k, v in per_frequency {
        mx = max(mx, v)
        mn = min(mn, v)
    }
    return mx - mn

}

example_input :=`NNCB

CH -> B
HH -> N
CB -> H
NH -> C
HB -> C
HC -> B
HN -> C
NN -> C
BH -> H
NC -> B
NB -> B
BN -> B
BB -> N
BC -> B
CC -> N
CN -> C`