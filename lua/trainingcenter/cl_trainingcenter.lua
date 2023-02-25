hook.Add("InitPostEntity", "MRP::cirfaReception::hint", function ()
    -- we want to wait for the player to be fully loaded before calling methods on him
    local ply = LocalPlayer()
    timer.Create("MRP::trainingCenter::hint", 5, 0, function ()
        if ply:GetPos():DistToSqr(MRP.trainingCenter.receptionnistPos) < 10000 then
            ply:ChatPrint(MRP.translation[MRP.lang].trainingCenter.hint)
        end
    end)
end)