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

    fmt.println(part1(string(input)))
    fmt.println(part2(string(input)))
}

binary_lookup := map[rune][4]u8 {
    '0' = "0000",
    '1' = "0001",
    '2' = "0010",
    '3' = "0011",
    '4' = "0100",
    '5' = "0101",
    '6' = "0110",
    '7' = "0111",
    '8' = "1000",
    '9' = "1001",
    'A' = "1010",
    'B' = "1011",
    'C' = "1100",
    'D' = "1101",
    'E' = "1110",
    'F' = "1111",
}

Header :: struct {
    version, type_id: int,
}

Literal :: struct {
    using header: Header,
    value: int,
}

Operator :: struct {
    using header: Header,
    length_type: int,
    function: proc([]int) -> int,
    sub_packets: [dynamic]Packet,
}

Packet :: union {
    Literal,
    Operator,
}

part1 :: proc(data: string) -> int {
    binary := expand_hex(data)

    version := 0
    packet, rest, ok := parse_packet(binary[:])
    assert(ok)

    return sum_version(packet)
}

part2 :: proc(data: string) -> int {
    binary := expand_hex(data)


    packet, rest, ok := parse_packet(binary[:])
    assert(ok)

    return evaluate(packet)
}

evaluate :: proc(packet: Packet) -> int {
    switch p in packet {
    case Literal:
        return p.value
    case Operator:
        values := make([dynamic]int)
        for s in p.sub_packets {
            append(&values, evaluate(s))
        }
        return p.function(values[:])
    case:
        panic("Unknown variant type")
    }
}

sum_version :: proc(packet: Packet) -> int {
    version := 0
    switch p in packet {
    case Literal:
        version += p.version
    case Operator:
        version += p.version
        for sub_p in p.sub_packets {
            version += sum_version(sub_p)
        }
    }
    return version
}

expand_hex :: proc(data: string) -> [dynamic]u8 {
    binary := make([dynamic]u8, 0, 4*len(data))
    for d in data {
        as_binary := binary_lookup[d]
        append(&binary, as_binary.x, as_binary.y, as_binary.z, as_binary.w)
    }
    return binary
}

parse_packet :: proc(data: []u8) -> (result: Packet, r: []u8, ok: bool) {
    data := data
    version := strconv.parse_int(string(data[:3]), 2) or_return
    type_id := strconv.parse_int(string(data[3:][:3]), 2) or_return

    data = data[6:]
    if type_id == 4 {
        value, rest := parse_literal(data)
        data = rest
        return Literal{header = Header{version= version, type_id = type_id}, value = value}, data, true
    } else {
        length_type := strconv.parse_int(string(data[0:1]), 2) or_return
        operator := Operator{header = {version = version, type_id = type_id}, length_type = length_type}
        switch type_id {
        case 0:
            operator.function = sum
        case 1:
            operator.function = product
        case 2:
            operator.function = minimum
        case 3:
            operator.function = maximum
        case 5:
            operator.function = gt
        case 6:
            operator.function = lt
        case 7:
            operator.function = eq
        case:
            panic("Unknown type_id")
        }
        operator.sub_packets = make([dynamic]Packet, context.temp_allocator)
        if length_type == 0 {
            length := strconv.parse_int(string(data[1:][:15]), 2) or_return
            rest := data[16:][:length]
            data = data[16 + length:]
            for len(rest) != 0 {
                sub_packet: Packet
                sub_packet, rest = parse_packet(rest) or_return
                append(&operator.sub_packets, sub_packet)
            }
        } else {
            num_sub_packets := strconv.parse_int(string(data[1:][:11]), 2) or_return
            rest := data[12:]
            data = data[12:]
            for ;num_sub_packets != 0; num_sub_packets -= 1 {
                sub_packet: Packet
                sub_packet, rest = parse_packet(rest) or_return
                append(&operator.sub_packets, sub_packet)
                data = data[len(data) - len(rest):]
            }

        }
        return operator, data, true
    }
}

parse_literal :: proc(data: []u8) -> (int, []u8) {
    data := data
    tmp := make([dynamic]u8, context.temp_allocator)
    for data[0] != u8('0') {
        values := data[1:5]
        for v in values {
            append(&tmp, v)
        }
        data = data[5:]
    }
    values := data[1:5]
    for v in values {
        append(&tmp, v)
    }
    data = data[5:]
    value, _ := strconv.parse_int(string(tmp[:]), 2)
    return value, data
}

sum :: proc(a: []int) -> int {
    return slice.reduce(a, 0, proc(a, b: int) -> int {
        return a + b
    })
}

product :: proc(a: []int) -> int {
    return slice.reduce(a, 1, proc(a, b: int) -> int {
        return a * b
    })
}

minimum :: proc(a: []int) -> int {
    v, _ := slice.min(a)
    return v
}
maximum :: proc(a: []int) -> int {
    v, _ := slice.max(a)
    return v
}
gt :: proc(a: []int) -> int {
    return 1 if a[0] > a[1] else 0
}

lt :: proc(a: []int) -> int {
    return 1 if a[0] < a[1] else 0
}
eq :: proc(a: []int) -> int {
    return 1 if a[0] == a[1] else 0
}

example_input := `8A004A801A8002F478`
example_input_2 := `620080001611562C8802118E34`
example_input_3 := `C0015000016115A2E0802F182340`
example_input_4 := `A0016C880162017C3686B18A3D4780`