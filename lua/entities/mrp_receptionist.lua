
AddCSLuaFile()
DEFINE_BASECLASS( "base_ai" )

if SERVER then
    util.AddNetworkString("MRP::cirfaReception")
    util.AddNetworkString("MRP::cirfaReception::signup")

    function ENT:Initialize()
        self:SetModel("models/Humans/Group01/Male_Cheaple.mdl")
        self:SetHullType(HULL_HUMAN)
        self:SetHullSizeNormal()
        self:SetNPCState(NPC_STATE_SCRIPT)
        self:SetSolid(SOLID_BBOX)
        self:CapabilitiesAdd(CAP_ANIMATEDFACE or CAP_TURN_HEAD)
        self:SetUseType(SIMPLE_USE)
        self:DropToFloor()
    end

    function ENT:Use(ply, caller, useType, value)
        net.Start("MRP::cirfaReception")
        net.Send(ply)
    end

    net.Receive("MRP::cirfaReception::signup", function (len, ply)
        if ply:GetNWBool("MRP::isSignedUp") then
            ply:SetNWBool("MRP::isSignedUp", false)
            table.RemoveByValue(MRP.waitingTrainees, ply)
        else
            ply:SetNWBool("MRP::isSignedUp", true)
            table.insert(MRP.waitingTrainees, ply)
        end
    end)
    
else

    net.Receive("MRP::cirfaReception", function ()
        local ply = LocalPlayer()
        local frame = vgui.Create("DFrame")
        frame:SetSize(ScrW() * 0.5, ScrH() * 0.5)
        frame:Center()
        frame:SetTitle("Réceptionniste du CIRFA")
        frame:MakePopup()
        frame:ShowCloseButton(true)
        frame:SetDraggable(true)

        local button = vgui.Create("DButton", frame)
        button:SetSize(frame:GetWide() * 0.5, frame:GetTall() * 0.1)
        button:SetPos(frame:GetWide() * 0.25, frame:GetTall() * 0.1)
        if ply:GetNWBool("MRP::isSignedUp") then
            button:SetText("Se désinscrire de la formation")
        else
            button:SetText("S'inscrire à la formation")
        end
        button.DoClick = function ()
            net.Start("MRP::cirfaReception::signup")
            net.SendToServer()
            frame:Close()

            local frame = vgui.Create("DFrame")
            frame:SetSize(ScrW() * 0.5, ScrH() * 0.5)
            frame:Center()
            frame:SetTitle("Réceptionniste du CIRFA")
            frame:MakePopup()
            frame:ShowCloseButton(true)
            frame:SetDraggable(true)

            local label = vgui.Create("DLabel", frame)
            label:SetSize(frame:GetWide() * 0.5, frame:GetTall() * 0.1)
            label:SetPos(frame:GetWide() * 0.25, frame:GetTall() * 0.1)
            label:SetText("Vous avez bien été inscrit à la formation")
        end
    end)
end