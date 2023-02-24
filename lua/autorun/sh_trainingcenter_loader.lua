AddCSLuaFile("trainingcenter/sh_trainingcenter.lua")
AddCSLuaFile("trainingcenter/cl_trainingcenter.lua")

include("trainingcenter/sh_trainingcenter.lua")
if CLIENT then
    include("trainingcenter/cl_trainingcenter.lua")
else
    include("trainingcenter/sv_trainingcenter.lua")
end