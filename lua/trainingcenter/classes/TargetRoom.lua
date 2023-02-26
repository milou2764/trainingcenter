---@class TargetRoom:MRP.Room The first room trainees will be teleported in
---@field targets table<target> The targets trainees will have to hit
---@field timeLimit number The time limit for the trainee to hit all the targets
MRP.TargetRoom = {
    timeLimit = 45
}
if SERVER then
    setmetatable(MRP.TargetRoom, {__index = MRP.Room})

    MRP.TargetRoom.netName = 'grenadeRoom'

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
    function MRP.TargetRoom:acceptTrainee(trainee)
        table.RemoveByValue(MRP.waitingTrainees, trainee)
        timer.Simple(self.timeBeforeTP, function ()
            if trainee:Alive() then
                trainee:SetPos(self.spawnPos)
                trainee:SetEyeAngles(self.spawnAng)
                self.trainee = trainee
                trainee:Give("weapon_smg1")
                net.Start("trainingCenter::countDown")
                net.Send(self.trainee)
                self:setTimeLimit()
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
        self.trainee:StripAmmo()
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
else
    hook.Add("PostDrawOpaqueRenderables", "example", function()
        local trace = LocalPlayer():GetEyeTrace()
        local angle = trace.HitNormal:Angle()

    ---@diagnostic disable-next-line: param-type-mismatch
        render.DrawLine( trace.HitPos, trace.HitPos + 8 * angle:Forward(), Color( 255, 0, 0 ), true )
    ---@diagnostic disable-next-line: param-type-mismatch
        render.DrawLine( trace.HitPos, trace.HitPos + 8 * -angle:Right(), Color( 0, 255, 0 ), true )
    ---@diagnostic disable-next-line: param-type-mismatch
        render.DrawLine( trace.HitPos, trace.HitPos + 8 * angle:Up(), Color( 0, 0, 255 ), true )

        cam.Start3D2D( Vector(2928, 3462.9, -471), Angle(0, 0, 90), 1 )
            surface.SetDrawColor( 0, 0, 0, 255 )
            surface.DrawRect( 0, 0, 48, 17 )
            surface.SetTextColor( 0, 255, 0, 255 )
            surface.SetTextPos( 0, -4 )
            surface.SetFont( "Trebuchet24" )
            surface.DrawText(string.FormattedTime( MRP.trainingCenter.remainingTime, "%2i:%02i" ))
        cam.End3D2D()
    end)
end