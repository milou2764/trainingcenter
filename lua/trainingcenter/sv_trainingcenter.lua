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

---@class Room
---@field spawnPos Vector The position trainees will be teleported when they get in
---@field spawnAng Angle
---@field trainee Player The trainee in the room
---@field nextRooms table<Room> The rooms trainees will be teleported in when they leave this room
local Room = {}
Room.timeBeforeTP = 5
Room.trainee = nil
function Room:setTrainee(trainee)
    self.trainee = trainee
end
function Room:tptrainee()
    timer.Create("MRP::trainingCenter::seekingFreeRoom" .. self.trainee:SteamID64(), 5, 0, function ()
        for _, r in pairs(self.nextRooms) do
            if r.trainee == nil then
                r:setTrainee(self.trainee)
                self.trainee:SetPos(r.spawnPos)
                self.trainee:SetEyeAngles(r.spawnAng)
                timer.Remove("MRP::trainingCenter::seekingFreeRoom" .. self.trainee:SteamID64())
                self.trainee = nil
                self:traineeLeft()
                return
            end
        end
        self.trainee:ChatPrint(translation[lang].noFreeRoom)
    end)
end
function Room:traineeLeft()
    -- to be overriden
end

---@class GrenadeRoom:Room The first room trainees will be teleported in
local GrenadeRoom = {}
GrenadeRoom.nextRooms = MRP.trainingCenter.grenadeRoom
setmetatable(GrenadeRoom, {__index = Room})
for _, v in pairs(MRP.trainingCenter.grenadeRoom) do
    setmetatable(v, {__index = GrenadeRoom})
end

---@class CourseRoom:Room The first room trainees will be teleported in
---@field button Entity The invisible button trainees will have to push to teleport to the next room
local CourseRoom = {}
CourseRoom.nextRooms = MRP.trainingCenter.grenadeRoom
setmetatable(CourseRoom, {__index = Room})
function CourseRoom:traineeLeft()
    self.button.hasBeenPushed = false
end
for _, v in pairs(MRP.trainingCenter.courseRoom) do
    setmetatable(v, {__index = CourseRoom})
end


---@class TargetRoom:Room The first room trainees will be teleported in
---@field targets table<target> The targets trainees will have to hit
local TargetRoom = {}
setmetatable(TargetRoom, {__index = Room})

TargetRoom.nextRooms = MRP.trainingCenter.courseRoom
function TargetRoom:seekTrainee()
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
function TargetRoom:acceptTrainee(trainee)
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
function TargetRoom:traineeLeft()
    -- close the doors
    timer.Simple(3, function ()
        for _, target in pairs(self.targets) do
            target.doorEntity:Fire("Close")
        end
    end)
end
for _, v in pairs(MRP.trainingCenter.targetRoom) do
    setmetatable(v, {__index = TargetRoom})
end

hook.Add("InitPostEntity", "MRP::trainingCenter::init", function ()
    local receptionnist = ents.Create("mrp_receptionnist")
    receptionnist:SetPos(MRP.trainingCenter.receptionnistPos)
    receptionnist:SetAngles(MRP.trainingCenter.receptionnistAng)
    receptionnist:Spawn()
    for _, v in pairs(MRP.trainingCenter.targetRoom) do
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
    for _, v in pairs(MRP.trainingCenter.courseRoom) do
        -- create an invisible button to teleport trainees to the next room
        v.button = ents.Create("mrp_courseroom_button")
        v.button:SetPos(v.buttonPos)
        v.button:Spawn()
        v.button.room = v
    end

end)

hook.Add("EntityTakeDamage", "MRP::trainingCenter::targetHit", function (ent, dmgInfo)
    local entityWasTarget = false
    for _, v in pairs(MRP.trainingCenter.targetRoom) do
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