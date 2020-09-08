AddCSLuaFile()

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true

--todo:make a base

function ENT:Initialize()
	--print( self, "Initialize" )
	self:SetModel( "models/Combine_Soldier.mdl" )
	
	self.state = "idle"
	self.startingWeapon = "weapon_ar2"
	
	--weapon_smg1
	--weapon_shotgun
	--weapon_ar2
	
	self.wep = nil
	self.wepFire = nil

	self.nextFire = CurTime()
	self.fireDelay = .06
	self.burstDelay = .5
	self.burstSize =10
	self.burstFired =0
	
	self.ableToFire = true
	
	
	self.maxFireRange = 1500 -- max distance a target can be frm me before i try moving closer.
	self.minFireRange = 1000 -- min distance i need to be form target to start fighting them.
	self.followRange = 100
	self.mvPos = nil
	
	
	self.runSpeed = 170
	self.walkSpeed = 70
	
	self.squadleader = nil
	self.squad = nil
	
	
	if SERVER then
		self:SetHealth( 20 )
	end
end


function ENT:RunBehaviour()
	while true do
	--print( self, "RunBehaviour" )
	
	--self:StartActivity( ACT_IDLE_ANGRY_SMG1 )
	
	if self.wep == nil then
		self:GiveWeapon(self.startingWeapon)
		--weapon_smg1
	end
	
	
	
	
	
	
	
	enemies = ents.FindByClass("nb_testRebel")
	--table.sort(enemies,function(a,b) return self:GetRangeSquaredTo(a:GetPos()) < self:GetRangeSquaredTo(b:GetPos())end)
	enemies_alive ={}
	
	for t =1,#enemies do
		if enemies[t] != nil and enemies[t]:Health()>0 then
			table.insert(enemies_alive,#enemies_alive,enemies[t])
			
		end
	end
	
	table.sort(enemies_alive,function(a,b) return self:GetRangeSquaredTo(a:GetPos()) < self:GetRangeSquaredTo(b:GetPos())end)
	local firstE = enemies_alive[0]
	
	if firstE ~= nil then
	
			if self:GetSquadLeader() == nil or self:IsSquadLeader() then -- if i am or don't have  a squadleader
				if self:GetRangeTo(firstE:GetPos()) > self.maxFireRange or not self:IsLineOfSightClear(firstE:GetPos()) then
					self.ableToFire = false
					--move to my enemy
					self:SetActivity(ACT_RUN_RIFLE)
					self:Close(firstE:GetPos(),self.runSpeed,self.minDist)
				else
					self.loco:SetDesiredSpeed(0)
					self:SetActivity(ACT_IDLE_ANGRY_SMG1)
					self.ableToFire = true
				end
			else
				if firstE ~= nil and self:GetSquadLeader():GetRangeTo(firstE:GetPos()) > self.maxFireRange and self:GetSquadLeader():IsLineOfSightClear(firstE:GetPos()) then 
				-- if squad leader isn't in position to engage
					if self:GetRangeTo(self:GetSquadLeader():GetPos()) > self.followRange then 
					-- move to squad leader if too far
						self.mvPos = nil
						self.ableToFire = false
						self:SetActivity(ACT_RUN_RIFLE)
						self:MoveTo(self:GetSquadLeader():GetPos(),self.runSpeed,self.followRange)
					else -- stand stil if near squad leader
					self.ableToFire = false
						self:SetActivity(ACT_IDLE_ANGRY_SMG1)
					end
				else 
				-- if squad leader near target
					if self.mvPos ~= nil then 
						-- if i have somewhere to move
						if self:GetRangeTo(self.mvPos) > self.followRange then
							self.ableToFire = false
							--move to my enemy
							self:SetActivity(ACT_RUN_RIFLE)
							self:MoveTo(self.mvPos,self.runSpeed,self.followRange)
						else
							self.loco:SetDesiredSpeed(0)
							self:SetActivity(ACT_IDLE_ANGRY_SMG1)
							self.ableToFire = true
						end
						
					else
						self.mvPos = self:GetSquadLeader():GetPos() +self:GetSquadLeader():GetForward() * math.Rand(20,300) + self:GetSquadLeader():GetRight() * (math.Rand(100,500) * math.random(-1,1))
						
					end
				end
					
			end
			
			
			
			if self.ableToFire then
				self.loco:FaceTowards(firstE:GetPos())
				self:ShootBullets(firstE:GetPos()+Vector(0,0,50)) -- shoot at my target
			end
	else
		self:SetActivity(ACT_IDLE)
		self.mvPos = nil
	end
	
	
		
	
	
	
	coroutine.yield()
	end
end




function ENT:OnInjured( info )
	print( self, "OnInjured" )
	
	if info:GetAttacker() == self or info:GetAttacker():GetClass() == self:GetClass() then
		self:SetHealth(self:Health() + info:GetDamage()) -- don't hurt myself, reverse damage from friendly fire
		return
		
	end
	
	if info:GetAttacker():GetClass() == self:GetClass() then
		info:GetAttacker().mvPos = nil  -- force ally to move if recieving friendly fire
		self.mvPos = nil
		return
	
	end
	
	self:EmitSound( "npc/combine_soldier/pain"..tostring(math.random(1,3))..".wav" )
	self:AddGestureSequence( self:LookupSequence( "flinch_gesture" ) )
end

function ENT:OnKilled(info)


	if self:IsSquadLeader() and #self.squad > 1 then
		self.squad[1].squad = self.squad -- make next squad member the new squad leader
		table.remove(self.squad[1].squad,1) -- remove my new squad leader form new squad
		for i =1,#self.squad do
			self.squadleader = self.squad[1] -- update squadleader for each squadmember
		
		end
		
	end
 
	self:EmitSound("npc/combine_soldier/die"..tostring(math.random(1,3))..".wav")
	self:BecomeRagdoll(info)
	timer.Simple(.01,function() self:Remove() end)

end

function ENT:OnOtherKilled(v,info)

	if v:GetClass() == self:GetClass() then
		if self:IsSquadLeader() then
			for i=1,#self.squad do
				if v== self.squad[i] then
					table.remove(self.squad,i) -- remove dead squadmembers
					break
				end
			end
		end
	
	end



end



function ENT:OnContact(ent)
	
	if(ent:GetClass() == self:GetClass()) then
		--print("do be mememing")
		self.loco:SetVelocity( self.loco:GetVelocity() + VectorRand() * 100 )
	end
end





function ENT:GiveWeapon(name)
	if self == nil then return end
	
	
	local att = "anim_attachment_RH"
	local wPos = self:GetAttachment(self:LookupAttachment(att))
	
	--self:GetAttachment(self:LookupAttachment("anim_attachment_RH"))
	--print("w pos is ",wPos.Pos)
	
	local weapon = ents.Create(name)
	local wFP = ents.Create("nb_weaponPos") -- Source tracers are retarded and will only originate from origin 
	--of weapon unless you use a middleman
	
	--print("hello!")
	weapon:SetOwner(self)
	weapon:SetPos(wPos.Pos)
	
	
	weapon:Spawn()
	
	wFP:SetOwner(weapon)
	
	wFP:SetSolid(SOLID_NONE)
	wFP:SetParent(weapon)
	wFP:SetPos(weapon:GetPos())
	wFP.owner = self.wep
	self.wepFire = wFP
	
	weapon:SetParent(self)
	
	weapon:SetTrigger(false)
	weapon:SetSolid(SOLID_NONE)
	weapon:Fire("setparentattachment","anim_attachment_RH")
	weapon:AddEffects(EF_BONEMERGE)
	weapon:SetAngles(self:GetForward():Angle())
	
	self.wep = weapon
	


end

function ENT:ShootBullets(where)

	if not self.ableToFire or CurTime() < self.nextFire then return end -- don't attempt to fire before i'm able to
	

	local bullet ={} -- create a bullet object
		bullet.Damage = 4
		bullet.Attacker = self
		bullet.Num = 1
		bullet.Tracer = 1
		bullet.AmmoType = "Pistol"
		bullet.TracerName = nil
		bullet.Spread = Vector(.1,.1,0)
		bullet.Src = self.wep:GetPos()+Vector(0,0,7)+self.wep:GetForward()*15
		bullet.Dir = (where-bullet.Src  ):GetNormalized()
		
	if self.startingWeapon == "weapon_ar2" then -- if i have a pulse-rifle
		bullet.Damge = 5
		bullet.TracerName = "AR2Tracer"
		bullet.Spread = Vector(.05,.05,0)
		self:EmitSound("Weapon_AR2.NPC_Single")
		self.fireDelay =.1
		self:AddGestureSequence(self:LookupSequence("gesture_shoot_smg1")) 
	elseif self.startingWeapon == "weapon_shotgun" then -- if i have a shotgun
		bullet.Num = 7
		bullet.Damage = 3
		bullet.Spread = Vector(.1,.1,0)
		self:EmitSound("Weapon_Shotgun.Single")
		self.fireDelay = 1.2
		self:AddGestureSequence(self:LookupSequence("gesture_shoot_shotgun")) 
	else -- if i have an smg
		self:EmitSound("Weapon_SMG1.NPC_Single")
		self.fireDelay = .065
		self:AddGestureSequence(self:LookupSequence("gesture_shoot_smg1")) 
	end
		
	
	self.wepFire:FireBullets(bullet,false) -- tell my weapon firing psition to shoot the bullets
	self.burstFired = self.burstFired +1 -- keep track of bullest fired for the burst
	
	
	
	
	if self.burstFired < self.burstSize then
		self.nextFire = CurTime() + self.fireDelay
	else 
	
	
		self.nextFire = CurTime() + self.burstDelay
		self.burstFired =0
		
		
		self.burstSize = math.random(9,13)
		self.burstDelay = math.Rand(.3,.6)
		--print("burst delay is ",self.burstDelay)
	end


end


function ENT:MoveTo(pos,speed, minDist)
	minDist = minDist or 300
	
	if self:GetRangeTo(pos) <= minDist then return end
		
	
	local path = Path("Chase")
	path:SetMinLookAheadDistance(300)
	path:SetGoalTolerance(100)
	
	path:Compute(self,pos)
	
	self.loco:SetDesiredSpeed(speed)
	path:Update(self)
end


function ENT:Close(pos,speed,minDist)
	minDist = minDist or 300
	
	if self:IsLineOfSightClear(pos) and self:GetRangeTo(pos) <= minDist then return end
		
	
	local path = Path("Chase")
	path:SetMinLookAheadDistance(300)
	path:SetGoalTolerance(100)
	
	path:Compute(self,pos)
	
	self.loco:SetDesiredSpeed(speed)
	path:Update(self)


end


function ENT:SetActivity(act)
	--print("running act is ",self:LookupActivity(self:GetActivity()), " but i want to run ",self:LookupActivity(act))

	if self:GetActivity() == act then return end
	
	--print("attemptng to start act ",act)
	self:StartActivity(act)
	--print("started act",self:GetSequenceActivityName(act))
	

end

function ENT:LookupActivity(act)
	return self:GetSequenceActivityName(self:SelectWeightedSequence(act))


end


function ENT:IsSquadLeader()
	if self.squadleader == self then
		return true
	else
		return false
	end

end

function ENT:GetSquadLeader()
	if self.squadleader ~= nil then	
		return self.squadleader
	else
		return self
	end

end





list.Set( "NPC", "nb_testCombine", {
	Name = "Test Combine 1",
	Class = "nb_testCombine",
	Category = "MysticBot"
} )