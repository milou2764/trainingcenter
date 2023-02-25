AddCSLuaFile("trainingcenter/sh_trainingcenter.lua")
AddCSLuaFile("trainingcenter/classes/Room.lua")
AddCSLuaFile("trainingcenter/classes/GrenadeRoom.lua")
AddCSLuaFile("trainingcenter/classes/CourseRoom.lua")
AddCSLuaFile("trainingcenter/classes/TargetRoom.lua")
AddCSLuaFile("trainingcenter/cl_trainingcenter.lua")

------------------------------------------------------
-- The order in which we include files is important --
------------------------------------------------------

include("trainingcenter/sh_trainingcenter.lua")
if CLIENT then
    include("trainingcenter/classes/Room.lua")
    include("trainingcenter/classes/GrenadeRoom.lua")
    include("trainingcenter/classes/CourseRoom.lua")
    include("trainingcenter/classes/TargetRoom.lua")
    include("trainingcenter/cl_trainingcenter.lua")
else
    include("trainingcenter/classes/Room.lua")
    include("trainingcenter/classes/GrenadeRoom.lua")
    include("trainingcenter/classes/CourseRoom.lua")
    include("trainingcenter/classes/TargetRoom.lua")
    include("trainingcenter/sv_trainingcenter.lua")
end