AddCSLuaFile()

ENT.Base = "base_mysticbot1"
ENT.Spawnable = true



function ENT:Initialize()
	self:SetModel("models/Humans/Group03/male_02.mdl")
	
	self.state = "idle"
	self.startingWeapon = "weapon_shotgun"
	
	--weapon_smg1
	--weapon_shotgun
	--weapon_ar2
	
	self.wep = nil
	self.wepFire = nil

	
	
	self.squadleader = nil
	self.squad = nil
	
	self.validEnemies = {"npc_combine_s","nb_combine2"}
	
	
	if SERVER then
		self:SetHealth( 20 )
	end





end

list.Set( "NPC", "nb_rebel2", {
	Name = "Rebel Test 2",
	Class = "nb_rebel2",
	Category = "MysticBot"
} )