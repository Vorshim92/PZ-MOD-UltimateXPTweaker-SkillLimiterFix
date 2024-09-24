require "UXPT/UxptMultiplierMath"

-- patch SkillLimiter
local isSkillLimiter = false
-- local SkillLimiter = nil
if getActivatedMods():contains("SkillLimiter_fix") then
    isSkillLimiter = true
    print("UXPT: Inside getActivatedMods SkillLimiter")
    -- SkillLimiter = require("SkillLimiter") or nil
end

local function checkSkillLimiter(character, perk)
    print("checkSkillLimiter: ", perk:getName())
    local maxLevel = 10
    local currentPerkLevel = character:getPerkLevel(perk)
    if currentPerkLevel == maxLevel then
        print("Il livello corrente è già al lvl 10, non aggiungere XP")
        return true
    end
    local listPerksLimit = character:getModData().skillLimiter
    if not listPerksLimit then
        print("checkSkillLimiter: SkillLimiter non è definito o non è una tabella")
        return false
    end
    
    local perkData = listPerksLimit[perk:getId()]
    if perkData then
        print("checkSkillLimiter: Dati trovati per il perk " .. perk:getName())
        local limitLevel = perkData["maxLevel"]
        if limitLevel then
            if currentPerkLevel >= limitLevel then
                print("checkSkillLimiter: livello corrente >= limitLevel (" .. currentPerkLevel .. " >= " .. limitLevel .. ")")
                return true
            end
        else
            print("checkSkillLimiter: limitLevel non definito per il perk " .. perk:getName())
        end
    else
        print("checkSkillLimiter: Nessun dato trovato per il perk " .. perk:getName())
    end
    return false
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
            print("UXPT: Risultato di checkSkillLimiter: ", result)
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