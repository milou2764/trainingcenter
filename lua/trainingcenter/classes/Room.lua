---@class MRP.Room
---@field spawnPos Vector The position trainees will be teleported when they get in
---@field spawnAng Angle
---@field trainee Player The trainee in the room
---@field nextRooms table<MRP.Room> The rooms trainees will be teleported in when they leave this room
MRP.Room = {}
MRP.Room.timeBeforeTP = 5
if SERVER then
    function MRP.Room:setTrainee(trainee)
        self.trainee = trainee
    end
    function MRP.Room:startCountDown()
        -- to be overriden
    end
    function MRP.Room:acceptTrainee(trainee)
        self:setTrainee(trainee)
        trainee:SetPos(self.spawnPos)
        trainee:SetEyeAngles(self.spawnAng)
        self:startCountDown()
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
    function MRP.Room:timeOut()
        if self.trainee then
            self.trainee:ChatPrint(MRP.translation[MRP.lang].trainingCenter.timeOut)
            self.trainee:StripWeapons()
            self.trainee:SetPos(MRP.trainingCenter.spawnPos)
            self.trainee:SetEyeAngles(MRP.trainingCenter.spawnAng)
            self.trainee:SetNWBool("MRP::isSignedUp", false)
            self:traineeLeft()
        end
    end
    function MRP.Room:traineeLeft()
        self.trainee = nil
    end
end