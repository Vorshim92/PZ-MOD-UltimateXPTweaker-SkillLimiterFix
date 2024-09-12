require "UXPT/UxptMultiplierMath"

-- patch SkillLimiter
local isSkillLimiter = false
local SkillLimiter = nil
if getActivatedMods():contains("SkillLimiter_BETA") then
    isSkillLimiter = true
    print("UXPT: Inside getActivatedMods SkillLimiter")
    SkillLimiter = require("SkillLimiter") or nil
end

local function addExtraXp(gamechar, perk, xpAmount)
    local perkLevel = gamechar:getPerkLevel(perk)
    local boostLevel = gamechar:getXp():getPerkBoost(perk)
    
    local mult = UxptMultiplierMath.skill(perk) * UxptMultiplierMath.actualBoost(perk, boostLevel) * UxptMultiplierMath.extra(perk, perkLevel)
    local extraXP = xpAmount * (mult - 1)
    
    if getDebug() then
        print("UXPT : " .. tostring(perk) .. "_" .. boostLevel .. " (" .. UxptMultiplierMath.skill(perk) .. "," .. UxptMultiplierMath.actualBoost(perk, boostLevel) .. "," .. UxptMultiplierMath.extra(perk, perkLevel) .. ") : " .. tostring(xpAmount) .. " + " .. tostring(extraXP) .. " = " .. tostring(xpAmount + extraXP))
    end

    if extraXP > 0 then
        -- patch skillLimiter
        if isSkillLimiter and SkillLimiter then
            print("UXPT: Inside SkillLimiter condition AddXPHook.lua")
            local result = SkillLimiter.checkLevelMax(gamechar, perk)
            if not result then
                gamechar:getXp():AddXP(perk, extraXP, true, false, false)
            end
        else
        gamechar:getXp():AddXP(perk, extraXP, true, false, false)
        end
    end
end

Events.AddXP.Add(addExtraXp)