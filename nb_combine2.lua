AddCSLuaFile()

ENT.Base = "base_mysticbot1"
ENT.Spawnable = true



function ENT:Initialize()
	self:SetModel("models/Combine_Soldier.mdl")
	
	self.state = "idle"
	self.startingWeapon = "weapon_smg1"
	
	--weapon_smg1
	--weapon_shotgun
	--weapon_ar2
	
	self.wep = nil
	self.wepFire = nil

	
	
	self.squadleader = nil
	self.squad = nil
	
	self.validEnemies = {"npc_citizen","nb_rebel2"}
	
	
	if SERVER then
		self:SetHealth( 20 )
	end





end

function ENT:SaySound(input)
	--ouch, dead
	
	if input == "dead" then
		return "npc/combine_soldier/die"..tostring(math.random(1,3))..".wav"
	elseif input == "ouch" then
		return "npc/combine_soldier/pain"..tostring(math.random(1,3))..".wav"
	
	
	
	
	
	end



end


list.Set( "NPC", "nb_combine2", {
	Name = "Combine Test 2",
	Class = "nb_combine2",
	Category = "MysticBot"
} )