timer.Create("MRP::trainingCenter::hint", 5, 0, function ()
    for k, v in pairs(player.GetAll()) do
        if v:GetPos():DistToSqr(MRP.trainingCenter.receptionnistPos) < 10000 then
            v:ChatPrint("Vous pouvez vous inscrire à la formation en intéragissant avec le réceptionniste")
        end
    end
end)

local targetRoomTime = MRP.TargetRoom.timeLimit
net.Receive("trainingCenter::targetRoom::countDown", function()
    timer.Create("MRP::trainingCenter::targetRoom::countDown", 1, MRP.TargetRoom.timeLimit, function ()
        targetRoomTime = targetRoomTime - 1
    end)
end)
net.Receive("trainingCenter::targetRoom::resetTime", function()
    targetRoomTime = MRP.TargetRoom.timeLimit
end)

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
        surface.DrawText(string.FormattedTime( targetRoomTime, "%2i:%02i" ))
	cam.End3D2D()
end )