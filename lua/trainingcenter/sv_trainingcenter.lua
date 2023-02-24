if game.GetMap() ~= "trainingcenter" then return end

concommand.Add("getposeye", function(ply,cmd,args,argStr)
    print(ply:GetEyeTrace().HitPos)
    ply:ChatPrint(tostring(ply:GetEyeTrace().HitPos))
end)
concommand.Add("getid", function(ply,cmd,args,argStr)
    print(tostring(ply:GetEyeTrace().Entity:MapCreationID()))
    ply:ChatPrint(tostring(ply:GetEyeTrace().Entity:MapCreationID()))
end)

local lang = MRP.lang or "FR"
local translation = {
    FR = {
        countDown = "Téléportation dans %s s",
        noFreeRoom = "Veuillez patienter que la salle suivante se libère s'il vous plaît"
    },
    EN = {
        countDown = "Teleporting in %s s",
        noFreeRoom = "Please wait for the next room to be free"
    }
}


---@class targetRoom The first room trainees will be teleported in
---@field spawnPos Vector The position trainees will be teleported when they get in
---@field spawnAng Angle
---@field targets table<target> The targets trainees will have to hit
---@field trainee Player The trainee in the room
local targetRoom = {}
targetRoom.timeBeforeTP = 5
function targetRoom:seekTrainee()
    for k, v in pairs(MRP.waitingTrainees) do
        -- remove from the list the first trainee we finf
        table.remove(MRP.waitingTrainees, k)
        -- if this trainee is alive, accept him and break the loop
        if v:Alive() then
            self:acceptTrainee(v)
            break
        end
    end
end
function targetRoom:acceptTrainee(trainee)
    table.RemoveByValue(MRP.waitingTrainees, trainee)
    timer.Simple(self.timeBeforeTP, function ()
        if trainee:Alive() then
            trainee:SetPos(self.spawnPos)
            trainee:SetEyeAngles(self.spawnAng)
            self.trainee = trainee
        end
    end)
    local countDown = self.timeBeforeTP
    timer.Create("MRP::trainingCenter::TPCountDown" .. trainee:SteamID64(), 1, self.timeBeforeTP, function ()
        trainee:ChatPrint(translation[lang].countDown:format(countDown))
        countDown = countDown - 1
    end)
end
function targetRoom:tptrainee()
    timer.Create("MRP::trainingCenter::seekingFreeRoom" .. self.trainee:SteamID64(), 5, 0, function ()
        for _, room in pairs(MRP.trainingCenter.courseRoom) do
            if room.trainee == nil then
                room.trainee = self.trainee
                self.trainee:SetPos(room.spawnPos)
                self.trainee:SetEyeAngles(room.spawnAng)
                timer.Remove("MRP::trainingCenter::seekingFreeRoom" .. self.trainee:SteamID64())
                self.trainee = nil
                return
            end
        end
        self.trainee:ChatPrint(translation[lang].noFreeRoom)
    end)
end
function targetRoom:traineeLeft()
    -- close the doors
    timer.Simple(3, function ()
        for _, target in pairs(self.targets) do
            target.doorEntity:Fire("Close")
        end
    end)
end

hook.Add("InitPostEntity", "MRP::trainingCenter::init", function ()
    local receptionnist = ents.Create("mrp_receptionnist")
    receptionnist:SetPos(MRP.trainingCenter.receptionnistPos)
    receptionnist:SetAngles(MRP.trainingCenter.receptionnistAng)
    receptionnist:Spawn()
    for _, v in pairs(MRP.trainingCenter.targetRoom) do
        setmetatable(v, {__index = targetRoom})
        for _, target in pairs(v.targets) do
            target.entity = ents.GetMapCreatedEntity(target.mapId)
            target.doorEntity = ents.GetMapCreatedEntity(target.doorMapId)
        end
    end
    timer.Create("MRP::trainingCenter::seekingTrainee", 5, 0, function ()
        for _, v in pairs(MRP.trainingCenter.targetRoom) do
            if v.trainee == nil then
                v:seekTrainee()
                break
            end
        end
    end)
end)

hook.Add("EntityTakeDamage", "MRP::trainingCenter::targetHit", function (ent, dmgInfo)
    for _, v in pairs(MRP.trainingCenter.targetRoom) do
        local shouldTPTrainee = true
        for _, target in pairs(v.targets) do
            if target.entity == ent then
                target.hit = true
            end
            shouldTPTrainee = shouldTPTrainee and target.hit
        end
        if shouldTPTrainee then
            v:tptrainee()
            v:traineeLeft()
            break
        end
    end
end)