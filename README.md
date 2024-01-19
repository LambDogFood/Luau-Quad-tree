# QuadTree Module Documentation

```lua
-- Create a QuadTree with a rectangular boundary and a maximum capacity of 4 points.
local boundary = QuadTree.Rect(0, 0, 800, 600)
local maxCapacity = 4
local quadTree = QuadTree.new(boundary, maxCapacity)

-- Insert points into the QuadTree.
local point1 = QuadTree.Point(100, 100, {data = "A"})
local point2 = QuadTree.Point(200, 200, {data = "B"})
quadTree:Insert(point1)
quadTree:Insert(point2)

-- Find points within a rectangular range.
local rectRange = QuadTree.Rect(150, 150, 50, 50)
local foundPointsRect = quadTree:Find(rectRange)

-- Output the found points.
for _, point in ipairs(foundPointsRect) do
    print("Found Point (Rect):", point.x, point.y, "with data:", point.data.data)
}
```
