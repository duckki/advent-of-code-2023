from testing import assert_true

@value
struct Queue[T:CollectionElement](Sized):
    var items: DynamicVector[T]
    var begin: Int

    fn __init__(inout self):
        self.items = DynamicVector[T]()
        self.begin = 0

    fn __init__(inout self, capacity: Int):
        self.items = DynamicVector[T](capacity)
        self.begin = 0

    fn __len__(self) -> Int:
        return len(self.items) - self.begin

    fn enqueue(inout self, item: T):
        self.items.push_back(item)

    fn front(self) -> T: # Note: The return value can't be a reference, yet.
        return self.items[self.begin]

    fn remove_front(inout self) raises:
        assert_true( len(self) > 0 )
        self.begin += 1
        if self.begin == len(self.items):
            # reached the end of the underlying vector, reset state.
            self.items.clear()
            self.begin = 0

    fn dequeue(inout self) raises -> T:
        let item_idx = self.begin
        self.remove_front()
        # Note: It's safe to access the item at self.begin, even after removing the front
        return self.items[item_idx]

