--//
--// Created by LordDogFood on 02/04/2025
--//

--!strict

local QuadTree = {}
QuadTree.__index = QuadTree

export type QRect = {
	x: number,
	y: number,
	w: number,
	h: number,

	Contains: (Point<any>) -> boolean,
	Intersects: (QRect) -> boolean,
}

function QuadTree.Rect(x: number, y: number, w: number, h: number): QRect
	local self = {
		x = x,
		y = y,
		w = w,
		h = h,
	}

	self.Contains = function(p: Point<any>): boolean
		return (
			p.x > self.x - self.w and
				p.x < self.x + self.w and
				p.y > self.y - self.h and
				p.y < self.y + self.h
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

export type Point<T> = {
	x: number,
	y: number,
	data: T?,
}

function QuadTree.Point<T>(x: number, y: number, data: T?): Point<T>
	local point = {
		x = x,
		y = y,
		data = data,
	}

	return point
end

export type QuadTree<T> = {
	
	_boundary: QRect,
	_capacity: number,
	_points: {Point<T>},
	_regions: {QuadTree<T>},
	_divided: boolean,

	_subdivide: (self: QuadTree<T>) -> (),
	Insert: (self: QuadTree<T>, point: Point<T>) -> boolean,
	Find: (self: QuadTree<T>, range: QRect, found: {Point<T>}) -> {Point<T>},
}

function QuadTree.new<T>(boundary: QRect, capacity: number): QuadTree<T>
	local self: any = setmetatable({
		_boundary = boundary,
		_capacity = capacity or 4,
		_points = {},
		_regions = {},
		_divided = false,
	}, QuadTree)
	return self :: QuadTree<T>
end


function QuadTree._subdivide<T>(self: QuadTree<T>)
	local x = self._boundary.x
	local y = self._boundary.y
	local w = self._boundary.w
	local h = self._boundary.h

	local ne = QuadTree.Rect(x + w / 2, y - h / 2, w / 2, h / 2)
	local nw = QuadTree.Rect(x - w / 2, y - h / 2, w / 2, h / 2)
	local se = QuadTree.Rect(x + w / 2, y + h / 2, w / 2, h / 2)
	local sw = QuadTree.Rect(x - w / 2, y + h / 2, w / 2, h / 2)

	self._regions[1] = QuadTree.new(ne, self._capacity)
	self._regions[2] = QuadTree.new(nw, self._capacity)
	self._regions[3] = QuadTree.new(se, self._capacity)
	self._regions[4] = QuadTree.new(sw, self._capacity)

	self._divided = true
end

function QuadTree.Insert<T>(self: QuadTree<T>, point: Point<T>): boolean
	
	if not self._boundary.Contains(point) then
		return false
	end

	if #self._points < self._capacity then
		table.insert(self._points, point)
		return true
	end

	if not self._divided then
		self:_subdivide()
	end

	for _, region in self._regions do
		local success = region:Insert(point)

		if success then
			return true
		end
	end
	
	return false
end

function QuadTree.Find<T>(self: QuadTree<T>, range: QRect, found: {Point<T>}?): {Point<T>}

	local result = found or {} :: {Point<T>}
	
	if self._boundary.Intersects(range) then
		for _, point in self._points do			
			if range.Contains(point) then
				table.insert(result, point)
			end
		end

		for _, region in self._regions do
			region:Find(range, result)
		end
	end

	return result
end

return QuadTree :: {
	new: <T>(boundary: QRect, capacity: number) -> QuadTree<T>,
	Point: <T>(x: number, y: number, data: T?) -> Point<T>,
	Rect: (x: number, y: number, w: number, h: number) -> QRect
}
