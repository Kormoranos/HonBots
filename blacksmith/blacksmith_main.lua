

local _G = getfenv(0)
local object = _G.object

object.myName = object:GetName()

object.bRunLogic         = true
object.bRunBehaviors    = true
object.bUpdates         = true
object.bUseShop         = true

object.bRunCommands     = true 
object.bMoveCommands     = true
object.bAttackCommands     = true
object.bAbilityCommands = true
object.bOtherCommands     = true

object.bReportBehavior = false
object.bDebugUtility = false

object.logger = {}
object.logger.bWriteLog = false
object.logger.bVerboseLog = false

object.core         = {}
object.eventsLib     = {}
object.metadata     = {}
object.behaviorLib     = {}
object.skills         = {}

runfile "bots/core.lua"
runfile "bots/botbraincore.lua"
runfile "bots/eventsLib.lua"
runfile "bots/metadata.lua"
runfile "bots/behaviorLib.lua"

local core, eventsLib, behaviorLib, metadata, skills = object.core, object.eventsLib, object.behaviorLib, object.metadata, object.skills

local print, ipairs, pairs, string, table, next, type, tinsert, tremove, tsort, format, tostring, tonumber, strfind, strsub
    = _G.print, _G.ipairs, _G.pairs, _G.string, _G.table, _G.next, _G.type, _G.table.insert, _G.table.remove, _G.table.sort, _G.string.format, _G.tostring, _G.tonumber, _G.string.find, _G.string.sub
local ceil, floor, pi, tan, atan, atan2, abs, cos, sin, acos, max, random
    = _G.math.ceil, _G.math.floor, _G.math.pi, _G.math.tan, _G.math.atan, _G.math.atan2, _G.math.abs, _G.math.cos, _G.math.sin, _G.math.acos, _G.math.max, _G.math.random

local BotEcho, VerboseLog, BotLog = core.BotEcho, core.VerboseLog, core.BotLog
local Clamp = core.Clamp


BotEcho(object:GetName()..' loading <hero>_main...')




--####################################################################
--####################################################################
--#                                                                 ##
--#                  bot constant definitions                       ##
--#                                                                 ##
--####################################################################
--####################################################################

-- hero_<hero>  to reference the internal hon name of a hero, Hero_Yogi ==wildsoul
object.heroName = 'Hero_DwarfMagi'


--   item buy order. internal names  
behaviorLib.StartingItems  = {"Item_RunesOfTheBlight", "Item_IronBuckler", "Item_LoggersHatchet"}
behaviorLib.LaneItems  = {"Item_Marchers", "Item_Replenish", "Item_EnhancedMarchers"}
behaviorLib.MidItems  = {"Item_Nuke 3"}
behaviorLib.LateItems  = {"Item_Morph", "Item_Nuke 5"}


-- skillbuild table, 0=q, 1=w, 2=e, 3=r, 4=attri
object.tSkills = {
    0, 1, 0, 1, 0,
    3, 0, 1, 1, 2, 
    3, 2, 2, 2, 4,
    3, 4, 4, 4, 4,
    4, 4, 4, 4, 4,
}

-- bonus agression points if a skill/item is available for use
object.abilQUp = 10
object.abilWUp = 10
object.abilEUp = 15
object.nNukeUp = 20
object.nSheepUp = 18
-- bonus agression points that are applied to the bot upon successfully using a skill/item
object.abilQUse = 10
object.abilWUse = 10
object.abilEUse = 15
object.nNukeUse = 10
object.nSheepUse = 18
--thresholds of aggression the bot must reach to use these abilities
object.abilQThreshold = 20
object.abilWThreshold = 20
object.abilEThreshold = 16
object.nNukeThreshold = 40
object.nSheepThreshold = 20


--####################################################################
--####################################################################
--#                                                                 ##
--#   bot function overrides                                        ##
--#                                                                 ##
--####################################################################
--####################################################################

------------------------------
--     skills               --
------------------------------
-- @param: none
-- @return: none
function object:SkillBuild()
    core.VerboseLog("skillbuild()")

-- takes care at load/reload, <name_#> to be replaced by some convinient name.
    local unitSelf = self.core.unitSelf
    if  skills.abilQ == nil then
        skills.abilQ = unitSelf:GetAbility(0)
        skills.abilW = unitSelf:GetAbility(1)
        skills.abilE = unitSelf:GetAbility(2)
        skills.abilR = unitSelf:GetAbility(3)
        skills.abilAttributeBoost = unitSelf:GetAbility(4)
    end
    if unitSelf:GetAbilityPointsAvailable() <= 0 then
        return
    end
    
   
    local nlev = unitSelf:GetLevel()
    local nlevpts = unitSelf:GetAbilityPointsAvailable()
    for i = nlev, nlev+nlevpts do
        unitSelf:GetAbility( object.tSkills[i] ):LevelUp()
    end
