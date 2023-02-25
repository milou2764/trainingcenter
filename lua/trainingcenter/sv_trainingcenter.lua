if game.GetMap() ~= "trainingcenter" then return end

concommand.Add("getposeye", function(ply,cmd,args,argStr)
    local pos = ply:GetEyeTrace().HitPos
    local x = math.Round(pos.x, 0)
    local y = math.Round(pos.y, 0)
    local z = math.Round(pos.z, 0)
    local nicePos = "Vector(" .. x .. ", " .. y .. ", " .. z .. ")"
    print(nicePos)
    ply:ChatPrint(nicePos)
end)
concommand.Add("getid", function(ply,cmd,args,argStr)
    print(tostring(ply:GetEyeTrace().Entity:MapCreationID()))
    ply:ChatPrint(tostring(ply:GetEyeTrace().Entity:MapCreationID()))
end)

util.AddNetworkString("trainingCenter::targetRoom::countDown")
util.AddNetworkString("trainingCenter::targetRoom::resetTime")

hook.Add("InitPostEntity", "MRP::trainingCenter::init", function ()
    local receptionnist = ents.Create("mrp_receptionnist")
    receptionnist:SetPos(MRP.trainingCenter.receptionnistPos)
    receptionnist:SetAngles(MRP.trainingCenter.receptionnistAng)
    receptionnist:Spawn()
    for _, v in pairs(MRP.trainingCenter.targetRooms) do
        for _, target in pairs(v.targets) do
            target.entity = ents.GetMapCreatedEntity(target.mapId)
            target.doorEntity = ents.GetMapCreatedEntity(target.doorMapId)
        end
    end
    timer.Create("MRP::trainingCenter::seekingTrainee", 5, 0, function ()
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

hook.Add("EntityTakeDamage", "MRP::trainingCenter::targetHit", function (ent, dmgInfo)
    local entityWasTarget = false
    for _, v in pairs(MRP.trainingCenter.targetRooms) do
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
            break
        end
    end
end)

-- TODO we can probably do better than that with player_manager
hook.Add("PlayerSpawn", "MRP::trainingcenter::PlayerSpawn", function(player, _)
    timer.Simple(1, function ()
        player:StripWeapons()
    end)
end)