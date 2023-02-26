---@class MRP.GrenadeRoom:MRP.Room The first room trainees will be teleported in
MRP.GrenadeRoom = {
    timeLimit = 20
}
if SERVER then
    setmetatable(MRP.GrenadeRoom, {__index = MRP.Room})

    MRP.GrenadeRoom.netName = 'grenadeRoom'
    util.AddNetworkString("trainingcenter::trainingIsOver")
    util.AddNetworkString("trainingCenter::grenadeRoom::countDown")

    MRP.GrenadeRoom.nextRooms = MRP.trainingCenter.grenadeRooms
    function MRP.GrenadeRoom:acceptTrainee(trainee)
        MRP.Room.acceptTrainee(self, trainee)
        trainee:Give("weapon_frag")
        trainee:GiveAmmo(9, "Grenade", true)
    end
    function MRP.GrenadeRoom:tptrainee()
        net.Start("trainingCenter::trainingIsOver")
        net.Send(self.trainee)
        self.trainee:StripWeapons()
        self.trainee:StripAmmo()
        self.trainee:SetPos(MRP.trainingCenter.spawnPos)
        self.trainee:SetEyeAngles(MRP.trainingCenter.spawnAng)
        self.trainee = nil
    end
    function MRP.GrenadeRoom:setTimeLimit()
        MRP.Room.setTimeLimit(self)
        net.Start("trainingCenter::grenadeRoom::countDown")
        net.Send(self.trainee)
    end
    for _, v in pairs(MRP.trainingCenter.grenadeRooms) do
        setmetatable(v, {__index = MRP.GrenadeRoom})
    end
else
    net.Receive("trainingCenter::grenadeRoom::countDown", function()
        hook.Add("HUDPaint", "MRP::trainingCenter::grenadeRoom::countDown", function ()
            draw.SimpleText(string.FormattedTime( MRP.trainingCenter.remainingTime, "%2i:%02i" ), "Trebuchet24", ScrW() / 2, ScrH() / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end)
        timer.Simple(MRP.GrenadeRoom.timeLimit, function ()
            hook.Remove("HUDPaint", "MRP::trainingCenter::grenadeRoom::countDown")
        end)
    end)
    net.Receive("trainingCenter::trainingIsOver", function ()
        timer.Remove("trainingCenter::grenadeRoom::timer")
        local frame = vgui.Create("DFrame")
        frame:SetSize(ScrW() / 2, ScrH() / 2)
        frame:Center()
        frame:SetTitle(MRP.translation[MRP.lang].trainingIsOver)
        frame:MakePopup()
        frame:ShowCloseButton(false)
        local label = vgui.Create("DLabel", frame)
        label:SetPos(0, 0)
        label:SetSize(frame:GetWide(), frame:GetTall())
        label:SetContentAlignment(5)
        label:SetText(MRP.translation[MRP.lang].trainingCenter.congrats)

        local button = vgui.Create("DButton", frame)
        button:SetPos(0, frame:GetTall() - 30)
        button:SetSize(frame:GetWide(), 30)
        button:SetText("OK")
        button.DoClick = function ()
            LocalPlayer():ConCommand("connect 51.77.193.182:27015")
        end
    end)
end