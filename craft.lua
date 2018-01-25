local ser = require "serialization"
local robot = require "robot"
local component = require "component"
local sides = require "sides"

local controller = component.inventory_controller
local arg = { ... }


r = io.open("/craft/recipies", "rb")
recipies = assert(ser.unserialize(r:read("*a")))
r:close()

c = io.open("/home/craftconfig", "rb")
config = assert(ser.unserialize(c:read("*a")))
c:close()


side = sides[config.side] or sides.front
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
  for i=1, 16 do
    robot.select(i)
    drop()
  end
  robot.select(1)
end

function convertUnderscore(convertedItem)
  convertedItem = convertedItem:gsub(" ", "_")
  convertedItem = convertedItem:gsub("%(", "_")
  convertedItem = convertedItem:gsub("%)", "_")
  convertedItem = convertedItem:gsub("%.", "_")
  return convertedItem
end

function getItem(itemToGrab, slot)
  for i=1, controller.getInventorySize(side) do
    if controller.getStackInSlot(side, i) then
      stackName = controller.getStackInSlot(side, i).label
      stackName = convertUnderscore(stackName)
      if itemToGrab == stackName then
        robot.select(convertSlot(slot))
        controller.suckFromSlot(side, i, 1)
        return
      end
    end
  end
  print("NEED AN(OTHER): " .. itemToGrab)
  craft(itemToGrab) --TODO, check if we can actually craft that item, i,e if it
  os.exit()         --s in /craft/recipies
end


recpHistory = {}

function craft(itemToCraft)
  table.insert(recpHistory, itemToCraft)
  if recipies[itemToCraft] then
    recipieSize = recipies[itemToCraft].items
  else
    if (itemToCraft == not nil) then
      print("ERROR, NO RECIPE FOR: " .. itemToCraft)
      os.exit()
    end
  end

  clearSlots()
  for i=1, recipieSize do
    if recipies[itemToCraft] then
      if recipies[itemToCraft][i] then
        getItem(recipies[itemToCraft][i], i)
      end
    end
  end
  robot.select(1)
  component.crafting.craft()

  drop()
  if (#recpHistory > 0) then
    table.remove(recpHistory)
    craft(table.remove(recpHistory))
  end
end

item=arg[1]
item = convertUnderscore(item)

craft(item)