end

------------------------------------------------------
--            onthink override                      --
-- Called every bot tick, custom onthink code here  --
------------------------------------------------------
-- @param: tGameVariables
-- @return: none
function object:onthinkOverride(tGameVariables)
    self:onthinkOld(tGameVariables)

    -- custom code here
end
object.onthinkOld = object.onthink
object.onthink 	= object.onthinkOverride




----------------------------------------------
--            oncombatevent override        --
-- use to check for infilictors (fe. buffs) --
----------------------------------------------
-- @param: eventdata
-- @return: none
function object:oncombateventOverride(EventData)
   self:oncombateventOld(EventData)
   
   local bDebugEchos = false
   local addBonus = 0
   
   if EventData.Type == "Ability" then
   if bDebugEchos then BotEcho(" ABILITY EVENT! InflictorName: "..EventData.InflictorName) end
        if EventData.InflictorName == "Ability_DwarfMagi1" then
            addBonus = addBonus + object.abilQUse
			object.abilQUseTime = EventData.TimeStamp
			BotEcho(object.abilQUseTime)
   elseif EventData.InflictorName == "Ability_DwarfMagi2" then
            addBonus = addBonus + object.abilWUse
			object.abilWUseTime = EventData.TimeStamp
			BotEcho(object.abilWUseTime)
     end
	 elseif EventData.Type == "Item" then
		if core.itemNuke ~= nil and EventData.SourceUnit == core.unitSelf:GetUniqueID() and EventData.InflictorName == core.itemNuke:GetName() then
			nAddBonus = nAddBonus + self.nNukeUse
		end
		if core.itemSheepstick ~= nil and EventData.SourceUnit == core.unitSelf:GetUniqueID() and EventData.InflictorName == core.itemSheepstick:GetName() then
            nAddBonus = nAddBonus + self.nSheepUse
        end
   end
   if addBonus > 0 then
        core.DecayBonus(self)
        core.nHarassBonus = core.nHarassBonus + addBonus

	end
end		
-- override combat event trigger function.
object.oncombateventOld = object.oncombatevent
object.oncombatevent     = object.oncombateventOverride



------------------------------------------------------
--            customharassutility override          --
-- change utility according to usable spells here   --
------------------------------------------------------
-- @param: iunitentity hero
-- @return: number
local function AbilitiesUpUtility(hero)
local nUtility = 0
    
local unitSelf = core.unitSelf
	
    if skills.abilQ:CanActivate() then
        nUtility = nUtility + object.abilQUp
    end
 
    if skills.abilW:CanActivate() then
        nUtility = nUtility + object.abilWUp
    end
	
	if skills.abilE:CanActivate() then
        nUtility = nUtility + object.abilEUp
    end
	
	if object.itemNuke and object.itemNuke:CanActivate() then
        nUtility = nUtility + object.nNukeUp
    end
	
	if object.itemSheepstick and object.itemSheepstick:CanActivate() then
        nUtility = nUtility + object.nSheepStickUp
    end


    return nUtility
end

local function CustomHarassUtilityFnOverride(hero)
	local nUtility = AbilitiesUpUtility(hero)	
	
	return Clamp(nUtility, 0, 100)
end
-- assisgn custom Harrass function to the behaviourLib object
behaviorLib.CustomHarassUtility = CustomHarassUtilityFnOverride   



--Find Items PK
local function funcFindItemsOverride(botBrain)
	local bUpdated = object.FindItemsOld(botBrain)

	if bUpdated then
		--toDo Run File if inventory changed

		local inventory = core.unitSelf:GetInventory(true)
		for slot = 1, 6, 1 do
			local curItem = inventory[slot]
			if curItem then
				if core.itemNuke == nil and curItem:GetName() == "Item_Nuke" then
					core.itemNuke = core.WrapInTable(curItem)
				elseif core.itemTablet == nil and curItem:GetName() == "Item_PushStaff" then
					core.itemTablet = core.WrapInTable(curItem)
				elseif core.itemPortalKey == nil and curItem:GetName() == "Item_PortalKey" then
					core.itemPortalKey = core.WrapInTable(curItem)
				elseif core.itemFrostfieldPlate == nil and curItem:GetName() == "Item_FrostfieldPlate" then
					core.itemFrostfieldPlate = core.WrapInTable(curItem)
				elseif core.itemSheepstick == nil and curItem:GetName() == "Item_Morph" then
					core.itemSheepstick = core.WrapInTable(curItem)					
				elseif core.itemHellFlower == nil and curItem:GetName() == "Item_Silence" then
					core.itemHellFlower = core.WrapInTable(curItem)
				elseif core.itemReplenish == nil and curItem:GetName() == "Item_Replenish" then
					core.itemReplenish = core.WrapInTable(curItem)
				elseif core.itemSacStone == nil and curItem:GetName() == "Item_SacrificialStone" then
					core.itemSacStone = core.WrapInTable(curItem)
				end
				
			end
		end
	end
