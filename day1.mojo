# Day 1: Trebuchet?!

# ============================================================================
# Part One

fn read_calibration_value( str: String ) -> Int:
    var first : Int = -1
    var last : Int = -1
    for i in range(len(str)):
        let ch = ord(str[i])
        if isdigit(ch):
            if first < 0:
                first = last = ch - ord('0')
            else:
                last = ch - ord('0')
    return first * 10 + last


# ============================================================================
# Part Two

# see if the string at `pos` is a digit
# - returns the digit if found
# - otherwise, returns -1
fn scan_digit( s: String, pos: Int ) -> Int:
    let ch = ord(s[pos])
    if isdigit(ch):
        return ch - ord('0')

    fn compare_word( w: String ) -> Bool:
        return s[pos:pos+len(w)] == w

    if compare_word("one"):
        return 1
    elif compare_word("two"):
        return 2
    elif compare_word("three"):
        return 3
    elif compare_word("four"):
        return 4
    elif compare_word("five"):
        return 5
    elif compare_word("six"):
        return 6
    elif compare_word("seven"):
        return 7
    elif compare_word("eight"):
        return 8
    elif compare_word("nine"):
        return 9

    return -1

fn read_calibration_value2( x: String ) -> Int:
    var first : Int = -1
    var last : Int = -1
    var pos = 0
    while pos <= len(x):
        let num = scan_digit( x, pos )
        pos += 1 # advance to next char
        if num < 0: # not a digit => ignore
            continue

        if first < 0:
            first = last = num
        else:
            last = num
    return first * 10 + last


# ============================================================================
# main: drive the test

fn main() raises:
    var sum = 0

    with open("./inputs/day1-input.txt", "r") as f:
        let input = f.read().split("\n")
        f.close()

        for i in range(len(input)):
            if len(input[i]) == 0: # ignore empty lines
                continue
            # let val = read_calibration_value( input[i] )
            let val = read_calibration_value2( input[i] )
            sum += val
            print( input[i], "=>", val )

    print( "Sum:", sum )
