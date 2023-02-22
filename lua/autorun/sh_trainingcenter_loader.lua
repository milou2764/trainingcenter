AddCSLuaFile("trainingcenter/shared.lua")
AddCSLuaFile("trainingcenter/client.lua")

include("trainingcenter/shared.lua")
if CLIENT then
    include("trainingcenter/client.lua")
else
    include("trainingcenter/server.lua")
end