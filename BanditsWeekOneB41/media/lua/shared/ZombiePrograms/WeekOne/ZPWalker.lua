ZombiePrograms = ZombiePrograms or {}

ZombiePrograms.Walker = {}
ZombiePrograms.Walker.Stages = {}

ZombiePrograms.Walker.Init = function(bandit)
end

ZombiePrograms.Walker.GetCapabilities = function()
    -- capabilities are program decided
    local capabilities = {}
    capabilities.melee = false
    capabilities.shoot = false
    capabilities.smashWindow = not BWOPopControl.Police.On
    capabilities.openDoor = true
    capabilities.breakDoor = not BWOPopControl.Police.On
    capabilities.breakObjects = not BWOPopControl.Police.On
    capabilities.unbarricade = false
    capabilities.disableGenerators = false
    capabilities.sabotageCars = false
    return capabilities
end

ZombiePrograms.Walker.Prepare = function(bandit)
    local tasks = {}
    local world = getWorld()
    local cell = getCell()
    local cm = world:getClimateManager()
    local dls = cm:getDayLightStrength()
    local id = BanditUtils.GetCharacterID(bandit)
    local weapons = Bandit.GetWeapons(bandit)

    if math.abs(id) % 13 == 0 and not bandit:isFemale() then
        local brain = BanditBrain.Get(bandit)
        brain.bag = "Briefcase"
        local fakeItem = BanditCompatibility.InstanceItem("Base.Briefcase")
        --local fakeItem = BanditCompatibility.InstanceItem("Base.Briefcase")
        --local fakeItem = BanditCompatibility.InstanceItem("Base.Flightcase")
        --local fakeItem = BanditCompatibility.InstanceItem("Base.Cooler")
        bandit:setPrimaryHandItem(fakeItem)
    elseif math.abs(id) % 5 == 0 and bandit:isFemale() then
        weapons.melee = "Base.PurseWeapon"
        local task = {action="Equip", itemPrimary=weapons.melee}
        table.insert(tasks, task)
    end

    Bandit.ForceStationary(bandit, false)

    return {status=true, next="Main", tasks=tasks}
end

