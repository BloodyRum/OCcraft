local ser = require "serialization"
local robot = require "robot"
local component = require "component"
local controller = component.inventory_controller
local arg = { ... }

f = io.open("/craft/recipies", "rb")
recipies = assert(ser.unserialize(f:read("*a")))
f:close()

function convertSlot(slot)
  if slot == 4 or slot == 5 or slot == 6 then
    slot = slot + 1
  elseif slot == 7 or slot == 8 or slot == 9 then
    slot = slot + 2
  end
  return slot
end

function clearSlots()
  for i=1, 16 do
    robot.select(i)
    robot.drop()
  end
  robot.select(1)
end

function getItem(itemToGrab, slot)
  for i=1, controller.getInventorySize(3) do
    if controller.getStackInSlot(3, i) then
      stackName = controller.getStackInSlot(3, i).label
      stackName = stackName:gsub(" ", "_")
      stackName = stackName:gsub("%(", "_")
      stackName = stackName:gsub("%)", "_")
      stackName = stackName:gsub("%.", "_")
      if itemToGrab == stackName then
        robot.select(convertSlot(slot))
        controller.suckFromSlot(3, i, 1)
        return
      end
    end
  end
  print("NEED AN(OTHER): " .. itemToGrab)
  craft(itemToGrab) --TODO, check if we can actually craft that item, i,e if it
  os.exit()         --s in /craft/recipies
end

item = arg[1] --TODO, do this right before we call the main function, and
item=item:gsub(" ", "_") -- Add the the gsubs to a function because another
item=item:gsub("%(", "_") -- function uses these exact gsubs
item=item:gsub("%)", "_")
item=item:gsub("%.", "_")

recpHistory = {}

inventorySize = controller.getInventorySize(3)

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

  robot.drop()
  if (#recpHistory > 0) then
    table.remove(recpHistory)
    craft(table.remove(recpHistory))
  end
end

craft(item)
