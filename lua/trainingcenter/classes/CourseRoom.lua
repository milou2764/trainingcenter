---@class CourseRoom:MRP.Room The first room trainees will be teleported in
---@field button Entity The invisible button trainees will have to push to teleport to the next room
MRP.CourseRoom = {
    timeLimit = 120
}
if SERVER then
    MRP.CourseRoom.nextRooms = MRP.trainingCenter.grenadeRooms
    setmetatable(MRP.CourseRoom, {__index = MRP.Room})

    MRP.CourseRoom.netName = 'courseRoom'
    util.AddNetworkString("trainingCenter::courseRoom::countDown")
    function MRP.CourseRoom:traineeLeft()
        self.button.hasBeenPushed = false
        MRP.Room.traineeLeft(self)
    end
    function MRP.CourseRoom:setTimeLimit()
        MRP.Room.setTimeLimit(self)
        net.Start("trainingCenter::courseRoom::countDown")
        net.Send(self.trainee)
    end

    for _, v in pairs(MRP.trainingCenter.courseRooms) do
        setmetatable(v, {__index = MRP.CourseRoom})
    end
else
    net.Receive("trainingCenter::courseRoom::countDown", function()
        hook.Add("HUDPaint", "MRP::trainingCenter::courseRoom::countDown", function ()
            draw.SimpleText(string.FormattedTime( MRP.trainingCenter.remainingTime, "%2i:%02i" ), "Trebuchet24", ScrW() / 2, ScrH() / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end)
        timer.Simple(MRP.CourseRoom.timeLimit, function ()
            hook.Remove("HUDPaint", "MRP::trainingCenter::courseRoom::countDown")
        end)
    end)
end