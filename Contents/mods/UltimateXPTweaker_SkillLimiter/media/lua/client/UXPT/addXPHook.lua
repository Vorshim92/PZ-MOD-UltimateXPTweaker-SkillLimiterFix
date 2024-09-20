require "UXPT/UxptMultiplierMath"

-- patch SkillLimiter
local isSkillLimiter = false
-- local SkillLimiter = nil
if getActivatedMods():contains("SkillLimiter_fix") then
    isSkillLimiter = true
    print("UXPT: Inside getActivatedMods SkillLimiter")
    -- SkillLimiter = require("SkillLimiter") or nil
end

local function checkSkillLimiter(perk, character)
    local result = false
    local maxLevel = 10
    local currentPerkLevel = character:getPerkLevel(perk)
    local listPerksLimit = character:getModData().SkillLimiter.perkDetails_LIST
    for _, v in pairs(listPerksLimit) do
        if v:getPerk() == perk then
            print("checkLevelMax: dentro if v:getPerk() == perk")
            -- print("checkLevelMax: v:getCurrentLevel(): ", v:getCurrentLevel())
            print("checkLevelMax: v:getMaxLevel(): ", v:getMaxLevel())
            if currentPerkLevel == maxLevel then
                result = true
                return result
            end
        
            if currentPerkLevel >= v:getMaxLevel() then
                print("checkLevelMax: dentro if currentPerkLevel >= v:getMaxLevel() " .. currentPerkLevel .. " >= " .. v:getMaxLevel())
                result = true
            end
            break
        end
    end
return result
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
        -- patch skillLimiter
        if isSkillLimiter then
            print("UXPT: Inside SkillLimiter condition AddXPHook.lua")
            local result = checkSkillLimiter(gamechar, perk)
            -- Aggiungi print per vedere il valore di result
            print("UXPT: Risultato di checkLevelMax: ", result)
            -- Se result è true, ritorna subito
            if result then
                print("UXPT: Livello massimo raggiunto, XP non aggiunta")
                return  -- Interrompi la funzione, non aggiungere XP
            end
            -- Se result è false, aggiungi gli extraXP
            if not result then
                gamechar:getXp():AddXP(perk, extraXP, false, false, false)
            end
        else
        -- Se SkillLimiter non è attivo, aggiungi comunque gli extraXP
        gamechar:getXp():AddXP(perk, extraXP, false, false, false)
        end
    end
end

Events.AddXP.Add(addExtraXp)