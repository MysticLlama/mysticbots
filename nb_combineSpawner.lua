AddCSLuaFile()


ENT.Base = "base_point"
ENT.Spawnable = true

function ENT:Initialize()
	--self.spawnedSquad= false
	self.numAlive = 0
	self.peeps = {}



end




function ENT:Think()
	if self.numAlive < 2 then
		self:SpawnASquad()
	end
	
	local wkAlive =0
	for _,peep in pairs(self.peeps) do
		if IsValid(peep) and peep:Health() >0 then
			wkAlive = wkAlive+1
		end
	
	
	end
	self.numAlive = wkAlive



end


function ENT:SpawnASquad()
	s1 = ents.Create("nb_combine2")
		s2 = ents.Create("nb_combine2")
		s3= ents.Create("nb_combine2")
		s4= ents.Create("nb_combine2")
		
		self:DeleteOnRemove(s1)
		self:DeleteOnRemove(s2)
		self:DeleteOnRemove(s3)
		self:DeleteOnRemove(s4)
		
		
		
		s1:SetPos(self:GetPos())
		s2:SetPos(self:GetPos()+Vector(100,0,0))
		s3:SetPos(self:GetPos()+Vector(0,100,0))
		s4:SetPos(self:GetPos()+(Vector(100,100,0)))
		
		s1:Spawn()
		s2:Spawn()
		s3:Spawn()
		s4:Spawn()
		
		s1.startingWeapon = "weapon_ar2"
		s2.startingWeapon = "weapon_smg1"
		s3.startingWeapon = "weapon_smg1"
		s4.startingWeapon = "weapon_shotgun"
		
		s1.squadleader = s1
		s2.squadleader = s1
		s3.squadleader = s1
		s4.squadleader = s1
		
		s1.squad = {s2,s3,s4}
		table.insert(self.peeps,s1)
		table.insert(self.peeps,s2)
		table.insert(self.peeps,s3)
		table.insert(self.peeps,s4)
		--self.spawnedSquad = true
		self.numAlive = self.numAlive +4




end


list.Set( "NPC", "nb_combineSpawner", {
	Name = "Combine Squad Spawner",
	Class = "nb_combineSpawner",
	Category = "MysticBot Spawners"
} )

