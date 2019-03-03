
-- Returns true if the objects' bounding circles are overlapping
local function objectsAreTouching(obj1, obj2)
 local dx = obj2.x - obj1.x
 local dy = obj2.y - obj1.y
 local distance = math.sqrt(dx * dx + dy * dy)
 return distance < obj1.radius + obj2.radius
end

return {
 objectsAreTouching = objectsAreTouching
}