timer.Create("MRP::trainingCenter::hint", 5, 0, function ()
    for k, v in pairs(player.GetAll()) do
        if v:GetPos():DistToSqr(MRP.trainingCenter.receptionnistPos) < 10000 then
            v:ChatPrint("Vous pouvez vous inscrire à la formation en intéragissant avec la réceptionniste")
        end
    end
end)