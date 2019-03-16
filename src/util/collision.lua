
-- Returns true if the objects' bounding circles are overlapping
local function objectsAreTouching(obj1, obj2)
 local dx = obj2.x - obj1.x
 local dy = obj2.y - obj1.y
 local distance = math.sqrt(dx * dx + dy * dy)
 return distance < obj1.radius + obj2.radius
end


-- https://2dengine.com/?p=intersections#Segment_vs_circle

local function pointOnSegment(px, py, x1, y1, x2, y2)
  local cx, cy = px - x1, py - y1
  local dx, dy = x2 - x1, y2 - y1
  local d = (dx*dx + dy*dy)
  if d == 0 then
    return x1, y1
  end
  local u = (cx*dx + cy*dy)/d
  if u < 0 then
    u = 0
  elseif u > 1 then
    u = 1
  end
  return x1 + u*dx, y1 + u*dy
end

local function pointInCircle(px, py, cx, cy, r)
  local dx, dy = px - cx, py - cy
  return dx*dx + dy*dy <= r*r
end

local function segmentVsCircle(x1, y1, x2, y2, cx, cy, cr)
  local qx, qy = pointOnSegment(cx, cy, x1, y1, x2, y2)
  return pointInCircle(qx, qy, cx, cy, cr)
end

return {
 objectsAreTouching = objectsAreTouching,
 segmentVsCircle = segmentVsCircle
}
