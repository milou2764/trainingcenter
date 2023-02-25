---@class CourseRoom:MRP.Room The first room trainees will be teleported in
---@field button Entity The invisible button trainees will have to push to teleport to the next room
MRP.CourseRoom = {}
MRP.CourseRoom.nextRooms = MRP.trainingCenter.grenadeRooms
setmetatable(MRP.CourseRoom, {__index = MRP.Room})
function MRP.CourseRoom:traineeLeft()
    self.button.hasBeenPushed = false
end
for _, v in pairs(MRP.trainingCenter.courseRooms) do
    setmetatable(v, {__index = MRP.CourseRoom})
end