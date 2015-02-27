init start
    local depotBackpack     =   "brocade backpack" -- bp name or loot destination
    local lootBackpack      =   "red backpack"     -- bp name or loot destination
    local stackBackpack     =   "green backpack"   -- bp name or loot destination
    local raresBackpack     =   "blue backpack"    -- bp name or loot destination
    local depositItems      =   ""         -- categories or {items list}

    -- DO NOT EDIT BELOW --

    --local SCRIPT_VERSION = "1.0.0"
    local debugMode, debugmsg = true, '' -- for script developers
    local tempItems, typeItems = {}, type(depositItems)

    if typeItems == 'string' then
        foreach lootingitem item depositItems do
            if item.id > 0 then
                if not (item.id == 3031 or item.id == 3035 or item.id == 3043) then
                    table.insert(tempItems, item.id)
                end
            elseif debugMode then
                debugmsg = debugmsg .. sprintf('Depositer Issue: Could\'t find item named %q.\n', item.name)
            end
        end
    elseif typeItems == 'table' then
        for _, item in ipairs(depositItems) do
            local itemID = itemid(item)

            if itemID > 0 then
                if not (itemID == 3031 or itemID == 3035 or itemID == 3043) then
                    table.insert(tempItems, itemID)
                end
            elseif debugMode then
                debugmsg = debugmsg .. sprintf('Depositer Issue: Could\'t find item named %q.\n', itemname(item))
            end
        end
    end

    depositItems = tempItems

    local function checkcont(cont)
        local dest = getlootingdestination(cont)

        if dest ~= '' then
            return dest
        elseif itemid(cont) > 0 then
            return cont
        else
            debugmsg = debugmsg .. sprintf('Depositer Issue: Invalid backpack name/looting destination %q.\n', cont)
        end
    end

    depotBackpack = checkcont(depotBackpack)
    lootBackpack = checkcont(lootBackpack)
    raresBackpack = checkcont(raresBackpack)
    stackBackpack = checkcont(stackBackpack)

    if #depositItems == 0 then
        debugmsg = debugmsg .. sprintf('Depositer Issue: Item list is empty.')
    end

    if debugMode and debugmsg ~= '' then
        printerror(debugmsg)
    end

    local nextBP = getsetting('Looting/OpenNextBP')
    setsetting('Looting/OpenNextBP', 'no')
init end

opendepot()

local depotBpsAmount, depotIndex, openNext = itemcount(depotBackpack), 1, false

openitem(depotBackpack) waitcontainer(depotBackpack, false)

if windowcount(lootBackpack) == 0 then
	openitem(lootBackpack, $back.id, false) waitcontainer(lootBackpack, false)
end

while (true) do
    local stackBpsAmount, rareBpsAmount = itemcount(stackBackpack, depotBackpack), itemcount(raresBackpack, depotBackpack)
    local cont = getcontainer(lootBackpack)
	clearlastonto()

    while cont.isopen do
        for k = cont.itemcount, 1, -1 do
            if table.find(depositItems, cont.item[k].id) then
                local info = iteminfo(cont.item[k].id)

                if info.iscumulative then
                    while stackBpsAmount >= $lastonto do
                        local itemamount = itemcount(info.id, cont.name)

                        setlifetime(60000)
                        moveitemsonto(info.id, stackBackpack, $lastonto) waitping()

                        if itemcount(info.id, cont.name) == itemamount then
                            stackLastOnto[info.id] = stackLastOnto[info.id] + 1
                        else
                            break
                        end
                    end

                    if $lastonto > stackBpsAmount and depotBpsAmount > 1 then
                        openNext = true
                    end
                else
                    while rareBpsAmount >= $lastonto do
                        local itemamount = itemcount(info.id, cont.name)

                        setlifetime(60000)
                        moveitemsonto(info.id, raresBackpack, $lastonto) waitping()

                        if itemcount(info.id, cont.name) == itemamount then
                            rareLastOnto = rareLastOnto + 1
                        else
                            break
                        end
                    end

                    if $lastonto > rareBpsAmount and depotBpsAmount > 1 then
                        openNext = true
                    end
                end
            end
        end

        if itemcount(lootBackpack, lootBackpack) > 0 then
            openitem(lootBackpack, lootBackpack, false) waitping()
        else
            break
        end
    end

    if openNext and depotBpsAmount > depotIndex then
        depotIndex = depotIndex + 1
        higherwindows(depotBackpack) waitping()
        openitem(depotBackpack, "Depot Chest", false, depotIndex) waitping()

        local id = itemid(lootBackpack)
        cont = getcontainer(lootBackpack)

        while cont.itemid == id and cont.isopen and cont.hashigher do
            higherwindows(cont.index, true)
        end

        repeat
            openitem(id, cont.index, false) waitping()
        until cont.itemid == id or not cont.isopen or itemcount(id, cont.index) == 0
    else
        break
    end

    wait(200)
end

setsetting('Looting/OpenNextBP', nextBP)
