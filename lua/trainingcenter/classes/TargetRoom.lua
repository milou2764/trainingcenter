---@class TargetRoom:MRP.Room The first room trainees will be teleported in
---@field targets table<target> The targets trainees will have to hit
---@field timeLimit number The time limit for the trainee to hit all the targets
setmetatable(MRP.TargetRoom, {__index = MRP.Room})
MRP.TargetRoom.nextRooms = MRP.trainingCenter.courseRooms
function MRP.TargetRoom:seekTrainee()
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
function MRP.TargetRoom:timeOut()
    if self.trainee then
        self.trainee:ChatPrint(MRP.translation[MRP.lang].trainingCenter.timeOut)
        self.trainee:StripWeapons()
        self.trainee:SetPos(MRP.trainingCenter.spawnPos)
        self.trainee:SetEyeAngles(MRP.trainingCenter.spawnAng)
        self.trainee:SetNWBool("MRP::isSignedUp", false)
        net.Start("trainingCenter::targetRoom::resetTime")
        net.Send(self.trainee)
        self:traineeLeft()
    end
end
function MRP.TargetRoom:startCountDown()
    net.Start("trainingCenter::targetRoom::countDown")
    net.Send(self.trainee)
    timer.Simple(self.timeLimit, function ()
        self:timeOut()
    end)
end
function MRP.TargetRoom:acceptTrainee(trainee)
    table.RemoveByValue(MRP.waitingTrainees, trainee)
    timer.Simple(self.timeBeforeTP, function ()
        if trainee:Alive() then
            trainee:SetPos(self.spawnPos)
            trainee:SetEyeAngles(self.spawnAng)
            self.trainee = trainee
            trainee:Give("weapon_smg1")
            self:startCountDown()
        end
    end)
    local countDown = self.timeBeforeTP
    timer.Create("MRP::trainingCenter::TPCountDown" .. trainee:SteamID64(), 1, self.timeBeforeTP, function ()
        trainee:ChatPrint(MRP.translation[MRP.lang].countDown:format(countDown))
        countDown = countDown - 1
    end)
end
function MRP.TargetRoom:traineeLeft()
    self.trainee:StripWeapons()
    -- close the doors
    timer.Simple(3, function ()
        self.trainee = nil
        for _, target in pairs(self.targets) do
            target.doorEntity:Fire("Close")
            target.hit = false
        end
    end)
end
for _, v in pairs(MRP.trainingCenter.targetRooms) do
    setmetatable(v, {__index = MRP.TargetRoom})
end