end
object.FindItemsOld = core.FindItems
core.FindItems = funcFindItemsOverride


--------------------------------------------------------------
--                    Harass Behavior                       --
-- All code how to use abilities against enemies goes here  --
--------------------------------------------------------------
-- @param botBrain: CBotBrain
-- @return: none
--
local function HarassHeroExecuteOverride(botBrain)
    
    local unitTarget = behaviorLib.heroTarget
    if unitTarget == nil then
        return object.harassExecuteOld(botBrain) --Target is invalid, move on to the next behavior
    end
    
    
    local unitSelf = core.unitSelf
    local vecMyPosition = unitSelf:GetPosition() 
    local nAttackRange = core.GetAbsoluteAttackRangeToUnit(unitSelf, unitTarget)
    local nMyExtraRange = core.GetExtraRange(unitSelf)
    
    local vecTargetPosition = unitTarget:GetPosition()
    local nTargetExtraRange = core.GetExtraRange(unitTarget)
    local nTargetDistanceSq = Vector3.Distance2DSq(vecMyPosition, vecTargetPosition)
    
    local nLastHarassUtility = behaviorLib.lastHarassUtil
    local bCanSee = core.CanSeeUnit(botBrain, unitTarget)    
    local bActionTaken = false
    
	if core.CanSeeUnit(botBrain, unitTarget) then
        local bTargetVuln = unitTarget:IsStunned() or unitTarget:IsImmobilized() or unitTarget:IsPerplexed()
	    core.FindItems()
		local itemNuke = core.itemNuke
		
	if not bActionTaken then 
            core.FindItems()
            local itemSheepstick = core.itemSheepstick
            if itemSheepstick then
                local nRange = itemSheepstick:GetRange()
                if itemSheepstick:CanActivate() and nLastHarassUtility > botBrain.nSheepThreshold then
                    if nTargetDistanceSq < (nRange * nRange) then
                        if bDebugEchos then BotEcho("Using sheepstick") end
                        bActionTaken = core.OrderItemEntityClamp(botBrain, unitSelf, itemSheepstick, unitTarget)
                    end
                end
            end
        end
    
    if not bActionTaken then
        local abilSlow = skills.abilW
		local abilW = skills.abilW
        if skills.abilW:CanActivate() and nLastHarassUtility > botBrain.abilWThreshold then
		
            local nRange = abilSlow:GetRange()
            if nTargetDistanceSq < (nRange * nRange) then
                bActionTaken = core.OrderAbilityEntity(botBrain, skills.abilW, unitTarget)
            
            end
        end
    end	
    
    if not bActionTaken then
        local abilStun = skills.abilQ
		local abilQ = skills.abilQ
        if skills.abilQ:CanActivate() and nLastHarassUtility > botBrain.abilQThreshold then
		
            local nRange = abilStun:GetRange()
            if nTargetDistanceSq < (nRange * nRange) then
                bActionTaken = core.OrderAbilityEntity(botBrain, skills.abilQ, unitTarget)
            
            end
        end
    end	
	
	if not bActionTaken then
	   if itemNuke then
				local nNukeRange = itemNuke:GetRange()
                if itemNuke:CanActivate() and nLastHarassUtility > botBrain.nNukeThreshold then--and unitSelf:GetMana()>315 and nLastHarassUtility > botBrain.nPortalkeyThreshold then
					--BotEcho(" " .. nTargetDistanceSq .. " " .. (nRange*nRange));
                    if nTargetDistanceSq <= (nNukeRange*nNukeRange) then
						bActionTaken = core.OrderItemEntityClamp(botBrain, unitSelf, itemNuke, unitTarget) --teleport on that mofo
						
					
						bActionTaken = core.OrderAttackClamp(botBrain, unitSelf, unitTarget, false, true)
						
					elseif nTargetDistanceSq>(nNukeRange*nNukeRange) then
						bActionTaken = core.OrderMoveToUnitClamp(botBrain, unitSelf, unitTarget)
					end
				end
            end
	end
    
    
        return object.harassExecuteOld(botBrain)
    end 
