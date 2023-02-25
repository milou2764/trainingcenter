---@class CourseRoom:MRP.Room The first room trainees will be teleported in
---@field button Entity The invisible button trainees will have to push to teleport to the next room
MRP.CourseRoom = {
    timeLimit = 12
}
if SERVER then
    util.AddNetworkString("trainingCenter::courseRoom::countDown")
    util.AddNetworkString("trainingCenter::courseRoom::resetTime")

    MRP.CourseRoom.nextRooms = MRP.trainingCenter.grenadeRooms
    setmetatable(MRP.CourseRoom, {__index = MRP.Room})
    function MRP.CourseRoom:traineeLeft()
        net.Start("trainingCenter::courseRoom::resetTime")
        net.Send(self.trainee)
        timer.Remove("trainingCenter::courseRoom::timer")
        self.button.hasBeenPushed = false
        MRP.Room.traineeLeft(self)
    end
    function MRP.CourseRoom:startCountDown()
        net.Start("trainingCenter::courseRoom::countDown")
        net.Send(self.trainee)
        timer.Create("trainingCenter::courseRoom::timer", self.timeLimit, 1, function ()
            self:timeOut()
        end)
    end

    for _, v in pairs(MRP.trainingCenter.courseRooms) do
        setmetatable(v, {__index = MRP.CourseRoom})
    end
else
    local courseRoomTime = MRP.CourseRoom.timeLimit
    net.Receive("trainingCenter::courseRoom::countDown", function()
        timer.Create("MRP::trainingCenter::courseRoom::countDown", 1, MRP.CourseRoom.timeLimit, function ()
            courseRoomTime = courseRoomTime - 1
        end)
        hook.Add("HUDPaint", "MRP::trainingCenter::courseRoom::countDown", function ()
            draw.SimpleText(string.FormattedTime( courseRoomTime, "%2i:%02i" ), "Trebuchet24", ScrW() / 2, ScrH() / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end)
        timer.Simple(MRP.CourseRoom.timeLimit, function ()
            hook.Remove("HUDPaint", "MRP::trainingCenter::courseRoom::countDown")
        end)
    end)
    net.Receive("trainingCenter::courseRoom::resetTime", function()
        courseRoomTime = MRP.CourseRoom.timeLimit
    end)
end