require "UXPT/UxptMultiplierMath"

-- patch SkillLimiter
local isSkillLimiter = false
local SkillLimiter = nil
if getActivatedMods():contains("SkillLimiter_fix") then
    isSkillLimiter = true
    print("UXPT: Inside getActivatedMods SkillLimiter")
    SkillLimiter = require("SkillLimiter")
end

local function addExtraXp(gamechar, perk, xpAmount)
    if xpAmount <= 0 then return end
    local perkLevel = gamechar:getPerkLevel(perk)
    local boostLevel = gamechar:getXp():getPerkBoost(perk)
    
    local mult = UxptMultiplierMath.skill(perk) * UxptMultiplierMath.actualBoost(perk, boostLevel) * UxptMultiplierMath.extra(perk, perkLevel)
    local extraXP = xpAmount * (mult - 1)
    
    if getDebug() then
        print("UXPT : " .. tostring(perk) .. "_" .. boostLevel .. " (" .. UxptMultiplierMath.skill(perk) .. "," .. UxptMultiplierMath.actualBoost(perk, boostLevel) .. "," .. UxptMultiplierMath.extra(perk, perkLevel) .. ") : " .. tostring(xpAmount) .. " + " .. tostring(extraXP) .. " = " .. tostring(xpAmount + extraXP))
    end

    if extraXP > 0 then
        -- patch skillLimiter - usa funzione utility centralizzata
        if isSkillLimiter and SkillLimiter then
            if SkillLimiter.isAtMaxLevel(gamechar, perk) then
                if getDebug() then
                    print("UXPT: Livello massimo raggiunto per " .. perk:getName() .. ", XP bonus non aggiunta")
                end
                return  -- Non aggiungere XP, il personaggio è al limite
            end
        end

        -- Aggiungi XP bonus (SkillLimiter rimuoverà l'eccesso al prossimo XP gain se necessario)
        gamechar:getXp():AddXP(perk, extraXP, false, false, false)
    end
end

Events.AddXP.Add(addExtraXp)