ZombiePrograms.Walker.Main = function(bandit)
    local ts = getTimestampMs()

    local tasks = {}

    local cell = bandit:getCell()
    local id = BanditUtils.GetCharacterID(bandit)
    local bx = bandit:getX()
    local by = bandit:getY()
    local bz = bandit:getZ()
    local gameTime = getGameTime()
    local hour = gameTime:getHour()
    local minute = gameTime:getMinutes()

    local walkType = "Walk"
    local endurance = 0
    if BWOScheduler.NPC.Run then 
        walkType = "Run"
        endurance = -0.06
    end
    
    local health = bandit:getHealth()
    if health < 0.8 then
        walkType = "Limp"
        endurance = 0
    end 


    -- if 9 to 5 burgerflipper mode:
    local foundWorkplace = 0
    local distFromWork = 1000
    local dist2B = 1000
    local home2Coords
    local brain = BanditBrain.Get(bandit)
        

    for key, eb in pairs(GetBWOModData().EventBuildings) do
        if eb.event == "home2" and eb.x and eb.y then
            foundWorkplace = 1
            home2Coords = BWOBuildings.GetEventBuildingCoords("home2"); print('home2Coords.x=' .. home2Coords.x .. ' and home2Coords.y=' .. home2Coords.y)
            dist2B = BanditUtils.DistTo(bx, by, home2Coords.x, home2Coords.y)
            break
        end
    end

    -- syncData.id = brain.id
    -- syncData.program = brain.program
    if brain.loot[1] ~= "Base.Paperbag_Spiffos" and brain.loot[1] ~= "Base.Paperbag_Jays" and brain.loot[1] ~= "Base.PaperBag" then
        if brain.weapons.melee == "Base.Paperbag_Spiffos" or brain.weapons.melee == "Base.Paperbag_Jays" or brain.weapons.melee == "Base.PaperBag" then
            print('eat the ' .. menuRecipePicked)
            anim = "Eat"
            sound = "Eating"
            item = menuRecipePicked

            local task = {action="TimeItem", anim=anim, sound=sound, item=item, left=true, time=100}
            table.insert(tasks, task)
            brain.loot[1] = "Base.PaperBag"
            return {status=true, next="Main", tasks=tasks}
        end

    end


    if brain.loot[1] == "Base.Paperbag_Spiffos" or brain.loot[1] == "Base.Paperbag_Jays" or brain.loot[1] == "Base.PaperBag" then
        -- if dist2B > 120 then
        --     brain.loot[1] = "Base.Money"
        -- end
    end

    -- 

    local stressEatingNeed = brain.bornCoords.z

    -- if NPC is NOT ALREADY holding a paper bag in their loot slot 1 (which would indicate that they have already been recently given a meal which they have eaten and stuffed the bag it came inside into their pocket) then they can move towards the player to get a meal:

    if brain.loot[1] ~= "Base.Paperbag_Spiffos" and brain.loot[1] ~= "Base.Paperbag_Jays" and brain.loot[1] ~= "Base.PaperBag" then
        if stressEatingNeed > 120 and stressEatingNeed < 190 and foundWorkplace == 1 then
            print("stressEatingNeed for " .. brain.fullname .. " is: " .. stressEatingNeed .. " ...therefore")
            dist2B = BanditUtils.DistTo(bx, by, home2Coords.x, home2Coords.y)
            distFromWork = BanditUtils.DistTo(getSpecificPlayer(0):getX(), getSpecificPlayer(0):getY(), home2Coords.x, home2Coords.y)
            
            home2Coords = BWOBuildings.GetEventBuildingCoords("home2"); print(brain.fullname .. ': home2Coords.x=' .. home2Coords.x .. ' and home2Coords.y=' .. home2Coords.y .. " and dist2B is " .. tostring(dist2B) .. " and distFromWork is " .. tostring(distFromWork))
            
            if distFromWork < 140 and dist2B < 140 then
                local cell = getCell(); local square = cell:getGridSquare(getPlayer(0):getX(), getPlayer(0):getY(), 0); local room = square:getRoom(); if room == nil then print('room is nil'); else print("BWORooms.IsRestaurant(room) is " .. tostring(BWORooms.IsRestaurant(room))); print("room:getName() is: " .. tostring(room:getName())); end

                print("player is " .. distFromWork .. " dist from work and npc is " .. dist2B .. " dist from work so they can head towards work since their stress is " .. stressEatingNeed )
                if room ~= nil then

                    local cell = getCell(); local square = cell:getGridSquare(getPlayer(0):getX(), getPlayer(0):getY(), 0); local room = square:getRoom()
                    
                    if BWORooms.IsRestaurant(room) == false then 
                        print('room is not a restaurant')
                    else 
                        print("BWORooms.IsRestaurant(room) is " .. tostring(BWORooms.IsRestaurant(room)))

                        -- local cell = getCell(); local square = cell:getGridSquare(getPlayer(0):getX(), getPlayer(0):getY(), 0); local room = square:getRoom(); if room == nil then print('room is nil'); else print("BWORooms.IsRestaurant(room) is " .. tostring(BWORooms.IsRestaurant(room))); end


                        local cell = getCell(); local square = cell:getGridSquare(getPlayer(0):getX(), getPlayer(0):getY(), 0); local room = square:getRoom(); print("BWORooms.IsRestaurant(room) is " .. tostring(BWORooms.IsRestaurant(room)))

                        -- this should generate something like 'cafe' if used in the Lua console (if you are within a breakfast diner):
                        local cell = getCell(); local square = cell:getGridSquare(getPlayer(0):getX(), getPlayer(0):getY(), 0); local room = square:getRoom():getName(); print("mainFoodsForWorkplaceType should be determined by the room type we are currently in, which is: " .. tostring(room))

                        local mainFoodsForWorkplaceType = {"Base.Sandwich", "Base.BurgerRecipe", "farming.Salad"}; local menuRecipePickedIndex = math.abs(brain.id) % (#mainFoodsForWorkplaceType); if menuRecipePickedIndex == 0 then menuRecipePickedIndex = (#mainFoodsForWorkplaceType); end; menuRecipePicked = mainFoodsForWorkplaceType[menuRecipePickedIndex]
                        
                        local cashRegisterX = getSpecificPlayer(0):getX(); local cashRegisterY = getSpecificPlayer(0):getY()
                        local bufferDist = 2; 

                        -- local square = cell:getGridSquare(getPlayer(0):getX(), getPlayer(0):getY(), 0)

                        -- ----------------------------------------------------------------
                        
                        -- ----------------------------------------------------------------
                        
                        -- local objects = square:getObjects()
                        -- 
                        -- local facing
                        -- local cashRegisterX = 0; local cashRegisterY = 0
                        -- local bufferDist = 1
                        -- for i=0, objects:size()-1 do
                        --     local object = objects:get(i)
                        --     local sprite = object:getSprite()
                        --     if sprite then
                        --         local props = sprite:getProperties()
                        --         if props:Is("CustomName") then
                        --             local customName = props:Val("CustomName")
                        --             if customName == "Register" then
                        --                 lineToOrderFood = object
                        --                 print('Cash register location where customers line up to order food is at X=')
                        --                 -- cashRegisterX = getCell():getGridSquare(getSpecificPlayer(0):getX() + cashRegisterX, getSpecificPlayer(0):getY() + cashRegisterY, 0):getObjects():get(1):getX()
                        --                 cashRegisterX = object:getX()

                        --                 -- cashRegisterY = getCell():getGridSquare(getSpecificPlayer(0):getX() + cashRegisterX, getSpecificPlayer(0):getY() + cashRegisterY, 0):getObjects():get(1):getY()
                        --                 cashRegisterY = object:getY()

                        --                 facing = props:Val("Facing")
                        --                 if facing == "N" then
                        --                     cashRegisterX = cashRegisterX - bufferDist
                        --                     cashRegisterY = cashRegisterY + bufferDist
                        --                 end
                        --                 if facing == "E" then
                        --                     cashRegisterX = cashRegisterX - bufferDist
                        --                     cashRegisterY = cashRegisterY - bufferDist
                        --                 end
                        --                 if facing == "S" then
                        --                     cashRegisterX = cashRegisterX + bufferDist
                        --                     cashRegisterY = cashRegisterY - bufferDist
                        --                 end
                        --                 if facing == "W" then
                        --                     cashRegisterX = cashRegisterX + bufferDist
                        --                     cashRegisterY = cashRegisterY + bufferDist
                        --                 end
                        --                 break
                        --             end
                        --         end
                        --     end
                        -- end
                            
                        -- ----------------------------------------------------------------
                        
                        -- ----------------------------------------------------------------

                        local dist2C = BanditUtils.DistTo(cashRegisterX, cashRegisterY, bx, by)
                        
                        if getPlayer(0) and BanditUtils.LineClear(bandit, getPlayer(0)) then
                            print('cashRegisterX is: ' .. cashRegisterX .. ' .....and cashRegisterY is: ' .. cashRegisterY)
                            print('getPlayer(0) is: ' .. getPlayer(0):getX() .. ' .....and getPlayer(0):getY() is: ' .. getPlayer(0):getY())
                            print('bx is: ' .. bx .. ' .....and by is: ' .. by)

                            print('ok clear line to square, so we can send our NPC towards the player to order food!')
                            if distFromWork < 140 then
                                print('ok triggered if conditional 1 for moving towards cashRegister!')
                                if dist2C >= bufferDist then
                                    print('ok triggered if conditional 2 for moving towards cashRegister!')
                                    print('distance of NPC from cashRegister is:' .. dist2C)

                                    walkType = "Walk"
                                    table.insert(tasks, BanditUtils.GetMoveTask(endurance, cashRegisterX, cashRegisterY, 0, walkType, dist2C, false))
                                    return {status=true, next="Main", tasks=tasks}
                                else
                                    print('ok triggered if conditional 3 for moving towards cashRegister!')
                                    local rn = ZombRand(5)
                                    local anim
                                    local item
                                    local sound
                                    if rn == 0 then
                                        anim = "WaveHi"
                                    elseif rn == 1 then
                                        anim = "No"
                                    elseif rn == 2 then
                                        anim = "Yes"
                                    elseif rn == 3 then
                                        if brain.loot[1] == menuRecipePicked then 
                                            print('eat the ' .. menuRecipePicked)
                                            anim = "Eat"
                                            sound = "Eating"
                                            item = menuRecipePicked
                                        end
                                        local DeliveryHour = ModData.getOrCreate("FoodDeliveryTimes")[brain.id].hour
                                        local DeliveryMinute = ModData.getOrCreate("FoodDeliveryTimes")[brain.id].minute; print("DeliveryMinute is: " .. DeliveryMinute)

                                        local OrderHour = ModData.getOrCreate("FoodOrderTimes")[brain.id].hour
                                        local OrderMinute = ModData.getOrCreate("FoodOrderTimes")[brain.id].minute
                                        
                                        -- if DeliveryHour >= OrderHour or DeliveryMinute >= OrderMinute then
                                        --     print('')
                                        --     if hour > DeliveryHour or minute > (DeliveryMinute + 10) then
                                        --         brain.loot[1] = brain.weapons.melee
                                        --         brain.weapons.melee = nil
                                        --     end
                                        -- end
                                    elseif rn > 3 then
                                        anim = "Drink"
                                        sound = "DrinkingFromBottle"
                                        item = "Bandits.BeerBottle"
                                    end
                                    
                                    local task = {action="TimeItem", anim=anim, sound=sound, item=item, left=true, time=100}
                                    table.insert(tasks, task)
                                    return {status=true, next="Main", tasks=tasks}
                                end
                            else
                                print('ok triggered if conditional 3 asquare generation for adjancent free time finder')
                                local asquare = AdjacentFreeTileFinder.Find(getPlayer(0), bandit)
                                if asquare then
                                    print('ok triggered if conditional 3B asquare generation for adjancent free time finder')
                                    local dist = math.sqrt(math.pow(bandit:getX() - (square:getX() + 0.5), 2) + math.pow(bandit:getY() - (square:getY() + 0.5), 2))
                                    if dist > 1.20 then
                                        print('ok triggered if conditional 3C - GETTING MOVE-TASK FROM asquare generation for adjancent free time finder')
                                        table.insert(tasks, BanditUtils.GetMoveTask(0, asquare:getX(), asquare:getY(), asquare:getZ(), "Walk", dist, false))
                                        print ("WALKER 7: " .. (getTimestampMs() - ts))
                                        return {status=true, next="Main", tasks=tasks}
                                    else
                                        print('ok triggered if conditional 3D - SMOKING - asquare generation for adjancent free time finder')
                                        local task = {action="Smoke", anim="Smoke", item="Bandits.Cigarette", left=true, time=100}
                                        table.insert(tasks, task)
                                        return {status=true, next="Main", tasks=tasks}

                                        -- local subTasks = BanditPrograms.Bench(bandit)
                                        -- if #subTasks > 0 then
                                        --     for _, subTask in pairs(subTasks) do
                                        --         table.insert(tasks, subTask)
                                        --     end
                                        --     return {status=true, next="Main", tasks=tasks}
                                        -- end
                                    end
                                end
                            end
                        end

                    end


                end
                
                -- chair/bench rest
                if BWOScheduler.SymptomLevel < 4 then 
                    local subTasks = BanditPrograms.Bench(bandit)
                    if #subTasks > 0 then
                        for _, subTask in pairs(subTasks) do
                            table.insert(tasks, subTask)
                        end
                        return {status=true, next="Main", tasks=tasks}
                    end
                end

            end
        end
    end

    if bandit:isOutside() then
        if brain.weapons.melee == "Base.Paperbag_Spiffos" or brain.weapons.melee == "Base.Paperbag_Jays" or brain.weapons.melee == "Base.PaperBag" then
            local babe1 = BanditZombie.GetInstanceById(BanditUtils.GetClosestBanditLocationProgram(getSpecificPlayer(0), {"Walker", "Runner", "Inhabitant", "Active", "Babe"}).id);
            babe1:setPrimaryHandItem(nil);
            -- weapons.melee = "Base.Fork"

            brain.weapons.melee = BanditBrain.Get(BanditZombie.GetInstanceById( BanditUtils.GetClosestBanditLocationProgram(getSpecificPlayer(0), {"Walker", "Runner", "Inhabitant", "Active", "Babe"}).id)).loot[4]
            

            local task = {action="Equip", itemPrimary=brain.weapons.melee}
            table.insert(tasks, task)

        end
    end

    local stress = BanditBrain.Get(BanditZombie.GetInstanceById(BanditUtils.GetClosestBanditLocationProgram(getSpecificPlayer(0), {"Walker", "Runner", "Inhabitant", "Active", "Babe"}).id)).bornCoords.z

    -- if inside building change program
    if not bandit:isOutside() then
        if brain.loot[1] ~= "Base.Paperbag_Spiffos" and brain.loot[1] ~= "Base.Paperbag_Jays" and brain.loot[1] ~= "Base.PaperBag" then
            if stressEatingNeed < 140 or dist2B > 25 or stressEatingNeed > 185 then
                Bandit.ClearTasks(bandit)
                Bandit.SetProgram(bandit, "Inhabitant", {})

                
                local syncData = {}
                syncData.id = brain.id
                syncData.program = brain.program
                Bandit.ForceSyncPart(bandit, syncData)
                return {status=true, next="Main", tasks=tasks}
            end
        else
            if stress > 190 and dist2B < 200 then
                if brain.hostile == false then
                    brain.hostile = true
                    local rn = ZombRand(100)
                    if rn < 20 then
                        local task = {action="Time", anim="PainTorso", time=15}
                        table.insert(tasks, task)
                        return tasks
                    elseif rn < 30 then
                        local task = {action="Time", anim="PainStomach1", time=15}
                        table.insert(tasks, task)
                        return tasks
                    elseif rn < 40 then
                        local task = {action="Time", anim="PainStomach2", time=15}
                        table.insert(tasks, task)
                        return tasks
                    else
                        local sound = "ZSVomit" .. (1 + ZombRand(4))
                        local task = {action="Vomit", anim="Vomit", sound=sound, time=25}
                        table.insert(tasks, task)
                        return tasks
                    end
                else
                    if brain.weapons.melee == "Base.Paperbag_Spiffos" then
                        brain.weapons.melee = BanditBrain.Get(BanditZombie.GetInstanceById( BanditUtils.GetClosestBanditLocationProgram(getSpecificPlayer(0), {"Walker", "Runner", "Inhabitant", "Active", "Babe"}).id)).loot[4]

                        brain.program.name = "Active"

                        local task = {action="Equip", itemPrimary=brain.weapons.melee}
                        table.insert(tasks, task) 
                        return tasks
                        
                        -- Bandit.SetProgram(bandit, "Active", {})
                        -- Bandit.SetHostile(bandit, true)


                    end

                end
                
                
            end
        end
    end

    if stress > 250 and brain.hostile == false then
        brain.hostile = true
        brain.program.name = "Active"
    end
    -- print ("WALKER 1: " .. (getTimestampMs() - ts))

    -- if has a specifit outfit change program
    --[[
    local outfit = bandit:getOutfitName()
    if outfit == "Postal" then
        Bandit.ClearTasks(bandit)
        Bandit.SetProgram(bandit, "Postal", {})

        local brain = BanditBrain.Get(bandit)
        local syncData = {}
        syncData.id = brain.id
        syncData.program = brain.program
        Bandit.ForceSyncPart(bandit, syncData)
        return {status=true, next="Main", tasks=tasks}
    elseif outfit == "Farmer" then
        Bandit.ClearTasks(bandit)
        Bandit.SetProgram(bandit, "Gardener", {})

        local brain = BanditBrain.Get(bandit)
        local syncData = {}
        syncData.id = brain.id
        syncData.program = brain.program
        Bandit.ForceSyncPart(bandit, syncData)
        return {status=true, next="Main", tasks=tasks}
    end]]
    
    -- symptoms
    if math.abs(id) % 4 > 0 then
        if BWOScheduler.SymptomLevel == 3 then
            walkType = "Limp"
        elseif BWOScheduler.SymptomLevel >= 4 then
            walkType = "Scramble"
        end

        local subTasks = BanditPrograms.Symptoms(bandit)
        if #subTasks > 0 then
            for _, subTask in pairs(subTasks) do
                table.insert(tasks, subTask)
            end
            
            return {status=true, next="Main", tasks=tasks}
        end
    else
        if BWOScheduler.SymptomLevel >= 4 then walkType = "Run" end
    end
    -- print ("WALKER 2: " .. (getTimestampMs() - ts))
    
    -- react to events
    if BWOScheduler.SymptomLevel < 4 then
        local subTasks = BanditPrograms.Events(bandit)
        if #subTasks > 0 then
            for _, subTask in pairs(subTasks) do
                table.insert(tasks, subTask)
            end
            return {status=true, next="Main", tasks=tasks}
        end
    end
    -- print ("WALKER 3: " .. (getTimestampMs() - ts))


    -- atm
    if BWOScheduler.SymptomLevel < 4 then
        local subTasks = BanditPrograms.ATM(bandit)
        if #subTasks > 0 then
            for _, subTask in pairs(subTasks) do
                table.insert(tasks, subTask)
            end
            return {status=true, next="Main", tasks=tasks}
        end
    end
    -- print ("WALKER 4: " .. (getTimestampMs() - ts))




    -- grill time
    if BWOScheduler.SymptomLevel < 3 and ((hour >= 12 and hour < 15) or (hour >= 18 and hour < 23)) then
        local target = BWOObjects.FindGMD(bandit, "barbecue")
        if target.x and target.y and target.z and target.dist < 20 then
            local square = cell:getGridSquare(target.x, target.y, target.z)
            if square and BanditUtils.LineClear(bandit, square) then
                local objects = square:getObjects()
                for i=0, objects:size()-1 do
                    local object = objects:get(i)
                    if instanceof(object, "IsoBarbecue") then
                        if object:isLit() then
                            if target.dist >= 5 then
                                walkType = "Walk"
                                table.insert(tasks, BanditUtils.GetMoveTask(endurance, target.x, target.y, target.z, walkType, target.dist, false))
                                return {status=true, next="Main", tasks=tasks}
                            else
                                local rn = ZombRand(5)
                                local anim
                                local item
                                local sound
                                if rn == 0 then
                                    anim = "WaveHi"
                                elseif rn == 1 then
                                    anim = "No"
                                elseif rn == 2 then
                                    anim = "Yes"
                                elseif rn == 3 then
                                    anim = "Eat"
                                    sound = "Eating"
                                    item = "Base.Steak"
                                elseif rn == 4 then
                                    anim = "Drink"
                                    sound = "DrinkingFromBottle"
                                    item = "Bandits.BeerBottle"
                                end
                                local task = {action="TimeItem", anim=anim, sound=sound, item=item, left=true, time=100}
                                table.insert(tasks, task)
                                return {status=true, next="Main", tasks=tasks}
                            end
                        else
                            local asquare = AdjacentFreeTileFinder.Find(square, bandit)
                            if asquare then
                                local dist = math.sqrt(math.pow(bandit:getX() - (square:getX() + 0.5), 2) + math.pow(bandit:getY() - (square:getY() + 0.5), 2))
                                if dist > 1.20 then
                                    table.insert(tasks, BanditUtils.GetMoveTask(0, asquare:getX(), asquare:getY(), asquare:getZ(), "Walk", dist, false))
                                    print ("WALKER 7: " .. (getTimestampMs() - ts))
                                    return {status=true, next="Main", tasks=tasks}
                                else
                                    local task = {action="BarbecueLit", anim="Loot", x=object:getX(), y=object:getY(), z=object:getZ(), time=100}
                                    table.insert(tasks, task)
                                    return {status=true, next="Main", tasks=tasks}
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    -- print ("WALKER 8: " .. (getTimestampMs() - ts))

    -- chair/bench rest
    if BWOScheduler.SymptomLevel < 4 then 
        local subTasks = BanditPrograms.Bench(bandit)
        if #subTasks > 0 then
            for _, subTask in pairs(subTasks) do
                table.insert(tasks, subTask)
            end
            return {status=true, next="Main", tasks=tasks}
        end
    end
    -- print ("WALKER 9: " .. (getTimestampMs() - ts))

    -- interact with players and other npcs
    -- dont do it on the street tho
    if BWOScheduler.SymptomLevel < 3 then
        --local groundType = BanditUtils.GetGroundType(bandit:getSquare())
        --if groundType ~= "street" then
            local subTasks = BanditPrograms.Talk(bandit)
            if #subTasks > 0 then
                for _, subTask in pairs(subTasks) do
                    table.insert(tasks, subTask)
                end
                return {status=true, next="Main", tasks=tasks}
            end
        --end
    end
    -- print ("WALKER 10: " .. (getTimestampMs() - ts))

    -- most pedestrian will follow the street / road, some will just "gosomwhere" for variability
    --
    if math.floor(math.abs(id) / hour) % 4 > 0 then
        local subTasks = BanditPrograms.FollowRoad(bandit, walkType)
        if #subTasks > 0 then
            for _, subTask in pairs(subTasks) do
                table.insert(tasks, subTask)
            end
            return {status=true, next="Main", tasks=tasks}
        end
    end
    -- print ("WALKER 11: " .. (getTimestampMs() - ts))
    -- go somewhere if no road is found

    local subTasks = BanditPrograms.GoSomewhere(bandit, walkType)
    if #subTasks > 0 then
        for _, subTask in pairs(subTasks) do
            table.insert(tasks, subTask)
        end
        return {status=true, next="Main", tasks=tasks}
    end
    -- print ("WALKER 12: " .. (getTimestampMs() - ts))

    -- fallback
    local subTasks = BanditPrograms.FallbackAction(bandit)
    if #subTasks > 0 then
        for _, subTask in pairs(subTasks) do
            table.insert(tasks, subTask)
        end
    end

    -- print ("WALKER 13: " .. (getTimestampMs() - ts))
    return {status=true, next="Main", tasks=tasks}
end
