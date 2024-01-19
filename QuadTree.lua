--[[

	QuadTree Module
	
	Description:
	Simple luau implementation of a QuadTree data structure, allowing you to find point within a distinct QRect object effeciently.

	Credits:
	- Author: Alex (LordDogFood)
	- Repository: [https://github.com/LambDogFood/Lua-Quad-tree]
	- Resources:
	  - JS Quad-Tree Implementation: [https://www.youtube.com/watch?v=OJxEcs0w_kE]
	  
	QuadTree Module Example Usage:

	-- Create a QuadTree with a rectangular boundary and a maximum capacity of 4 points.
	local boundary = QuadTree.Rect(0, 0, 800, 600)
	local maxCapacity = 4
	local quadTree = QuadTree.new(boundary, maxCapacity)

	-- Insert points into the QuadTree.
	local point1 = QuadTree.Point(100, 100, "A")
	local point2 = QuadTree.Point(200, 200, "B")
	quadTree:Insert(point1)
	quadTree:Insert(point2)

	-- Find points within a rectangular range.
	local range = QuadTree.Rect(150, 150, 50, 50)
	local foundPoints = quadTree:Find(range)

	-- Output the found points.
	for _, point in ipairs(foundPoints) do
	    print("Found Point:", point.x, point.y, "with data:", point.data)
	end

--]]

local QuadTree = {}
local QuadTree_mt = {}
QuadTree_mt.__index = QuadTree_mt

export type Point = {
	x: number,
	y: number,
	data: any?
}

export type QRect = {
	x: number,
	y: number,
	w: number,
	h: number,
	
	Contains: (Point) -> boolean,
	Intersects: (QRect) -> boolean,
}

local function point(x, y, data)
	local point = {
		x = x,
		y = y,
		data = data,
	}

	return point
end

local function rect(x, y, w, h)
	local self = {
		x = x,
		y = y,
		w = w,
		h = h,
	}

	self.Contains = function(p: Point): boolean
		return (
			p.x >= self.x - self.w and
			p.x <= self.x + self.w and
			p.y >= self.y - self.h and
			p.y <= self.y + self.h
		)
	end

	self.Intersects = function(rect: QRect): boolean
		return not (
			rect.x - rect.w > self.x + self.w or
			rect.x + rect.w < self.x - self.w or
			rect.y - rect.h > self.y + self.h or
			rect.y + rect.h < self.y - self.h
		)
	end

	return self
end

function QuadTree_mt:Subdivide()
	local x = self.boundary.x
	local y = self.boundary.y
	local w = self.boundary.w
	local h = self.boundary.h

	local ne = rect(x + w / 2, y - h / 2, w / 2, h / 2)
	local nw = rect(x - w / 2, y - h / 2, w / 2, h / 2)
	local se = rect(x + w / 2, y + h / 2, w / 2, h / 2)
	local sw = rect(x - w / 2, y + h / 2, w / 2, h / 2)

	self.regions[1] = QuadTree.new(ne, self.capacity)
	self.regions[2] = QuadTree.new(nw, self.capacity)
	self.regions[3] = QuadTree.new(se, self.capacity)
	self.regions[4] = QuadTree.new(sw, self.capacity)

	self.divided = true
end

function QuadTree_mt:Insert(point)

	if not self.boundary.Contains(point) then
		return false
	end

	if #self.points < self.capacity then
		table.insert(self.points, point)
		return true
	end

	if not self.divided then
		self:Subdivide()
	end

	for _, region in self.regions do 
		local success = region:Insert(point)

		if success then
			return true
		end
	end

	return false
end

function QuadTree_mt:Find(range, found)
	if not found then
		found = {}
	end

	if self.boundary.Intersects(range) then
		for _, point in self.points do
			if range.Contains(point) then
				table.insert(found, point)
			end
		end

		for _, region in self.regions do
			region:Find(range, found)
		end
	end

	return found
end

function QuadTree.new(boundary, capacity)
	local self = {
		boundary = boundary,
		capacity = capacity or 4,
		points = {},
		regions = {},
		divided = false,
	}; setmetatable(self, QuadTree_mt)
	return self
end

QuadTree.Point = point
QuadTree.Rect = rect

export type QuadTree = {
	Subdivide: () -> (),
	Insert: (Point: Point) -> boolean,
	Find: (Range: QRect) -> {Point?}
}

return QuadTree :: {
	new: (Boundary: QRect, MaxCapacity: number) -> QuadTree,
	Point: (x: number, y: number, data: any?) -> Point,
	Rect: (x: number, y: number, w: number, h: number) -> QRect,
}
