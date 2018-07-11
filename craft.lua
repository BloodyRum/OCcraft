local component = require "component"
local robot = require "robot"
local ser = require "serialization"
local sides = require "sides"

local arg = { ... }
local controller = component.inventory_controller


r = io.open("/home/recipes", "rb")
recipes = assert(ser.unserialize(r:read("*a")))
r:close()

cache = {}

side = sides[recipes.side] or sides.front
function drop()
  if side == sides.front then
    robot.drop()
  elseif side == sides.bottom then
    robot.dropDown()
  elseif side == sides.top then
    robot.dropUp()
  end
end

function convertSlot(slot)
  if slot > 3 and slot < 7 then
    slot = slot + 1
  elseif slot > 6 and slot < 10 then
    slot = slot + 2
  end
  return slot
end

function clearSlots()
  for i=1, 9 do
    robot.select(convertSlot(i))
    drop()
  end
  robot.select(1)
end

function replacePrs(workString)
  workString = workString:gsub(" ", "_"):gsub("%(", "_"):gsub("%)", "_"):gsub("%.", "_")
  return workString
end

function checkItem(item, invSlot)
  if controller.getStackInSlot(side, invSlot) then
    stackName = replacePrs(controller.getStackInSlot(side, invSlot).label)
    if item == stackName then
      return true
    else
      return false
    end
  end
end
  
function getItem(itemToGrab, slot)
  location = nil
  if checkItem(itemToGrab, cache[itemToGrab]) then
    location = cache[itemToGrab]
  else
    for i=1, controller.getInventorySize(side) do
      if checkItem(itemToGrab, i) == true then
        cache[itemToGrab] = i
        location = i 
      end
    end
  end

  if location then --Found the item, weather in cache or not
    robot.select(convertSlot(slot))
    controller.suckFromSlot(side, location, 1)
  else -- Could not find item, must try to make it now
    print("NEED A(N(OTHER)}: " .. itemToGrab)
    craft(itemToGrab)
    os.exit() -- <<--Will only get called after the last item is made
  end
end

recpHistory = {}

function craft(itemToCraft)
  table.insert(recpHistory, itemToCraft)
  if not recipes[itemToCraft] then
    print("ERROR, NO RECIPE FOR: " .. itemToCraft)
    os.exit()
  end

  clearSlots()
  for i=1, recipes[itemToCraft].items  do
    if recipes[itemToCraft][i] then
      getItem(recipes[itemToCraft][i], i)
    end
  end
  
  robot.select(1)
  component.crafting.craft()
  drop()

  table.remove(recpHistory)
  if (#recpHistory > 0) then
    craft(table.remove(recpHistory))
  end
end


craft(replacePrs(arg[1]))
