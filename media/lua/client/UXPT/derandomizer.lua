require "XpSystem/XpUpdate"
-- patch SkillLimiter
local isSkillLimiter = false
local SkillLimiter = nil
if getActivatedMods():contains("SkillLimiter_BETA") then
    isSkillLimiter = true
    print("UXPT: Inside getActivatedMods SkillLimiter")
    SkillLimiter = require("SkillLimiter") or nil
end


local function handleXpGain(player, counter, perk, interval, xpAmount)
    while (counter > interval) do
        counter = counter - interval
        if isSkillLimiter and SkillLimiter then
            local result = SkillLimiter.checkLevelMax(player, perk)
            if not result then
				print("UXPT: Adding XP after checkLevelMaxs " .. tostring(xpAmount))
                player:getXp():AddXP(perk, xpAmount)
            end
        else
            player:getXp():AddXP(perk, xpAmount)
        end
    end
    return counter
end



Events.OnGameStart.Add(function()
	if isServer() or not SandboxVars.UXPT_Advanced.Derandomize then return end
	
	local fitnessCounter = 0
	local strengthCounter = 0
	local nimbleCounter = 0
	local sprintingCounter = 0
	
	local onPlayerMove_original = xpUpdate.onPlayerMove
	Events.OnPlayerMove.Remove(xpUpdate.onPlayerMove)
	Events.OnPlayerMove.Add(
		function()

			
			
			local player = getPlayer();			
			-- instead of using the getMultiplier() value to determine the chance, we just keep adding it up until it reaches the threshold, and then give XP and set it to 0
			local mult = GameTime:getInstance():getMultiplier()
			
			-- if you're running and your endurance has changed
			if (player:IsRunning() or player:isSprinting()) and player:getStats():getEndurance() > player:getStats():getEndurancewarn() then
				-- you may gain 1 xp in sprinting or fitness
				fitnessCounter = fitnessCounter + mult
				sprintingCounter = sprintingCounter + mult
			end
			
			-- aiming while moving, gain nimble xp (move faster in aiming mode)
			if player:isAiming() then
				nimbleCounter = nimbleCounter + mult
			end
			
			-- if you're walking with a lot of stuff, you may gain in Strength
			if player:getInventoryWeight() > player:getMaxWeight() * 0.5 then
				strengthCounter = strengthCounter + mult
			end
			
			fitnessCounter = handleXpGain(player, fitnessCounter, Perks.Fitness, SandboxVars.UXPT_Advanced.Fitness_interval, 1)
			sprintingCounter = handleXpGain(player, sprintingCounter, Perks.Sprinting, SandboxVars.UXPT_Advanced.Sprinting_interval, 1)
			nimbleCounter = handleXpGain(player, nimbleCounter, Perks.Nimble, SandboxVars.UXPT_Advanced.Nimble_interval, 1)
			strengthCounter = handleXpGain(player, strengthCounter, Perks.Strength, SandboxVars.UXPT_Advanced.Strength_interval, 2)


			
		end
	)
	
	print('UXPT: Derandomizer enabled')
		
end)
