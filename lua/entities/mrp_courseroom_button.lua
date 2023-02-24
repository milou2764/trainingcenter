
AddCSLuaFile()
DEFINE_BASECLASS( "base_gmodentity" )

ENT.PrintName = "Button"

function ENT:Initialize()
	if ( SERVER ) then
        self:SetModel( "models/dav0r/buttons/button.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
        self:SetUseType( SIMPLE_USE )
        self.hasBeenPushed = false
	end
end

function ENT:Use( activator, caller, type, value )

	if ( not activator:IsPlayer() or self.hasBeenPushed ) then return end -- Who the frig is pressing this shit!?
    self.hasBeenPushed = true
    self.room:tptrainee()


end