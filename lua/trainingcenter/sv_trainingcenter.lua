local function vectorToString(pos)
    local x = math.Round(pos.x, 0)
    local y = math.Round(pos.y, 0)
    local z = math.Round(pos.z, 0)
    return "Vector(" .. x .. ", " .. y .. ", " .. z .. ")"
end
local function angleToString(ang)
    local x = math.Round(ang.x, 0)
    local y = math.Round(ang.y, 0)
    local z = math.Round(ang.z, 0)
    return "Angle(" .. x .. ", " .. y .. ", " .. z .. ")"
end
concommand.Add("getposeye", function(ply,cmd,args,argStr)
    local pos = ply:GetEyeTrace().HitPos
    local nicePos = vectorToString(pos)
    print(nicePos)
    ply:ChatPrint(nicePos)
end)
concommand.Add("getplayerposnang", function(ply,cmd,args,argStr)
    local pos = ply:GetPos()
    local nicePos = vectorToString(pos)
    print(nicePos)
    ply:ChatPrint(nicePos)
    local ang = ply:GetAngles()
    local niceAng = angleToString(ang)
    print(niceAng)
    ply:ChatPrint(niceAng)
    SetClipboardText( "local pos = " .. nicePos .. "\nlocal ang = " .. niceAng .. "\n")
end)
concommand.Add("getid", function(ply,cmd,args,argStr)
    print(tostring(ply:GetEyeTrace().Entity:MapCreationID()))
    ply:ChatPrint(tostring(ply:GetEyeTrace().Entity:MapCreationID()))
end)

util.AddNetworkString("trainingCenter::targetRoom::countDown")
util.AddNetworkString("trainingCenter::targetRoom::resetTime")

local function initTargets(rooms)
    for _, v in pairs(rooms) do
        for _, target in pairs(v.targets) do
            target.entity = ents.GetMapCreatedEntity(target.mapId)
            target.doorEntity = ents.GetMapCreatedEntity(target.doorMapId)
        end
    end
end
hook.Add("InitPostEntity", "MRP::trainingCenter::init", function ()
    local receptionnist = ents.Create("mrp_receptionist")
    receptionnist:SetPos(MRP.trainingCenter.receptionnistPos)
    receptionnist:SetAngles(MRP.trainingCenter.receptionnistAng)
    receptionnist:Spawn()
    timer.Simple(2, function ()
        timer.Create("MRP::trainingCenter::seekingTrainee", 5, 0, function ()
            initTargets(MRP.trainingCenter.targetRooms)
            initTargets(MRP.trainingCenter.grenadeRooms)
            for _, v in pairs(MRP.trainingCenter.targetRooms) do
                if v.trainee == nil then
                    v:seekTrainee()
                    break
                end
            end
        end)
        for _, v in pairs(MRP.trainingCenter.courseRooms) do
            -- create an invisible button to teleport trainees to the next room
            v.button = ents.Create("mrp_courseroom_button")
            v.button:SetPos(v.buttonPos)
            v.button:Spawn()
            v.button.room = v
        end
    end)
end)

local function checkTargetsHit(rooms, ent)
    local entityWasTarget = false
    for _, v in pairs(rooms) do
        local shouldTPTrainee = true
        for _, target in pairs(v.targets) do
            if target.entity == ent then
                target.hit = true
                entityWasTarget = true
            end
            shouldTPTrainee = shouldTPTrainee and target.hit
        end
        if entityWasTarget then
            if shouldTPTrainee then
                v:tptrainee()
            end
            return true
        end
    end
    return false
end
hook.Add("EntityTakeDamage", "MRP::trainingCenter::targetHit", function (ent, dmgInfo)
    if checkTargetsHit(MRP.trainingCenter.targetRooms, ent) then
        return
    else
        checkTargetsHit(MRP.trainingCenter.grenadeRooms, ent)
    end
end)

-- TODO we can probably do better than that with player_manager
hook.Add("PlayerSpawn", "MRP::trainingcenter::PlayerSpawn", function(player, _)
    timer.Simple(1, function ()
        player:StripWeapons()
        player:StripAmmo()
    end)
end)