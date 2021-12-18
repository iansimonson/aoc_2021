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

    fmt.println(part1(string(input)))
    fmt.println(part2(string(input)))
}

Rect :: struct {
    x, y, width, height: int,
}

Probe :: struct {
    position: [2]int,
    velocity: [2]int,
}

part1 :: proc(target: string) -> int {
    rect := parse_target(target)
    fmt.println(rect)
    velocity := find_velocity(rect)

    fmt.println(velocity)
    return max_height(velocity)
}

part2 :: proc(target: string) -> int {
    rect := parse_target(target)

    count := 0
    for y := 1000; y >= rect.y; y -= 1 {
        for x := rect.x + rect.width; x >= 0; x -= 1 {
            attempt := Probe{position = {0, 0}, velocity = {x, y}}
            for step := 0; attempt.position.x <= rect.x + rect.width && attempt.position.y >= rect.y; step += 1 {
                attempt.position.x += attempt.velocity.x
                attempt.position.y += attempt.velocity.y
                attempt.velocity += [2]int{-1, -1}
                if attempt.velocity.x <= 0 {
                    attempt.velocity.x = 0
                }
    
                if attempt.position.x >= rect.x && attempt.position.x <= rect.x + rect.width && attempt.position.y >= rect.y && attempt.position.y <= rect.y + rect.height {
                    count += 1
                    break
                }
            }
        }
    }
    return count
}

parse_target :: proc(target: string) -> Rect {
    result: Rect

    trim := strings.trim_space(strings.split(target, ":")[1])
    x_y := strings.split(trim, ",")
    x_value := strings.split(strings.trim_space(x_y[0]), "=")[1]
    x_values := strings.split(strings.trim_space(x_value), "..")
    result.x = strconv.atoi(x_values[0])
    result.width = strconv.atoi(x_values[1]) - result.x

    y_value := strings.split(strings.trim_space(x_y[1]), "=")[1]
    y_values := strings.split(strings.trim_space(y_value), "..")
    result.y = strconv.atoi(y_values[0])
    result.height = strconv.atoi(y_values[1]) - result.y
    return result
}

find_velocity :: proc(target: Rect) -> [2]int {
    for y := 1000; y >= 0; y -= 1 {
        for x := target.x + target.width; x >= 0; x -= 1 {
            attempt := Probe{position = {0, 0}, velocity = {x, y}}
            for step := 0; attempt.position.x <= target.x + target.width && attempt.position.y >= target.y; step += 1 {
                attempt.position.x += attempt.velocity.x
                attempt.position.y += attempt.velocity.y
                attempt.velocity += [2]int{-1, -1}
                if attempt.velocity.x <= 0 {
                    attempt.velocity.x = 0
                }
    
                if attempt.position.x >= target.x && attempt.position.x <= target.x + target.width && attempt.position.y >= target.y && attempt.position.y <= target.y + target.height {
                    return {x, y}
                }
            }
        }
    }

    return {-1, -1}
}

max_height :: proc(init_velocity: [2]int) -> int {
    max_y := 0
    for y := init_velocity.y; y >= 0; y -= 1 {
        max_y += y
    }
    return max_y
}

example_input := `target area: x=20..30, y=-10..-5`