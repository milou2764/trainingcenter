MRP = MRP or {}
---@class target
---@field mapId number The map id of the target
---@field entity Entity The entity of the target
---@field hit boolean If the target has been hit
---@field doorMapId number The map id of the door
---@field doorEntity Entity The entity of the door
local function target(targetId, doorId)
    return {
        mapId = targetId,
        entity = nil,
        hit = false,
        doorMapId = doorId,
        doorEntity = nil
    }
end
MRP.waitingTrainees = {}
MRP.trainingCenter = {
    receptionnistPos = Vector(2480, -179, 8),
    receptionnistAng = Angle(5, 44, 0),
    targetRoom = {
        { -- target room of the fist circuit
            spawnPos = Vector(2659, 3360, -635),
            spawnAng = Angle(6, 0, 0),
            targets = {
                target(1237, 1236),
                target(1242, 1243),
                target(1238, 1239),
                target(1240, 1241)
            },
            trainee = nil
        }
    },
    courseRoom = {
        { -- course room of the fist circuit
            spawnPos = Vector(1672, 3338, -635),
            spawnAng = Angle(2, -2, 0),
            trainee = nil
        }
    }
}