---@class MRP.GrenadeRoom:MRP.Room The first room trainees will be teleported in
MRP.GrenadeRoom = {}
MRP.GrenadeRoom.nextRooms = MRP.trainingCenter.grenadeRooms
function MRP.GrenadeRoom:acceptTrainee(trainee)
    MRP.Room.acceptTrainee(self, trainee)
    trainee:Give("weapon_frag")
    trainee:GiveAmmo(9, "Grenade", true)
end
setmetatable(MRP.GrenadeRoom, {__index = MRP.Room})
for _, v in pairs(MRP.trainingCenter.grenadeRooms) do
    setmetatable(v, {__index = MRP.GrenadeRoom})
end