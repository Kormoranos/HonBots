--ArmadonBot v.0.3
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

object.bReportBehavior = true
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
object.heroName = 'Hero_Armadon'


--   item buy order. internal names  
behaviorLib.StartingItems  = {"Item_RunesOfTheBlight", "Item_IronBuckler", "Item_LoggersHatchet"}
behaviorLib.LaneItems  = {"Item_Marchers", "Item_Lifetube", "Item_MysticVestments"}
behaviorLib.MidItems  = {"Item_Shield2", "Item_MagicArmor2", "Item_PlatedGreaves", "Item_SolsBulwark"}
behaviorLib.LateItems  = {"Item_Damage10", "Item_DaemonicBreastplate"}


-- skillbuild table, 0=q, 1=w, 2=e, 3=r, 4=attri
object.tSkills = {
    1, 2, 1, 0, 1,
    3, 1, 2, 2, 2, 
    3, 0, 0, 0, 4,
    3, 4, 4, 4, 4,
    4, 4, 4, 4, 4,
}

-- bonus agression points if a skill/item is available for use
object.abilQUp = 15
object.abilWUp = 18


-- bonus agression points that are applied to the bot upon successfully using a skill/item
object.abilQUse = 10
object.abilWUse = 15


--thresholds of aggression the bot must reach to use these abilities
object.abilQThreshold = 15
object.abilWThreshold = 20





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
        if EventData.InflictorName == "Ability_Armadon1" then
            addBonus = addBonus + object.abilQUse
			object.abilQUseTime = EventData.TimeStamp
			BotEcho(object.abilQUseTime)
   elseif EventData.InflictorName == "Ability_Armadon2" then
            addBonus = addBonus + object.abilWUse
			object.abilWUseTime = EventData.TimeStamp
			BotEcho(object.abilWUseTime)
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

    return nUtility
end

local function CustomHarassUtilityFnOverride(hero)
	local nUtility = AbilitiesUpUtility(hero)	
	
	return Clamp(nUtility, 0, 100)
end

-- assisgn custom Harrass function to the behaviourLib object
behaviorLib.CustomHarassUtility = CustomHarassUtilityFnOverride   



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
    
    local bTargetVuln = unitTarget:IsStunned() or unitTarget:IsImmobilized() or unitTarget:IsPerplexed()
    
    
    if not bActionTaken then
		local abilSnot = skills.abilQ
		if abilSnot:CanActivate() and nLastHarassUtility > botBrain.abilQThreshold then
			local nRange = abilSnot:GetRange()
            if nTargetDistanceSq < (nRange * nRange) then
                bActionTaken = core.OrderAbilityEntity(botBrain, abilSnot, unitTarget)
            else
                bActionTaken = core.OrderMoveToUnitClamp(botBrain, unitSelf, unitTarget)
            end
		end
	end	
		
	if not bActionTaken then 
		local abilSpine = skills.abilW
            if abilSpine:CanActivate() and nLastHarassUtility > botBrain.abilWThreshold then
				local nRange = 650
                if nTargetDistanceSq < (nRange * nRange) then 
					bActionTaken = core.OrderAbility(botBrain, abilSpine)
                end
            end
        end 
		
        return object.harassExecuteOld(botBrain)
    end 
end
-- overload the behaviour stock function with custom 
object.harassExecuteOld = behaviorLib.HarassHeroBehavior["Execute"]
behaviorLib.HarassHeroBehavior["Execute"] = HarassHeroExecuteOverride


--Retreating tactics
object.nRetreatSpineThreshold = 10
--object.nRetreatSnotThreshold = 25
function funcRetreatFromThreatExecuteOverride(botBrain)
	local bDebugEchos = true
	local bActionTaken = false
	local unitSelf = core.unitSelf
	
	local vecMyPosition = unitSelf:GetPosition()
	local nlastRetreatUtil = behaviorLib.lastRetreatUtil
	local unitTarget = behaviorLib.heroTarget
	local tEnemies = core.localUnits["EnemyHeroes"]
	local nCount = 0
	
	if unitSelf:GetHealthPercent() < .5 then
	for id, unitEnemy in pairs(tEnemies) do
		if core.CanSeeUnit(botBrain, unitEnemy) then
			nCount = nCount + 1
		end
	end
	
		if nCount > 0 then
		local vecTargetPosition = unitTarget:GetPosition()
		local unitTarget = behaviorLib.heroTarget
			--When retreating, will Keg himself to push them back 
			--as well as create some distance between enemies
			if not bActionTaken then
				local abilSpine = skills.abilW
		
				if behaviorLib.lastRetreatUtil >= object.nRetreatSpineThreshold and abilSpine:CanActivate() then  
					if bDebugEchos then BotEcho("Backing...Using Spines") end
					bActionTaken = core.OrderAbility(botBrain, abilSpine)
				end
			end
		
		-- When retreating, will deploy a turret in front of him facing the opposite direction to slow enemies down.
		--	if not bActionTaken then
		--		local abilSnot = skills.abilQ
		--		if behaviorLib.lastRetreatUtil >= object.nRetreatSnotThreshold and abilSnot:CanActivate() then
		--			if bDebugEchos then BotEcho ("Backing...Using Slow") end
		--			bActionTaken = core.OrderAbilityEntity(botBrain, abilSnot, unitTarget)
		--		end
		--	end
			
		end
	end

	if not bActionTaken then
		return object.RetreatFromThreatExecuteOld(botBrain)
	end
end
object.RetreatFromThreatExecuteOld = behaviorLib.RetreatFromThreatExecute
behaviorLib.RetreatFromThreatBehavior["Execute"] = funcRetreatFromThreatExecuteOverride


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