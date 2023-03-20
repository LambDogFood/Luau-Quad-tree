--@ LordDogFood [20/03/23]

local QuadTree = {}
local QuadTree_mt = {}

local point = require(script.Point)
local rect = require(script.Rect)

function QuadTree_mt:subdivide()
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

function QuadTree_mt:insert(point)
	
	if not self.boundary.contains(point) then
		return false
	end
	
	if #self.points < self.capacity then
		table.insert(self.points, point)
		return true
	end
	
	if not self.divided then
		self:subdivide()
	end
		
	for _, region in self.regions do 
		local success = region:insert(point)
			
		if success then
			return true
		end
	end
	
	return false
end

function QuadTree_mt:find(range, found)
	if not found then
		found = {}
	end
	
	if self.boundary.intersects(range) then
		for _, point in self.points do
			if range.contains(point) then
				table.insert(found, point)
			end
		end
		
		for _, region in self.regions do
			region:find(range, found)
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
	}
	return setmetatable(self, {__index = QuadTree_mt})
end

QuadTree.Point = point
QuadTree.Rect = rect
return QuadTree
