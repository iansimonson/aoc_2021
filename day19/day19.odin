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

    for x in x_rotations {
        append(&all_rotations, x, z_rotations[2]*x)
    }
    for y in y_rotations {
        append(&all_rotations, z_rotations[1]*y, z_rotations[3]*y)
    }
    for z in z_rotations {
        append(&all_rotations, y_rotations[1]*z, y_rotations[3]*z)
    }
    assert(len(all_rotations) == 24)

    scanners := parse_scanners(string(input))
    fmt.println(solve(scanners[:]))
}

/*
Find all unique beacons - count only
we will try to process them all in relation to s0
all "done" scanners D will have coords rotated to match s0 orientation
but will still be in d_i / s_i space rather than s0
I think general plan is:
while len(S[1:]) > 0
    for each "done" scanner:
        try match si against dj
        if match -> convert all points to s0 space (si -> dj -> s0)
        set translation_vector for si -> s0 as (sk -> dj -> s0) where dj is (sj -> sp ->...->s0)

try_match ->
    for all possible orientations of si
    for each point in si, rotate and compare to dj[0]. if match count points matched
    if 12 -> return rotated list, true, translation_vec
return nil, false, nil


part2:
part 2 is easy: translation_vec[i] is effectively
scanner_i location relative to s0 so just for each pair find max
manhattan distance

*/
solve :: proc(scanners: []Scanner) -> (int, int) {
    all_beacons := make([dynamic][3]int) // relative to s0
    translation_vectors := make(map[int][3]int) // translate from i to to 0
    done := make(map[int][dynamic][3]int) // rotated to all face the same way as s0

    for coord in scanners[0].coords {
        append(&all_beacons, coord)
    }
    d_0 := make([dynamic][3]int, len(scanners[0].coords))
    copy(d_0[:], scanners[0].coords[:])
    done[0] = d_0

    unknown_scanners := slice.to_dynamic(scanners[1:])
    outer: for len(unknown_scanners) > 0 {
        for s, ui in unknown_scanners {
            for id, coords in done {
                rotated, translation, match := try_match(Scanner{id, coords}, s)
                if match {
                    done[s.id] = rotated.coords
                    translation_vectors[s.id] = translation + translation_vectors[id]
                    for p in rotated.coords[:] {
                        coord := p + translation_vectors[s.id]
                        if !slice.contains(all_beacons[:], coord) {
                            append(&all_beacons, coord)
                        }
                    }
                    unordered_remove(&unknown_scanners, ui)
                    continue outer
                }
            }
        }
    }

    // part2
    m := 0
    for id1, t1 in translation_vectors {
        for id2, t2 in translation_vectors {
            if id1 == id2 do continue
            sum := abs(t2.x - t1.x) + abs(t2.y - t1.y) + abs(t2.z - t1.z)
            m = max(m, sum)
        }
    }

    return len(all_beacons), m
}

/*
    Rotated is still in `matching` space
*/
try_match :: proc(known, matching: Scanner) -> (Scanner, [3]int, bool) {
    sub_match :: proc(rotation: matrix[3,3]int, p: [3]int, known, matching: Scanner) -> ([3]int, bool) {
        c := slice.clone(matching.coords[:])
        for ci in &c {
            ci = rotation * ci
        }
        for ci in &c {
            translation_vec := (p - ci)
            matches := 0
            for cj in c {
                cj_1 := cj
                cj_1 += translation_vec
                if slice.contains(known.coords[:], cj_1) {
                    matches += 1
                }
            }
            if matches >= 12 {
                return translation_vec, true
            }
        }
        return [3]int{}, false
    }
    
    for p in known.coords {
        for r in all_rotations[:] {
            if translation_vec, matches := sub_match(r, p, known, matching); matches {
                rotated := slice.to_dynamic(matching.coords[:])
                for ri in &rotated {
                    ri = r * ri
                }
                return Scanner{id = matching.id, coords = rotated}, translation_vec, true
            }
        }
    }
    return Scanner{}, [3]int{}, false
}

// A scanner is identified by its number
// which can be used as an index
Scanner :: struct {
    id: int,
    coords: [dynamic][3]int,
}

