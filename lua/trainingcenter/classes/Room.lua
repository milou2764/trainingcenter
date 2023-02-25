---@class MRP.Room
---@field spawnPos Vector The position trainees will be teleported when they get in
---@field spawnAng Angle
---@field trainee Player The trainee in the room
---@field nextRooms table<MRP.Room> The rooms trainees will be teleported in when they leave this room
MRP.Room = {}
MRP.Room.timeBeforeTP = 5
MRP.Room.trainee = nil
function MRP.Room:setTrainee(trainee)
    self.trainee = trainee
end
function MRP.Room:acceptTrainee(trainee)
    self:setTrainee(trainee)
    trainee:SetPos(self.spawnPos)
    trainee:SetEyeAngles(self.spawnAng)
end
function MRP.Room:tptrainee()
    timer.Create("MRP::trainingCenter::seekingFreeRoom" .. self.trainee:SteamID64(), 5, 0, function ()
        for _, r in pairs(self.nextRooms) do
            if r.trainee == nil then
                r:acceptTrainee(self.trainee)
                timer.Remove("MRP::trainingCenter::seekingFreeRoom" .. self.trainee:SteamID64())
                self:traineeLeft()
                return
            end
        end
        self.trainee:ChatPrint(MRP.translation[MRP.lang].noFreeRoom)
    end)
end
function MRP.Room:traineeLeft()
    -- to be overriden
end