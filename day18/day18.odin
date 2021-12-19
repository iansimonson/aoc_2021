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
    } else when example == 1 {
        input := example_input_2
    } else when example == 2 {
        input := example_input_3
    } else when example == 3 {
        input := example_input_4
    } else {
        input, _ := os.read_entire_file("input")
    }
    {
        v := parse_number("[[1,2],[[3,4],5]]")
        n := magnitude(v[:])
        assert(n == 143)
    }
    {
        v := parse_number("[[[[0,7],4],[[7,8],[6,0]]],[8,1]]")
        n := magnitude(v[:])
        assert(n == 1384)
    }

    lines := strings.split(string(input), "\n")
    p1 := part1(lines)
    fmt.println(p1)
    when example == 0 {
        assert(p1 == 4140)
    }
    fmt.println(part2(lines))
}

print_num :: proc(number: []Number) {
    fmt.print("N: ")
    for n in number {
        fmt.print(n.value, ",")
    }
    fmt.println()
    fmt.print("D: ")
    for n in number {
        fmt.print(n.depth, ",")
    }
    fmt.println()
}

part1 :: proc(lines: []string) -> int {
    current_value := parse_number(lines[0])
    // print_num(current_value[:])
    for line in lines[1:] {
        next := parse_number(line)
        // print_num(next[:])
        current_value = add_numbers(current_value[:], next[:])
        // print_num(current_value[:])
    }
    fmt.println("-----------")
    print_num(current_value[:])
    mag := magnitude(current_value[:])
    return mag
}

part2 :: proc(lines: []string) -> int {
    mags := make(map[[2]int]int)
    values := make([dynamic][dynamic]Number, len(lines))
    for line, i in lines {
        values[i] = parse_number(line)
    }

    for i in 0..<len(lines) {
        for j in 0..<len(lines) {
            forward := [2]int{i, j}
            backward := [2]int{j, i}
            if !(forward in mags) {
                result := add_numbers(values[i][:], values[j][:])
                mags[forward] = magnitude(result[:])
            }
            if !(backward in mags) {
                result := add_numbers(values[j][:], values[i][:])
                mags[backward] = magnitude(result[:])
            }
        }
    }

    max_val := 0
    for k, v in mags {
        if v > max_val && k.x != k.y {
            max_val = v
        }
    }
    return max_val
}

add_numbers :: proc(a, b: []Number) -> [dynamic]Number {
    result := make([dynamic]Number, 0, len(a) + len(b))
    for value in a {
        append(&result, value)
        result[len(result) - 1].depth += 1
    }
    for value in b {
        append(&result, value)
        result[len(result) - 1].depth += 1
    }


    for i := 1; true; i += 1 {
        // fmt.println("-----------------------------")
        if explode(&result) {
            // fmt.println("exploded: ", result)
            // fmt.print("X")
        } else if split(&result) {
            // fmt.println("split: ", result)
            // fmt.print("/")
        } else {
            break
        }
    }
    return result
}

explode :: proc(number: ^[dynamic]Number) -> (updated: bool) {
    for n, i in number {
        if n.depth >= 5 {
            if i != 0 {
                number[i - 1].value += n.value
            }
            assert(i + 1 < len(number))
            if i + 2 < len(number) {
                number[i + 2].value += number[i+1].value
            }
            ordered_remove(number, i)
            number[i].value = 0
            number[i].depth -= 1
            return true
        }
    }
    return false
}

split :: proc(number: ^[dynamic]Number) -> (updated: bool) {
    for n, i in number {
        if n.value >= 10 {
            resize(number, len(number) + 1)
            copy(number[i+2:len(number)], number[i + 1:len(number) - 1])
            cur_val := n.value
            number[i].value = cur_val / 2
            number[i].depth += 1
            number[i+1].value = (cur_val + 1) / 2
            number[i+1].depth = number[i].depth
            return true
        }
    }
    return false
}

magnitude :: proc(number: []Number) -> int {
    num := make([dynamic]Number, len(number))
    copy(num[:], number[:])
    for len(num) > 1 {
        max_idx, max_depth := 0, 0
        for n, i in num {
            if n.depth > max_depth {
                max_idx, max_depth = i, n.depth
            }
        }
        num[max_idx].value = 3 * num[max_idx].value + 2 * num[max_idx + 1].value
        num[max_idx].depth -= 1
        ordered_remove(&num, max_idx + 1)
    }
    return num[0].value
}

Number :: struct {
    value, depth: int,
}

parse_number :: proc(input: string) -> [dynamic]Number {
    result := make([dynamic]Number, 0, 100)
    depth := 0
    input := input
    for len(input) > 0 {
        switch input[0] {
        case '[':
            depth += 1
        case '0'..'9':
            append(&result, Number{strconv.atoi(input[0:1]), depth})
        case ',':
        case ']':
            depth -= 1
        case:
            panic("unknown rune")
        }
        input = input[1:]
    }
    return result
}

example_input := `[[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
[[[5,[2,8]],4],[5,[[9,9],0]]]
[6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
[[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
[[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
[[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
[[[[5,4],[7,7]],8],[[8,3],8]]
[[9,3],[[9,9],[6,[4,9]]]]
[[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
[[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]`


example_input_2 := `[[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]
[7,[[[3,7],[4,3]],[[6,3],[8,8]]]]
[[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]]
[[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]]
[7,[5,[[3,8],[1,4]]]]
[[2,[2,2]],[8,[8,1]]]
[2,9]
[1,[[[9,3],9],[[9,0],[0,7]]]]
[[[5,[7,4]],7],1]
[[[[4,2],2],6],[8,7]]`

example_input_3 := `[[[[4,3],4],4],[7,[[8,4],9]]]
[1,1]`

example_input_4 := `[1,1]
[2,2]
[3,3]
[4,4]
[5,5]
[6,6]`