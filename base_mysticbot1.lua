AddCSLuaFile()

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true

--todo: make a base

function ENT:Initialize()
	--print( self, "Initialize" )
	self:SetModel( "models/Humans/Group03/male_02.mdl" ) -- rng this
	
	self.state = "idle"
	self.startingWeapon = "weapon_smg1"
	
	--weapon_smg1
	--weapon_shotgun
	--weapon_ar2
	
	self.wep = nil
	self.wepFire = nil

	
	
	self.squadleader = nil
	self.squad = nil
	
	self.validEnemies = {"npc_citizen"}
	
	
	if SERVER then
		self:SetHealth( 20 )
	end
end


function ENT:RunBehaviour()


	self.nextFire = CurTime()
	self.fireDelay = .06
	self.burstDelay = .5
	self.burstSize =10
	self.burstFired =0
	
	self.ableToFire = true
	
	
	self.maxFireRange = 1500 -- max distance a target can be frm me before i try moving closer.
	self.minFireRange = 1000 -- min distance i need to be form target to start fighting them.
	self.followRange = 100 -- how far do i need to be to my leader furing follow
	self.mvPos = nil -- where am i moving
	
	
	self.runSpeed = 170
	self.walkSpeed = 70
	self.moveStuck = false
	self.stuckTgt = nil
	
	self.enemy = nil
	
	self.loco:SetStepHeight(30)


	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	while true do
	
	
	--self:StartActivity( ACT_IDLE_ANGRY_SMG1 )
	
	if self.wep == nil then
		self:GiveWeapon(self.startingWeapon)
		--weapon_smg1
	end
	
	
	
	--[[enemies = ents.FindByClass("npc_citizen")
	--table.sort(enemies,function(a,b) return self:GetRangeSquaredTo(a:GetPos()) < self:GetRangeSquaredTo(b:GetPos())end)
	enemies_alive ={}
	
	for t =1,#enemies do
		if enemies[t] != nil and enemies[t]:Health()>0 then
			table.insert(enemies_alive,#enemies_alive,enemies[t])
			
		end
	end
	
	table.sort(enemies_alive,function(a,b) return self:GetRangeSquaredTo(a:GetPos()) < self:GetRangeSquaredTo(b:GetPos())end)
	local self.enemy = enemies_alive[0]
	--]]
	
	if self.enemy == nil then
	
		local sortedEnemies = self:SortByDistance(self:GetEnemies())
	
		self.enemy = sortedEnemies[1]
	end
	
	if self.enemy ~= nil then
	
			if self:GetSquadLeader() == nil or self:IsSquadLeader() then -- if i am or don't have  a squadleader
				if self:GetRangeTo(self.enemy:GetPos()) > self.maxFireRange or not self:IsLineOfSightClear(self.enemy:GetPos()) then
					self.ableToFire = false
					--move to my enemy
					self:SetActivity(ACT_RUN_RIFLE)
					self:Close(self.enemy:GetPos(),self.runSpeed,self.minDist)
					
				else
					self.loco:SetDesiredSpeed(0)
					self:SetActivity(ACT_IDLE_ANGRY_SMG1)
					self.ableToFire = true
					
				end
			else
				
				if self.enemy ~= nil and self:GetSquadLeader() ~= nil and self:GetSquadLeader():GetRangeTo(self.enemy:GetPos()) > self.maxFireRange  then 
				-- if squad leader isn't in position to engage
					if self:GetRangeTo(self:GetSquadLeader():GetPos()) > self.followRange or self.stuckTgt == self:GetSquadLeader() then 
					-- move to squad leader if too far, or if i'm in thier way
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
							if self:IsLineOfSightClear(self.enemy:GetPos()) then
								self.loco:SetDesiredSpeed(0)
								self:SetActivity(ACT_IDLE_ANGRY_SMG1)
								self.ableToFire = true
							else
								self.ableToFire = false
								self:SetActivity(ACT_RUN_RIFLE)
								self:Close(self.enemy:GetPos(),self.runSpeed,self.minDist)
								self.mvPos = self:GetPos()
							end
						end
						
					else
						self.mvPos = self:GetSquadLeader():GetPos() +self:GetSquadLeader():GetForward() * math.Rand(20,300) + self:GetSquadLeader():GetRight() * (math.Rand(100,500) * math.random(-1,1))
						
					end
				end
					
			end
			
			
			
			if self.ableToFire then
				self.loco:FaceTowards(self.enemy:GetPos())
				self:ShootBullets(self.enemy:GetPos()+Vector(0,0,50)) -- shoot at my target
			end
	else
		self:SetActivity(ACT_IDLE_SMG1)
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
	if(info:GetDamage() < self:Health()) then
	
		self:EmitSound( self:SaySound("ouch") ) --make an ouch sound when hit, but not if i die to the incoming damage
	end
	self:AddGestureSequence( self:LookupSequence( "flinch_gesture" ) ) -- flinch against incoming damage
	
	if IsValid(self.enemy) and self:GetRangeSquaredTo(info:GetAttacker()) < self:GetRangeSquaredTo(self.enemy) then
		self.enemy = info:GetAttacker() -- change enemy to attacker if attacker is closer than my enemy
	
	
	end
	
	
end

function ENT:OnKilled(info)


	if self:IsSquadLeader() and #self.squad > 0 then
		print(self)
		PrintTable(self.squad)
		local nwSquadLeader = table.remove(self.squad,1)
		
		
		nwSquadLeader.squad = self.squad -- make next squad member the new squad leader
		nwSquadLeader.squadleader = nwSquadLeader
		--print("made ",self.squad[1]," a new squadleader")
		
		--table.RemoveByValue(self.squad[1].squad,self.squad[1]) -- remove my new squad leader from new squad
		
		for i =1,#self.squad do
			self.squad[i].squadleader = nwSquadLeader -- update squadleader for each squadmember
			
		
		end
		
	end
 
	self:EmitSound(self:SaySound("dead"))
	self:BecomeRagdoll(info)
	timer.Simple(.01,function() self:Remove() end) -- remove myself so there isn't a ghost

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
	
	if v == self.enemy then
		self.enemy = nil
	
	end



end



function ENT:SaySound(input)
	--ouch, dead
	
	if input == "dead" then
		return "vo/npc/male01/pain0"..tostring(math.random(1,9))..".wav"
	elseif input == "ouch" then
		return "vo/npc/male01/ow0"..tostring(math.random(1,2))..".wav"
	
	
	
	
	
	end



end


function ENT:OnContact(ent)

	
	
	
	if(ent:GetClass() == self:GetClass()) then
		
		--self.loco:SetVelocity( self.loco:GetVelocity() + VectorRand() * 100 )
		--self.loco:Approach(ent:GetPos()+ self:GetRight()*1000,1)
		--print("stuck on",ent)
		--self.mvPos = ent:GetPos()+ self:GetRight()*300
		--self.stuckTgt = ent
		--self.moveStuck = true
		print("colliding with ",ent)
		constraint.NoCollide(self,ent,0,0)
	else
		--self.stuckTgt = nil
		--self.moveStuck =false
	
	end
end


function ENT:GiveWeapon(name) -- give this bot a weapon of input class
	if self == nil then return end
	
	
	local att = "anim_attachment_RH"
	local wPos = self:GetAttachment(self:LookupAttachment(att))
	
	
	local weapon = ents.Create(name)
	local wFP = ents.Create("nb_weaponPos") -- Source tracers are retarded and will only originate from origin 
	--of weapon unless you use a middleman
	
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

function ENT:ShootBullets(where) -- shoot bullets towards "where"

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
		
	end


end


function ENT:MoveTo(pos,speed, minDist) --move towards a pos, stop if i'm within minDist


	
	minDist = minDist or 300
	
	if self.moveStuck then
		pos = (self.stuckTgt:GetPos() - self:GetPos()):GetNormalized() *300 + self:GetPos()
		
	end
	
	if self:GetRangeTo(pos) <= minDist then return end
		
	
	local path = Path("Chase")
	path:SetMinLookAheadDistance(300)
	path:SetGoalTolerance(100)
	
	path:Compute(self,pos)
	--path:Draw()
	
	self.loco:SetDesiredSpeed(speed)
	path:Update(self)
end


function ENT:Close(pos,speed,minDist) -- move towards pos until i'm within minDist and i can draw a line to pos
	minDist = minDist or 300
	
	if self.moveStuck then
		pos = (self.stuckTgt:GetPos() - self:GetPos()):GetNormalized() *300 + self:GetPos()
	end
	
	if self:IsLineOfSightClear(pos) and self:GetRangeTo(pos) <= minDist then return end
		
	
	local path = Path("Chase")
	path:SetMinLookAheadDistance(300)
	path:SetGoalTolerance(100)
	
	path:Compute(self,pos)
	--path:Draw()
	
	self.loco:SetDesiredSpeed(speed)
	path:Update(self)


end


function ENT:SetActivity(act) -- Start an activity, but don't restart if already running input.
	

	if self:GetActivity() == act then return end
	self:StartActivity(act)
	
	

end

function ENT:LookupActivity(act) -- when you need the sequence number for an activity
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
	if self.squadleader ~= nil and IsValid(self.squadleader) then	
		return self.squadleader
	else
		return nil
	end

end



function ENT:GetEnemies()--return a list of valid enemies
	local everyone = ents.GetAll()
	
	local validEnemies ={}
	
	for i = 1,#everyone do
		for j =1,#self.validEnemies do
			if everyone[i]:GetClass() == self.validEnemies[j] and everyone[i]:Health() >0 then
				table.insert(validEnemies,everyone[i])
			end
		end
	
	end

	return validEnemies


end


function ENT:SortByDistance(tbl)
	local sol = tbl
	
	table.sort(sol,
		function(a,b)
			return self:GetRangeSquaredTo(a:GetPos()) < self:GetRangeSquaredTo(b:GetPos())
		end)
		
	return sol
	
end





