package main

import "core:os"
import "core:strings"
import "core:fmt"
import "core:strconv"
import "core:slice"
import "core:math"

main :: proc() {
    when #config(example, false) {
        input := example_data
    } else when #config(example2, false) {
        input := example_data_2
    } else when #config(example3, false) {
        input := example_data_3
    } else {
        input, _ := os.read_entire_file("input")
    }

    lines := strings.split(string(input), "\n")

    adjacency_list := parse_input(lines)
    for k, v in adjacency_list {
        fmt.println("key: ", k, ", values: ", v)
    }

    fmt.println("part1: ", part1(adjacency_list))
    fmt.println("part2: ", part2(adjacency_list))

}

AdjacencyList :: map[string][dynamic]string

part1 :: proc(list: AdjacencyList) -> int {
    visited := make(map[string]bool)

    result := search("start", list, &visited)
    return result
}

part2 :: proc(list: AdjacencyList) -> int {
    visited := make(map[string]bool)

    result := search_one_little("start", list, &visited, false)
    return result
}

clone_map :: proc(m: ^$T/map[$U]$V) -> (result: T) {
    for k, v in m {
        result[k] = v
    }
    return
}

search :: proc(node: string, list: AdjacencyList, visited: ^map[string]bool) -> int {
    if node == "end" do return 1
    else if visited[node] && (is_little(node) || node == "start") do return 0

    visited[node] = true
    paths := 0
    nodes := list[node]
    for node in nodes {
        visited_so_far := clone_map(visited)
        paths += search(node, list, &visited_so_far)
    }
    return paths
}

search_one_little :: proc(node: string, list: AdjacencyList, visited: ^map[string]bool, used_little: bool) -> int {
    if node == "end" do return 1
    else if visited[node] && ((is_little(node) && used_little) || node == "start") do return 0

    used_little := used_little
    if visited[node] && is_little(node) && !used_little {
        used_little = true
    }

    visited[node] = true
    paths := 0
    nodes := list[node]
    for node in nodes {
        visited_so_far := clone_map(visited)
        paths += search_one_little(node, list, &visited_so_far, used_little)
    }
    return paths
}

is_little :: proc(s: string) -> bool {
    if s == "start" || s == "end" do return false

    switch(s[0]) {
    case 'a'..'z':
        return true
    case:
        return false
    }
}

parse_input :: proc(lines: []string) -> map[string][dynamic]string {
    result := make(map[string][dynamic]string)

    for line in lines {
        connection := strings.split(line, "-")
        {
            arr := result[connection[0]]
            if _, found := slice.linear_search(arr[:], connection[1]); !found {
                append(&arr, connection[1])
                result[connection[0]] = arr
            }
        }
        {
            arr := result[connection[1]]
            if _, found := slice.linear_search(arr[:], connection[0]); !found {
                append(&arr, connection[0])
                result[connection[1]] = arr
            }
        }
    }

    return result
}

example_data := `start-A
start-b
A-c
A-b
b-d
A-end
b-end`

example_data_2 := `dc-end
HN-start
start-kj
dc-start
dc-HN
LN-dc
HN-end
kj-sa
kj-HN
kj-dc`

example_data_3 := `fs-end
he-DX
fs-he
start-DX
pj-DX
end-zg
zg-sl
zg-pj
pj-he
RW-he
fs-DX
pj-RW
zg-RW
start-pj
he-WI
zg-he
pj-fs
start-RW`