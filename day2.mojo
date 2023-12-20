# Day 2: Cube Conundrum

from testing import assert_true

@value
struct Clue(CollectionElement):
    var red: Int
    var green: Int
    var blue: Int

@value
struct Game:
    var id: Int
    var clues: DynamicVector[Clue]

    def __init__(inout self, id: Int):
        self.id = id
        self.clues = DynamicVector[Clue]()

fn skip_string( line: String, inout pos: Int, s: String ) raises:
    assert_true( line[pos:pos+len(s)] == s )
    pos += len(s)

fn scan_number( line: String, inout pos: Int ) raises -> Int:
    let start = pos
    while pos < len(line) and isdigit(ord(line[pos])):
        pos += 1
    return atol(line[start:pos])

fn scan_word( line: String, inout pos: Int ) raises -> String:
    let start = pos

    fn isalpha(c: Int) -> Bool:
        return (c >= ord('a') and c <= ord('z'))
            or (c >= ord('A') and c <= ord('Z'))

    while pos < len(line) and isalpha(ord(line[pos])):
        pos += 1
    return line[start:pos]

fn parse_game( line: String ) raises -> Game:
    var pos = 0
    skip_string( line, pos, "Game " )

    let semicolon_offset = line.find(":", pos)
    assert_true( semicolon_offset != -1 )

    let id = atol(line[pos:pos+semicolon_offset])

    pos += semicolon_offset
    skip_string( line, pos, ": " )

    var game = Game(id)

    # parse color counts
    while pos < len(line):
        assert_true( isdigit(ord(line[pos])) )

        # fill Clue
        var clue = Clue(0, 0, 0)

        while isdigit(ord(line[pos])):
            let count = scan_number( line, pos )
            skip_string( line, pos, " " )
            let color = scan_word( line, pos )
            if color == "blue":
                clue.blue = count
            elif color == "red":
                clue.red = count
            elif color == "green":
                clue.green = count
            else:
                raise "unknown color"

            if pos == len(line): # end of game
                break
            elif line[pos] == ";": # end of clue
                skip_string( line, pos, "; " )
                break
            elif line[pos] == ",": # end of color
                skip_string( line, pos, ", " )
                continue
            else:
                raise "expected ',' or ';' at " + str(pos) + " `" + line[pos:] + "`"

        game.clues.append( clue )

    return game

fn is_impossible_game( game: Game ) -> Bool:
    for i in range(len(game.clues)):
        let clue = game.clues[i]
        if clue.blue > 14 or clue.red > 12 or clue.green > 13:
            return True

    return False

# part 1: returns the id number, if the line is a possible game; otherwise, zero.
fn part1( line: String ) raises -> Int:
    let g = parse_game( line )
    if not is_impossible_game(g):
        print( "possible:", g.id )
        return g.id
    return 0

# part 2: returns the power of the game.
fn part2( line: String ) raises -> Int:
    let g = parse_game( line )

    var max_blue: Int = 0
    var max_red: Int = 0
    var max_green: Int = 0

    for i in range(len(g.clues)):
        let clue = g.clues[i]
        if clue.blue > max_blue:
            max_blue = clue.blue
        if clue.red > max_red:
            max_red = clue.red
        if clue.green > max_green:
            max_green = clue.green

    # compute the power of the game
    return max_blue * max_red * max_green

fn main() raises:
    var sum = 0

    with open("./inputs/day2-input.txt", "r") as f:
        let input = f.read().split("\n")
        f.close()

        for i in range(len(input)):
            if len(input[i]) == 0: # ignore empty lines
                continue
            # sum += part1( input[i] )
            sum += part2( input[i] )

    print( "sum:", sum )
