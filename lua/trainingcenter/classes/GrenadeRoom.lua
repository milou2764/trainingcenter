---@class MRP.GrenadeRoom:MRP.Room The first room trainees will be teleported in
MRP.GrenadeRoom = {
    timeLimit = 20
}
if SERVER then
    util.AddNetworkString("trainingCenter::grenadeRoom::countDown")
    util.AddNetworkString("trainingCenter::grenadeRoom::resetTime")
    util.AddNetworkString("trainingcenter::trainingIsOver")

    setmetatable(MRP.GrenadeRoom, {__index = MRP.Room})
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
    for _, v in pairs(MRP.trainingCenter.grenadeRooms) do
        setmetatable(v, {__index = MRP.GrenadeRoom})
    end
else
    net.Receive("trainingCenter::grenadeRoom::countDown", function ()
        local timeLeft = MRP.GrenadeRoom.timeLimit
        timer.Create("trainingCenter::grenadeRoom::timer", 1, MRP.GrenadeRoom.timeLimit, function ()
            timeLeft = timeLeft - 1
            chat.AddText(Color(255, 255, 255), string.FormattedTime( timeLeft, "%2i:%02i" ))
        end)
    end)
    net.Receive("trainingCenter::grenadeRoom::resetTime", function ()
        timer.Remove("trainingCenter::grenadeRoom::timer")
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