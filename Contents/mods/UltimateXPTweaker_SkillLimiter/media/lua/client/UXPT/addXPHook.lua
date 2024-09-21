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
    print("checkSkillLimiter: ", perk)
    local maxLevel = 10
    local currentPerkLevel = character:getPerkLevel(perk)
    local listPerksLimit = character:getModData().SkillLimiter
    if not listPerksLimit or type(listPerksLimit) ~= "table" then
        print("Errore: SkillLimiter non è definito o non è una tabella")
        return false
    end

    local perkLimit = listPerksLimit[perk]
    if not perkLimit then
        print("Perk non trovato in SkillLimiter: " .. tostring(perk))
        return false
    end

    print("checkSkillLimiter: trovato perkLimit per " .. perk)

    if currentPerkLevel == maxLevel then
        print("Il livello corrente del perk è uguale a maxLevel (" .. maxLevel .. ")")
        return true
    end

    local limitLevel = perkLimit[3]
    if limitLevel and currentPerkLevel >= limitLevel then
        print("checkSkillLimiter: dentro if currentPerkLevel >= perkLimit[3] " .. currentPerkLevel .. " >= " .. limitLevel)
        return true
    else
        if limitLevel == nil then
            print("Errore: perkLimit[3] è nil per il perk " .. tostring(perk))
        else
            print("Il livello corrente del perk non ha raggiunto il limite (" .. currentPerkLevel .. " < " .. limitLevel .. ")")
        end
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