end
-- overload the behaviour stock function with custom 
object.harassExecuteOld = behaviorLib.HarassHeroBehavior["Execute"]
behaviorLib.HarassHeroBehavior["Execute"] = HarassHeroExecuteOverride


----------------------------------
--	Behemoth's Help behavior
--	
--	Utility: 
--	Execute: Use Ring of Sorcery (edited Astrolabe code)
----------------------------------

behaviorLib.nReplenishUtilityMul = 1.3
behaviorLib.nReplenishManaUtilityMul = 1.0
behaviorLib.nReplenishTimeToLiveUtilityMul = 0.5

function behaviorLib.ReplenishManaUtilityFn(unitHero)
	local nUtility = 0
	
	local nYIntercept = 100
	local nXIntercept = 100
	local nOrder = 2

	nUtility = core.ExpDecay(unitHero:GetManaPercent() * 100, nYIntercept, nXIntercept, nOrder)
	
	return nUtility
end

function behaviorLib.TimeToLiveUtilityFn(unitHero)
	--Increases as your time to live based on your damage velocity decreases
	local nUtility = 0
	
	local nManaVelocity = unitHero:GetManaRegen()	-- Get mana regen
	local nMana = unitHero:GetMana()				-- Get mana
	local nTimeToLive = 9999
	if nManaVelocity < 0 then
		nTimeToLive = nMana / (-1 * nManaVelocity)
		
		local nYIntercept = 100
		local nXIntercept = 20
		local nOrder = 2
		nUtility = core.ExpDecay(nTimeToLive, nYIntercept, nXIntercept, nOrder)
	end
	
	nUtility = Clamp(nUtility, 0, 100)
	
	--BotEcho(format("%d timeToLive: %g  healthVelocity: %g", HoN.GetGameTime(), nTimeToLive, nManaVelocity))
	
	return nUtility, nTimeToLive
end

behaviorLib.nReplenishCostBonus = 10
behaviorLib.nReplenishCostBonusCooldownThresholdMul = 4.0
function behaviorLib.AbilityCostBonusFn(unitSelf, ability)
	local bDebugEchos = false
	
	local nCost =		ability:GetManaCost()		-- Get item mana cost
	local nCooldownMS =	ability:GetCooldownTime()	-- Get item cooldown
	local nRegen =		unitSelf:GetManaRegen()		-- Get bot's mana regeneration
	
	local nTimeToRegenMS = nCost / nRegen * 1000
	
	if bDebugEchos then BotEcho(format("AbilityCostBonusFn - nCost: %d  nCooldown: %d  nRegen: %g  nTimeToRegen: %d", nCost, nCooldownMS, nRegen, nTimeToRegenMS)) end
	if nTimeToRegenMS < nCooldownMS * behaviorLib.nReplenishCostBonusCooldownThresholdMul then
		return behaviorLib.nReplenishCostBonus
	end
	
	return 0
end

behaviorLib.unitReplenishTarget = nil
behaviorLib.nReplenishTimeToLive = nil
function behaviorLib.ReplenishUtility(botBrain)
	local bDebugEchos = false
	
	if bDebugEchos then BotEcho("ReplenishUtility") end
	
	local nUtility = 0

	local unitSelf = core.unitSelf
	behaviorLib.unitReplenishTarget = nil
	
	core.FindItems()
	local itemRoS = core.itemReplenish
	
	local nHighestUtility = 0
	local unitTarget = nil
	local nTargetTimeToLive = nil
	local sAbilName = ""
	if itemRoS and itemRoS:CanActivate() then
		local tTargets = core.CopyTable(core.localUnits["AllyHeroes"]) 	-- Get allies close to the bot
		tTargets[unitSelf:GetUniqueID()] = unitSelf 					-- Identify bot as a target too
		for key, hero in pairs(tTargets) do
			--Don't mana ourself if we are going to head back to the well anyway, 
			--	as it could cause us to retrace half a walkback
			if hero:GetUniqueID() ~= unitSelf:GetUniqueID() or core.GetCurrentBehaviorName(botBrain) ~= "HealAtWell" then
				local nCurrentUtility = 0
				
				local nManaUtility = behaviorLib.ReplenishManaUtilityFn(hero) * behaviorLib.nReplenishManaUtilityMul
				local nTimeToLiveUtility = nil
				local nCurrentTimeToLive = nil
				nTimeToLiveUtility, nCurrentTimeToLive = behaviorLib.TimeToLiveUtilityFn(hero)
				nTimeToLiveUtility = nTimeToLiveUtility * behaviorLib.nReplenishTimeToLiveUtilityMul
				nCurrentUtility = nManaUtility + nTimeToLiveUtility
				
				if nCurrentUtility > nHighestUtility then
					nHighestUtility = nCurrentUtility
					nTargetTimeToLive = nCurrentTimeToLive
					unitTarget = hero
					if bDebugEchos then BotEcho(format("%s Replenish util: %d  health: %d  ttl:%d", hero:GetTypeName(), nCurrentUtility, nReplenishUtility, nTimeToLiveUtility)) end
				end
			end
		end

		if unitTarget then
			nUtility = nHighestUtility				
			sAbilName = "Replenish"
		
			behaviorLib.unitReplenishTarget = unitTarget
			behaviorLib.nReplenishTimeToLive = nTargetTimeToLive
		end		
	end
	
	if bDebugEchos then BotEcho(format("    abil: %s util: %d", sAbilName, nUtility)) end
	
	nUtility = nUtility * behaviorLib.nReplenishUtilityMul
	
	if botBrain.bDebugUtility == true and nUtility ~= 0 then
		BotEcho(format("  HelpUtility: %g", nUtility))
	end
	
	return nUtility
