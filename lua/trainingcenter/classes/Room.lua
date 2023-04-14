---@class MRP.Room
---@field timeLimit number The time limit for the trainee to complete the room
---@field spawnPos Vector The position trainees will be teleported when they get in
---@field spawnAng Angle
---@field trainee Player The trainee in the room
---@field nextRooms table<MRP.Room> The rooms trainees will be teleported in when they leave this room
MRP.Room = {}
MRP.Room.timeBeforeTP = 5
if SERVER then
    util.AddNetworkString("trainingCenter::countDown")
    util.AddNetworkString("trainingCenter::setTimeLimit")
    function MRP.Room:setTrainee(trainee)
        self.trainee = trainee
    end
    function MRP.Room:setTimeLimit()
        net.Start("trainingCenter::setTimeLimit")
        net.WriteInt(self.timeLimit, 32)
        net.Send(self.trainee)
        timer.Create("trainingCenter::" .. tostring(self) .. "::timer", self.timeLimit, 1, function ()
            self:timeOut()
        end)
    end
    function MRP.Room:acceptTrainee(trainee)
        self:setTrainee(trainee)
        trainee:SetPos(self.spawnPos)
        trainee:SetEyeAngles(self.spawnAng)
        self:setTimeLimit()
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
        timer.Remove("trainingCenter::" .. tostring(self) .. "::timer")
        self.trainee = nil
    end
else
    net.Receive("trainingCenter::setTimeLimit", function()
        MRP.trainingCenter.remainingTime = net.ReadUInt(32)
        timer.Create("MRP::trainingCenter::countDown", 1, MRP.trainingCenter.remainingTime, function ()
            MRP.trainingCenter.remainingTime = MRP.trainingCenter.remainingTime - 1
        end)
    end)
    net.Receive("trainingCenter::countDown", function()
        timer.Create("MRP::trainingCenter::countDown", 1, MRP.trainingCenter.remainingTime, function ()
            MRP.trainingCenter.remainingTime = MRP.trainingCenter.remainingTime - 1
        end)
    end)
end