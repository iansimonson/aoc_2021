package main

import "core:os"
import "core:strings"
import "core:fmt"
import "core:strconv"
import "core:slice"

Column :: struct {
	zeros, ones: int,
}

bit_len :: 12

main :: proc() {

	input, _ := os.read_entire_file("input")

	lines := strings.split(string(input), "\n")

    fmt.println("part1: ", part1(lines))
    fmt.println("part2: ", part2(lines))
}

part1 :: proc(lines: []string) -> int {
    bits := bit_info(lines)
	gamma, epsilon : [bit_len]u8
	for b, i in bits {
		gamma[i] = '1' if b.ones > b.zeros else '0'
		epsilon[i] = '1' if b.ones < b.zeros else '0'
	}
	g, _ := strconv.parse_int(string(gamma[:]), 2)
	e, _ := strconv.parse_int(string(epsilon[:]), 2)
	return g*e
}

part2 :: proc(lines: []string) -> int {
    ox_gen, co2: [bit_len]u8
    // do one separately to split the array
    bits := bit_info(lines)
    idx := partition(lines, bits[:], 0)
    most_common, least_common := lines[:idx], lines[idx:]
    found_mc, found_lc: bool
    for i in 1..<bit_len {
        mc_bits := bit_info(most_common)
        lc_bits := bit_info(least_common)
        mid_point_mc := partition(most_common, mc_bits[:], i)
        mid_point_lc := partition(least_common, lc_bits[:], i)
        most_common = most_common[0:mid_point_mc]
        least_common = least_common[mid_point_lc:]
        if !found_mc && len(most_common) == 1 {
            copy(ox_gen[:], most_common[0])
            found_mc = true
        }
        if !found_lc && len(least_common) == 1 {
            copy(co2[:], least_common[0])
            found_lc = true
        }
    }

    o, _ := strconv.parse_int(string(ox_gen[:]), 2)
	c, _ := strconv.parse_int(string(co2[:]), 2)
    return o*c
}

bit_info :: proc(lines: []string) -> [bit_len]Column
{
    bits := [bit_len]Column{}
	set_bit :: proc(line: string, b:^[bit_len]Column, idx: int) {
		if line[idx] == '1' {
			b[idx].ones += 1
		} else {
			b[idx].zeros += 1
		}
	}

	for line, j in lines {
		if len(line) == 0 { continue }
		for i in 0..<bit_len {
		    set_bit(line, &bits, i)
		}
	}
    return bits
}

// probably a faster way to do this
// partition [most_common; least_common]
// returns first index of least_common
partition :: proc(lines: []string, b: []Column, idx: int) -> int {
    d := b[idx]
    zero :: proc(l, r: string) -> bool {
        idx := context.user_index
        return l[idx] < r[idx]
    }
    one :: proc(l, r: string) -> bool {
        idx := context.user_index
        return r[idx] < l[idx]
    }
    get_zero :: proc(s: string) -> bool {
        idx := context.user_index
        return s[idx] == '0'
    }
    get_one :: proc(s: string) -> bool {
        idx := context.user_index
        return s[idx] == '1'
    }
    {
        context.user_index = idx
        slice.sort_by(lines, one if d.ones >= d.zeros else zero)
        idx, found := slice.linear_search_proc(lines, get_zero if d.ones >= d.zeros else get_one)
        return idx if found else len(lines)
    }
}