parse_scanners :: proc(input: string) -> [dynamic]Scanner {
    result := make([dynamic]Scanner)
    scanners := strings.split(string(input), "\n\n")
    defer delete(scanners)
    for s, id in scanners {
        lines := strings.split(s, "\n")
        defer delete(lines)
        coords := make([dynamic][3]int)
        for line in lines[1:] {
            items := strings.split(line, ",")
            defer delete(items)
            x, y, z := strconv.atoi(items[0]), strconv.atoi(items[1]), strconv.atoi(items[2])
            append(&coords, [3]int{x, y, z})
        }
        scanner := Scanner{id = id, coords = coords}
        append(&result, scanner)
    }
    return result
}

all_rotations: [dynamic]matrix[3,3]int


z_rotations := [4]matrix[3,3]int {
    {
        1, 0, 0,
        0, 1, 0,
        0, 0, 1,
    },
    {
        0, -1, 0,
        1, 0, 0,
        0, 0, 1,
    },
    {
        -1, 0, 0,
        0, -1, 0,
        0, 0, 1,
    },
    {
        0, 1, 0,
        -1, 0, 0,
        0, 0, 1,
    },
}

y_rotations := [4]matrix[3,3]int {
    {
        1, 0, 0,
        0, 1, 0,
        0, 0, 1,
    },
    {
        0, 0, -1,
        0, 1, 0,
        1, 0, 0,
    },
    {
        -1, 0, 0,
        0, 1, 0,
        0, 0, -1,
    },
    {
        0, 0, 1,
        0, 1, 0,
        -1, 0, 0,
    },
}

x_rotations := [4]matrix[3,3]int {
    {
        1, 0, 0,
        0, 1, 0,
        0, 0, 1,
    },
    {
        1, 0, 0,
        0, 0, -1,
        0, 1, 0,
    },
    {
        1, 0, 0,
        0, -1, 0,
        0, 0, -1,
    },
    {
        1, 0, 0,
        0, 0, 1,
        0, -1, 0,
    },
}

example_input := `--- scanner 0 ---
404,-588,-901
528,-643,409
-838,591,734
390,-675,-793
-537,-823,-458
-485,-357,347
-345,-311,381
-661,-816,-575
-876,649,763
-618,-824,-621
553,345,-567
474,580,667
-447,-329,318
-584,868,-557
544,-627,-890
564,392,-477
455,729,728
-892,524,684
-689,845,-530
423,-701,434
7,-33,-71
630,319,-379
443,580,662
-789,900,-551
459,-707,401

--- scanner 1 ---
686,422,578
605,423,415
515,917,-361
-336,658,858
95,138,22
-476,619,847
-340,-569,-846
567,-361,727
-460,603,-452
669,-402,600
729,430,532
-500,-761,534
-322,571,750
-466,-666,-811
-429,-592,574
-355,545,-477
703,-491,-529
-328,-685,520
413,935,-424
-391,539,-444
586,-435,557
-364,-763,-893
807,-499,-711
755,-354,-619
553,889,-390

--- scanner 2 ---
649,640,665
682,-795,504
-784,533,-524
-644,584,-595
-588,-843,648
-30,6,44
-674,560,763
500,723,-460
609,671,-379
-555,-800,653
-675,-892,-343
697,-426,-610
578,704,681
493,664,-388
-671,-858,530
-667,343,800
571,-461,-707
-138,-166,112
-889,563,-600
646,-828,498
640,759,510
-630,509,768
-681,-892,-333
673,-379,-804
-742,-814,-386
577,-820,562

--- scanner 3 ---
-589,542,597
605,-692,669
-500,565,-823
-660,373,557
-458,-679,-417
-488,449,543
-626,468,-788
338,-750,-386
528,-832,-391
562,-778,733
-938,-730,414
543,643,-506
-524,371,-870
407,773,750
-104,29,83
378,-903,-323
-778,-728,485
426,699,580
-438,-605,-362
-469,-447,-387
509,732,623
647,635,-688
-868,-804,481
614,-800,639
595,780,-596

--- scanner 4 ---
727,592,562
-293,-554,779
441,611,-461
-714,465,-776
-743,427,-804
-660,-479,-426
832,-632,460
927,-485,-438
408,393,-506
466,436,-512
110,16,151
-258,-428,682
-393,719,612
-211,-452,876
808,-476,-593
-575,615,604
-485,667,467
-680,325,-822
-627,-443,-432
872,-547,-609
833,512,582
807,604,487
839,-516,451
891,-625,532
-652,-548,-490
30,-46,-14`