end

-- Executing the behavior to use the Ring of Sorcery
function behaviorLib.ReplenishExecute(botBrain)
	core.FindItems()
	local itemRoS = core.itemReplenish
	
	local unitReplenishTarget = behaviorLib.unitReplenishTarget
	local nReplenishTimeToLive = behaviorLib.nReplenishTimeToLive
	
	if unitReplenishTarget and itemRoS and itemRoS:CanActivate() then 
		local unitSelf = core.unitSelf													-- Get bot's position
		local vecTargetPosition = unitReplenishTarget:GetPosition()						-- Get target's position
		local nDistance = Vector3.Distance2D(unitSelf:GetPosition(), vecTargetPosition)	-- Get distance between bot and target
		if nDistance < 500 then
			core.OrderItemClamp(botBrain, unitSelf, itemRoS) -- Use Ring of Sorcery, if in range
		else
			core.OrderMoveToUnitClamp(botBrain, unitSelf, unitReplenishTarget) -- Move closer to target
		end
	else
		return false
	end
	
	return true
end

behaviorLib.ReplenishBehavior = {}
behaviorLib.ReplenishBehavior["Utility"] = behaviorLib.ReplenishUtility
behaviorLib.ReplenishBehavior["Execute"] = behaviorLib.ReplenishExecute
behaviorLib.ReplenishBehavior["Name"] = "Replenish"
tinsert(behaviorLib.tBehaviors, behaviorLib.ReplenishBehavior)


function AttackCreepsExecuteCustom(botBrain)

local unitSelf = core.unitSelf
	local currentTarget = core.unitCreepTarget
	local bActionTaken = false

	if currentTarget and core.CanSeeUnit(botBrain, currentTarget) then		
		local vecTargetPos = currentTarget:GetPosition()
		local nDistSq = Vector3.Distance2DSq(unitSelf:GetPosition(), vecTargetPos)
		local nAttackRangeSq = core.GetAbsoluteAttackRangeToUnit(unitSelf, currentTarget, true)

		if currentTarget ~= nil then			
			
			core.FindItems(botBrain)
			local itemHatchet = core.itemHatchet
			if nDistSq < nAttackRangeSq and unitSelf:IsAttackReady() then
				--BotEcho("Attacking Creep")
				--only attack when in nRange, so not to aggro towers/creeps until necessary, and move forward when attack is on cd
				bActionTaken = core.OrderAttackClamp(botBrain, unitSelf, currentTarget)
			elseif (itemHatchet and itemHatchet:CanActivate()) then
				local nHatchRange = itemHatchet:GetRange()
				if nDistSq < ( nHatchRange * nHatchRange ) and currentTarget:GetTeam() ~= unitSelf:GetTeam() then					
					--BotEcho("Attempting Hatchet")
					bActionTaken = core.OrderItemEntityClamp(botBrain, unitSelf, itemHatchet, currentTarget)
				end			
			else
				--BotEcho("MOVIN OUT")
				local vecDesiredPos = core.AdjustMovementForTowerLogic(vecTargetPos)
				bActionTaken = core.OrderMoveToPosClamp(botBrain, unitSelf, vecDesiredPos, false)
			end
		end
	else
		return false
	end
	
	if not bActionTaken then
		return object.AttackCreepsExecuteOld(botBrain)
	end 
end

object.AttackCreepsExecuteOld = behaviorLib.AttackCreepsBehavior["Execute"]
behaviorLib.AttackCreepsBehavior["Execute"] = AttackCreepsExecuteCustom



