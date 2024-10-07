
if SERVER then AddCSLuaFile() end

ENT.Base = "base_entity"
ENT.Type = "point"
ENT.Spawnable = true
ENT.PrintName = "Hax Monitor"
ENT.Category = "Other"
ENT.Prop = ENT.Prop or NULL
ENT.PropPhys = ENT.PropPhys or NULL
ENT.EntityModel = "models/props_lab/monitor02.mdl"
ENT.EntitySound = "vo/npc/male01/hacks01.wav"

function ENT:Initialize()
	if SERVER then
		local prop = ents.Create( "prop_physics" )
		prop:SetModel( self.EntityModel )
		prop:SetPos( self:GetPos() )
		prop:Spawn()
		prop:Activate()
		prop:SetName( "hax_monitor" )
		prop.PropParent = self:EntIndex()
		local phys = prop:GetPhysicsObject()
		phys:Wake()
		self.Prop = prop
		self.PropPhys = phys
		self:SetParent(prop)

		local function PhysCallback( ent, data ) -- Function that will be called whenever collision happends
			if data and data.HitEntity and data.HitEntity:IsPlayer() and data.Speed > 200 then
				local ply = data.HitEntity
				local boneid = ply:LookupBone( "ValveBiped.Bip01_Head1" )
				ent:EmitSound("vo/npc/male01/hacks01.wav" )
				ent:SetMoveType( MOVETYPE_NONE )
				ent:SetSolid(0)
				ent:SetPos( ply:EyePos() - Vector( 0, 0, 15) )
				ent:SetAngles( ply:GetAngles() )
				ent:SetParent( ply, boneid )
				
				timer.Simple( 2, function() ply:Kill() Entity( ent.PropParent ):Remove() end)
			end
		end

		self.Prop:AddCallback( "PhysicsCollide", PhysCallback )
		self.Prop:AddCallback( "GravGunPunt", function( ply )
		end )

	end

end

function ENT:Think()

	if SERVER then -- Only set this stuff on the server

		self:NextThink( CurTime() ) -- Set the next think for the serverside hook to be the next frame/tick
		return true -- Return true to let the game know we want to apply the self:NextThink() call

	end

end

function ENT:OnRemove()

	if SERVER then

		self.Prop:Remove()

	end

end