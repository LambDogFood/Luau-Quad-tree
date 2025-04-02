# QuadTree (Luau)

A generic, efficient 2D QuadTree spatial partitioning module written in **strict-typed Luau**.

Useful for optimizing:
- 2D collision detection
- Range-based querying (e.g. nearby objects, units, bullets)
- RTS-style entity selection
- Spatial culling and optimization

---

## Features

- ✅ Fully typed with Luau generics
- ✅ `--!strict` support
- ✅ Efficient recursive subdivision
- ✅ Fast rectangular queries (`Find`)
- ✅ Clean, minimal API
- ✅ Easy to extend

---

## Example Usage

```lua
local QuadTree = require(ReplicatedStorage.QuadTree)

local boundary = QuadTree.Rect(0, 0, 800, 600)
local tree = QuadTree.new(boundary, 4)

tree:Insert(QuadTree.Point(100, 100, "A"))
tree:Insert(QuadTree.Point(200, 200, "B"))

local range = QuadTree.Rect(150, 150, 100, 100)
local found = tree:Find(range)

for _, point in found do
	print(point.x, point.y, point.data)
end
```

---
## API Reference

### Constructor

```lua
QuadTree.new<T>(boundary: QRect, capacity: number): QuadTree<T>
```
Creates a new QuadTree instance with a defined rectangular area and point capacity.

---
### Static Utilities

```lua
QuadTree.Rect(x: number, y: number, w: number, h: number): QRect
QuadTree.Point<T>(x: number, y: number, data: T?): Point<T>
```
- Rect creates a boundary rectangle
- Point creates a typed point object

---
### Instance Methods

```lua
QuadTree:Insert(point: Point<T>): boolean
QuadTree:Find(range: QRect, found?: { Point<T> }): { Point<T> }
```
- Insert: Adds a point to the tree
- Find: Retrieves all points within a given rectangular range

---
### QRect Methods

```lua
QRect:Contains(Point<any>): boolean
QRect:Intersects(QRect): boolean
```

---
## Inspiration
[Coding Train - QuadTrees in JavaScript](https://www.youtube.com/watch?v=OJxEcs0w_kE)

---
## Author
Alex (LordDogFood)
GitHub: [@LambDogFood](https://github.com/LambDogFood)

---
## License
MIT License
Free to use, modify and distribute.




























