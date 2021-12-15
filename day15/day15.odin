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

    backing_array, m := parse_input(lines)
    defer delete(backing_array)

    fmt.println(part1(m))

    m2 := m[1:len(m)-1]
    for v in &m2 {
        v = v[1:len(m)-1]
    }
    fmt.println(part2(m2))
}

parse_input :: proc(lines: []string) -> ([dynamic]int, [][]int)
{
    rows := len(lines) + 2
    cols := len(lines[0]) + 2
    backing_array := make([dynamic]int, rows * cols)
    for i in &backing_array {
        i = int(max(i32)) // allows arbitrarily large value without wrapping issues of max(int)
    }

    for line, r in lines {
        for c, col in line {
            backing_array[(r+1) * cols + (col+1)] = int(u8(c) - u8('0'))
        }
    }
    view := make([dynamic][]int, rows)
    for v, i in &view {
        v = backing_array[i * cols:(i+1)*cols]
    }
    return backing_array, view[:]
}

Point :: [2]int

neighbors :: proc(p: Point) -> [4]Point {
    return [4]Point{
        Point{p.x, p.y-1},
        Point{p.x-1, p.y},
        Point{p.x+1, p.y},
        Point{p.x, p.y+1},
    }
}

part1 :: proc(m: [][]int) -> int {

    distances := make(map[Point]int) // current value of each node
    visited := make(map[Point]bool) // have we visited

    for i in 0..<len(m) {
        for j in 0..<len(m[0]) {
            distances[Point{i, j}] = int(max(i32))
        }
    }

    start := Point{1, 1}
    end := Point{len(m)-2, len(m[0])-2}


    
    to_visit := make([dynamic]Point)
    distances[start] = 0

    context.user_ptr = transmute(rawptr) &distances

    node := start
    for node != end {
        visited[node] = true

        // this only works because edges are weight max(int)
        // so will never be selected over a node with a real weight
        ns := neighbors(node)
        for n in ns {
            _, found := slice.linear_search(to_visit[:], n)
            if !visited[n] && !found {
                append(&to_visit, n)
            }
            value := distances[node] + m[n.y][n.x]
            distances[n] = min(value, distances[n])
        }
        
        slice.sort_by(to_visit[:], proc(i, j: Point) -> bool {
            distances := transmute(^map[Point]int) context.user_ptr
            return distances[i] > distances[j]
        })

        node = to_visit[len(to_visit)-1]
        pop(&to_visit)
    }

    return distances[end]

}

neighbors2 :: proc(node, max: Point) -> []Point {
    points := make([dynamic]Point, context.temp_allocator)
    p1, p2, p3, p4 := Point{node.x, node.y-1}, Point{node.x-1, node.y}, Point{node.x+1,node.y}, Point{node.x,node.y+1}
    valid :: proc(l, m: Point) -> bool {
        return l.x >= 0 && l.y >= 0 && l.x < m.x && l.y < m.y
    }
    if valid(p1, max) {
        append(&points, p1)
    }
    if valid(p2, max) {
        append(&points, p2)
    }
    if valid(p3, max) {
        append(&points, p3)
    }
    if valid(p4, max) {
        append(&points, p4)
    }

    return points[:]
}

part2 :: proc(m: [][]int) -> int {
    tile := Point{0,0}
    tile_size := len(m)
    total_size := 5*tile_size
    distances := make(map[Point]int) // current value of each node
    visited := make(map[Point]bool) // have we visited

    for i in 0..<total_size {
        for j in 0..<total_size {
            distances[Point{i, j}] = int(max(i32))
        }
    }

    start := Point{0, 0}
    end := Point{total_size - 1, total_size - 1}

    to_visit := make([dynamic]Point)
    distances[start] = 0

    get_risk :: proc(m: [][]int, n: Point) -> int {
        horizontal := n.x / len(m[0])
        vertical := n.y / len(m)
        
        m_point := Point{n.x % len(m[0]), n.y % len(m)}
        value := m[m_point.y][m_point.x]
        value += horizontal + vertical
        if value > 9 {
            value -= 9
        }
        return value
    }

    // for sorting below
    context.user_ptr = transmute(rawptr) &distances

    node := start
    for node != end {
        visited[node] = true

        // this only works because edges are weight max(int)
        // so will never be selected over a node with a real weight
        ns := neighbors2(node, Point{total_size, total_size})
        for n in ns {
            _, found := slice.linear_search(to_visit[:], n)
            if !visited[n] && !found {
                append(&to_visit, n)
            }
            value := distances[node] + get_risk(m, n)
            distances[n] = min(value, distances[n])
        }
        
        slice.sort_by(to_visit[:], proc(i, j: Point) -> bool {
            distances := transmute(^map[Point]int) context.user_ptr
            return distances[i] > distances[j]
        })

        node = to_visit[len(to_visit)-1]
        pop(&to_visit)
    }

    return distances[end]
}


example_input :=`1163751742
1381373672
2136511328
3694931569
7463417111
1319128137
1359912421
3125421639
1293138521
2311944581`