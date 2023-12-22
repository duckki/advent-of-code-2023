from testing import assert_true

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

