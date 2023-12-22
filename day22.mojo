from testing import assert_true
from text_scan import skip_string, scan_number
from queue import Queue
from time import sleep

@value
struct Coord(CollectionElement, Stringable):
    var x: Int
    var y: Int
    var z: Int

    fn __str__( self ) -> String:
        return str(self.x) + "," + str(self.y) + "," + str(self.z)

@value
struct Cube(CollectionElement):
    var start: Coord
    var end: Coord

    fn check( self ) raises:
        assert_true( self.start.x <= self.end.x )
        assert_true( self.start.y <= self.end.y )
        assert_true( self.start.z <= self.end.z )

    fn hit( self, coord: Coord ) -> Bool:
        return (self.start.x <= coord.x and coord.x <= self.end.x)
           and (self.start.y <= coord.y and coord.y <= self.end.y)
           and (self.start.z <= coord.z and coord.z <= self.end.z)

    fn projectZ( self ) -> DynamicVector[Coord]:
        var result = DynamicVector[Coord]()
        let z = self.start.z
        if self.start.x != self.end.x: # align with the X-axis
            for x in range(self.start.x, self.end.x+1):
                result.append( Coord(x, self.start.y, z) )
        elif self.start.y != self.end.y: # align with the Y-axis
            for y in range(self.start.y, self.end.y+1):
                result.append( Coord(self.start.x, y, z) )
        else: # align with the Z-axis
            result.append( Coord(self.start.x, self.start.y, z) )
        return result

@value
struct World:
    var cubes: DynamicVector[Cube]

    fn dump( self ):
        for i in range(len(self.cubes)):
            let cube = self.cubes[i]
            print( "cube[", i, "] = ", cube.start, "~", cube.end )

    # returns the index of the cube that is located at the given coordinates
    fn locate_cube( self, coord: Coord ) -> Int:
        for i in range(len(self.cubes)):
            let curr = self.cubes[i]
            if curr.hit(coord):
                return i
        return -1

    # returns any one that supports the given cube
    fn find_support( self, cube: Cube ) -> Int:
        let z_proj = cube.projectZ()
        for i in range(len(z_proj)):
            let foot = z_proj[i]
            let index = self.locate_cube(Coord(foot.x, foot.y, foot.z-1))
            if index >= 0:
                return index
        return -1

    fn is_supported( self, cube: Cube ) -> Bool:
        if cube.start.z == 1:
            return True
        let support = self.find_support(cube)
        return support >= 0

    # returns True if updated
    fn update_world( inout self ) -> Bool:
        var updated = False
        for i in range(len(self.cubes)):
            let cube = self.cubes[i]
            if not self.is_supported(cube):
                # print( "moving cube[", i, "]"   )
                self.cubes[i].start.z -= 1
                self.cubes[i].end.z -= 1
                updated = True
        return updated

    fn find_all_supports( self, cube: Cube ) -> DynamicVector[Int]:
        var result = DynamicVector[Int]()
        let z_proj = cube.projectZ()
        for i in range(len(z_proj)):
            let foot = z_proj[i]
            let index = self.locate_cube(Coord(foot.x, foot.y, foot.z-1))
            if index >= 0:
                result.append( index )
        return result

    fn report_supports( self ):
        for i in range(len(self.cubes)):
            let cube = self.cubes[i]
            let supports = self.find_all_supports(cube)
            if cube.start.z == 0:
                print( "cube[", i, "] is on the ground" )
            elif len(supports) > 0:
                for j in range(len(supports)):
                    let support = supports[j]
                    print( "cube[", i, "] is supported by cube[", support, "]" )
            else:
                print( "cube[", i, "] is not supported" )

    fn solve_part1( self ) raises:
        let size = len(self.cubes)
        var supports_graph = DynamicVector[DynamicVector[Int]]()
        var supportedBy_graph = DynamicVector[DynamicVector[Int]]()

        # build the "support" graph
        print( "building graph..." )
        supports_graph.resize(size, DynamicVector[Int]())
        supportedBy_graph.resize(size, DynamicVector[Int]())
        for i in range(size):
            let cube = self.cubes[i]
            let supports = self.find_all_supports(cube)
            for idx_j in range(len(supports)):
                let j = supports[idx_j]
                # j supports i
                print( i, "->", j )
                supports_graph[j].append( i )
                supportedBy_graph[i].append( j )

        print( "solving..." )

        fn is_supported_by_others(j: Int, i: Int) -> Bool:
            # check if `j` is supported by other cubes
            let supportedBy = supportedBy_graph[j]
            for idx_k in range(len(supportedBy)):
                let k = supportedBy[idx_k]
                # k supports j
                if k != i:
                    return True
            # otherwise
            return False

        fn is_removeable( i: Int ) -> Bool:
            let supports = supports_graph[i]
            for idx_j in range(len(supports)):
                let j = supports[idx_j]
                # `i` supports `j`
                print( i, "->", j )
                if not is_supported_by_others(j, i):
                    print( " ", i, "is not removable" )
                    return False
            # `i` is removable
            print( " ", i, "is removable" )
            return True

        var count = 0
        for i in range(size):
            if is_removeable(i):
                count += 1

        print( "removable cubes:", count  )
    # end fn solve_part1

    @staticmethod
    fn search_part2( supports_graph: DynamicVector[DynamicVector[Int]]
                   , supportedBy_graph: DynamicVector[DynamicVector[Int]]
                   , i: Int ) raises -> Int:

        var removed = DynamicVector[Int]()

        fn is_removed( removed: DynamicVector[Int], i: Int ) -> Bool:
            for idx in range(len(removed)):
                if removed[idx] == i:
                    return True
            return False

        fn is_supported_by_others(removed: DynamicVector[Int], j: Int, i: Int) -> Bool:
            # check if `j` is supported by other cubes
            let supportedBy = supportedBy_graph[j]
            for idx_k in range(len(supportedBy)):
                let k = supportedBy[idx_k]
                # k supports j
                if k != i and not is_removed(removed, k):
                    return True
            # otherwise
            return False

        var queue = Queue[Int]()
        var count = 0
        queue.enqueue( i )
        while len(queue) > 0:
            # print( " queue size:", len(queue) )
            let curr = queue.dequeue()
            # print( " curr:", curr )
            let supports = supports_graph[curr]
            for idx_j in range(len(supports)):
                let j = supports[idx_j]
                # `i` supports `j`
                if is_removed(removed, j):
                    # `j` is already removed. Skip it.
                    continue
                if not is_supported_by_others(removed, j, i):
                    # print( " ", j, " falls" )
                    count += 1
                    # chain reaction
                    queue.enqueue( j )
                    removed.append( j )
        return count

    fn solve_part2( self ) raises:
        let size = len(self.cubes)
        var supports_graph = DynamicVector[DynamicVector[Int]]()
        var supportedBy_graph = DynamicVector[DynamicVector[Int]]()

        # build the "support" graph
        print( "building graph..." )
        supports_graph.resize(size, DynamicVector[Int]())
        supportedBy_graph.resize(size, DynamicVector[Int]())
        for i in range(size):
            let cube = self.cubes[i]
            let supports = self.find_all_supports(cube)
            for idx_j in range(len(supports)):
                let j = supports[idx_j]
                # j supports i
                # print( i, "->", j )
                supports_graph[j].append( i )
                supportedBy_graph[i].append( j )

        print( "solving..." )

        var total_fallen = 0
        for i in range(size):
            print( "if remove", i )
            let fallen = Self.search_part2( supports_graph, supportedBy_graph, i )
            print( " ", fallen, "cubes fall" )
            total_fallen += fallen
        print( "total fallen:", total_fallen )

    # end fn solve_part2

