AddCSLuaFile()

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= false


function ENT:Initialize()
	self:SetModel("models/Items/Flare.mdl") -- nextbot will error wo a model
	--self:SetNoDraw(false)
	
	

	self.owner = nil



end




function ENT:RunBehavior()
	while true do
		if self.owner != nil then
			self:SetPos(self.owner:GetPos())
		end

	end
end