# ============================================================================
# parsing input

fn parse_line( line: String ) raises -> Cube:
    var pos: Int = 0

    fn parse_coord( inout pos: Int) raises -> Coord:
        let x = scan_number(line, pos)
        skip_string( line, pos, "," )
        let y = scan_number(line, pos)
        skip_string( line, pos, "," )
        let z = scan_number(line, pos)
        return Coord(x, y, z)

    let start = parse_coord( pos )
    skip_string( line, pos, "~" )
    let end = parse_coord( pos )
    return Cube(start, end)

fn swap[T:AnyRegType]( inout x:T, inout y:T ):
    let tmp = x
    x = y
    y = tmp

fn load_world( path: String ) raises -> World:
    var cubes = DynamicVector[Cube]()
    with open(path, "r") as f:
        let input = f.read().split("\n")
        f.close()

        for i in range(len(input)):
            var cube = parse_line( input[i] )
            # normalize cube
            if cube.start.x > cube.end.x:
                swap( cube.start.x, cube.end.x )
            cubes.append( cube )
    return World(cubes)

fn main() raises:
    var world = load_world( "./inputs/day22-input.txt" )
    print( "initial world:" )
    world.dump()
    print() # newline

    while True:
        let updated = world.update_world()
        if not updated:
            break

        if False: # debug
            print( "updated world:" )
            world.dump()
            print() # newline

    print( "settled world:" )
    world.dump()
    print() # newline

    if False: # debug
        print( "report supports:" )
        world.report_supports()
        print() # newline

    print( "part 1:" )
    world.solve_part1()

    print( "part 2:" )
    world.solve_part2()
