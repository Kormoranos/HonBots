

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
object.heroName = 'Hero_PollywogPriest'


--   item buy order. internal names  
behaviorLib.StartingItems  = {"2 Item_RunesOfTheBlight", "Item_MinorTotem", "Item_MinorTotem", "Item_MarkOfTheNovice", "Item_MarkOfTheNovice"}
behaviorLib.LaneItems  = {"Item_Marchers", "Item_GraveLocket", "Item_Steamboots", "Item_MysticVestments"}
behaviorLib.MidItems  = {"Item_PortalKey", "Item_Silence"}
behaviorLib.LateItems  = {"Item_Protect", "Item_Morph"}


-- skillbuild table, 0=q, 1=w, 2=e, 3=r, 4=attri
object.tSkills = {
    0, 2, 0, 1, 0,
    3, 0, 1, 1, 1, 
    3, 2, 2, 2, 4,
    3, 4, 4, 4, 4,
    4, 4, 4, 4, 4,
}

-- bonus agression points if a skill/item is available for use
object.abilQUp = 10
object.abilWUp = 10
object.abilEUp = 8
object.abilRUp = 40
object.nPortalkeyUp = 20
object.nSilenceUp = 20
-- bonus agression points that are applied to the bot upon successfully using a skill/item
object.abilQUse = 10
object.abilWUse = 15
object.abilEUse = 15
object.abilRUse = 60
object.nPortalkeyUse = 50
object.nSilenceUse = 20
--thresholds of aggression the bot must reach to use these abilities
object.abilQThreshold = 35
object.abilWThreshold = 20
object.abilEThreshold = 20
object.abilRThreshold = 50
object.nPortalkeyThreshold = 25
object.nSilenceThreshold = 20


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
	
	local bDebugEchos = true
    local addBonus = 0

    if EventData.Type == "Ability" then
		if bDebugEchos then BotEcho(" ABILITY EVENT! InflictorName: "..EventData.InflictorName) end
        if EventData.InflictorName == "Ability_PollywogPriest1" then
            addBonus = addBonus + object.abilQUse
			object.abilQUseTime = EventData.TimeStamp
			BotEcho(object.abilQUseTime)
        elseif EventData.InflictorName == "Ability_PollywogPriest2" then
            addBonus = addBonus + object.abilWUse
			object.abilWUseTime = EventData.TimeStamp
			BotEcho(object.abilWUseTime)
		elseif EventData.InflictorName == "Ability_PollywogPriest3" then
            addBonus = addBonus + object.abilEUse
			object.abilWUseTime = EventData.TimeStamp
			BotEcho(object.abilEUseTime)
        elseif EventData.InflictorName == "Ability_PollywogPriest4" then
            addBonus = addBonus + object.abilRUse
			object.abilRUseTime = EventData.TimeStamp
			BotEcho(object.abilRUseTime)
        end
	elseif EventData.Type == "Item" then
        if core.itemPortalkey ~= nil and EventData.SourceUnit == core.unitSelf:GetUniqueID() and EventData.InflictorName == core.itemPortalkey:GetName() then
            nAddBonus = nAddBonus + self.nPortalkeyUse
	    end
		if core.itemSilence ~= nil and EventData.SourceUnit == core.unitSelf:GetUniqueID() and EventData.InflictorName == core.itemSilence:GetName() then
            nAddBonus = nAddBonus + self.nSilenceUse
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
local bDebugEchos = true    
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
 
    if skills.abilR:CanActivate() then
        nUtility = nUtility + object.abilRUp
    end
    
	if object.itemPortalkey and object.itemPortalkey:CanActivate() then
        nUtility = nUtility + object.nPortalkeyUp
    end
	
	if object.itemSilence and object.itemSilence:CanActivate() then
        nUtility = nUtility + object.nSilenceUp
    end
	
    return nUtility
	
	end

	


local function CustomHarassUtilityFnOverride(hero)

	local nUtility = AbilitiesUpUtility()	
	
	return Clamp(nUtility, 0, 100)
end
if bDebugEchos then BotEcho((nUtil)) end
-- assisgn custom Harrass function to the behaviourLib object
behaviorLib.CustomHarassUtility = CustomHarassUtilityFnOverride   


--Find Items 
local function funcFindItemsOverride(botBrain)
	local bUpdated = object.FindItemsOld(botBrain)

	if core.itemPortalKey ~= nil and not core.itemPortalKey:IsValid() then
		core.itemPortalKey = nil
	end
	
	if core.itemSilence ~= nil and not core.itemSilence:IsValid() then
		core.itemSilence = nil
	end

    if bUpdated then
    	if core.itemPortalKey and core.itemSilence then
			return
		end

		local inventory = core.unitSelf:GetInventory(true)
		for slot = 1, 12, 1 do
			local curItem = inventory[slot]
			if curItem then
				if core.itemPortalKey == nil and curItem:GetName() == "Item_PortalKey" then
					core.itemPortalKey = core.WrapInTable(curItem)
				elseif core.itemSilence == nil and curItem:GetName() == "Item_Silence" then
                    core.itemSilence = core.WrapInTable(curItem)
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
    
	if core.unitSelf:IsChanneling() then
		return
    end
	
	if core.CanSeeUnit(botBrain, unitTarget) then
        local bTargetVuln = unitTarget:IsStunned() or unitTarget:IsImmobilized() or unitTarget:IsPerplexed()
	    core.FindItems()
		local itemPortalKey = core.itemPortalKey
		
	if not bActionTaken then
	   if itemPortalKey then
	            local abilWards = skills.abilR
				local nPortalKeyRange = itemPortalKey:GetRange()
                if itemPortalKey:CanActivate() and abilWards:CanActivate() and nLastHarassUtility > botBrain.nPortalkeyThreshold then--and unitSelf:GetMana()>315 and nLastHarassUtility > botBrain.nPortalkeyThreshold then
					--BotEcho(" " .. nTargetDistanceSq .. " " .. (nRange*nRange));
                    if nTargetDistanceSq <= (nPortalKeyRange*nPortalKeyRange) and nTargetDistanceSq>(750*750) then
						bActionTaken = core.OrderItemPosition(botBrain, unitSelf, itemPortalKey, vecTargetPosition) --teleport on that mofo
						
					
						bActionTaken = core.OrderAttackClamp(botBrain, unitSelf, unitTarget, false, true)
						
					elseif nTargetDistanceSq>(nPortalKeyRange*nPortalKeyRange) then
						bActionTaken = core.OrderMoveToUnitClamp(botBrain, unitSelf, unitTarget)
					end
				end
            end
	end
	  
	if not bActionTaken then 
			core.FindItems()
			local itemSilence = core.itemSilence
			if itemSilence then
				local nRange = itemSilence:GetRange()
				if itemSilence:CanActivate() and nLastHarassUtility > botBrain.nSilenceThreshold then
					if nTargetDistanceSq < (nRange * nRange) then
						bActionTaken = core.OrderItemEntityClamp(botBrain, unitSelf, itemSilence, unitTarget)
					end
				end
			end
		end
		
	if not bActionTaken then
        local abilMorph = skills.abilW
		local abilW = skills.abilW
        if skills.abilW:CanActivate() and nLastHarassUtility > botBrain.abilWThreshold then
		
            local nRange = abilMorph:GetRange()
            if nTargetDistanceSq < (nRange * nRange) then
                bActionTaken = core.OrderAbilityEntity(botBrain, skills.abilW, unitTarget)
            
            end
        end
    end	
	
	if not bActionTaken then
        local abilJolt = skills.abilQ
        if abilJolt:CanActivate() and nLastHarassUtility > botBrain.abilQThreshold then
            local nRange = abilJolt:GetRange()
            if nTargetDistanceSq < (nRange * nRange) then
                bActionTaken = core.OrderAbilityEntity(botBrain, abilJolt, unitTarget)
            else
                bActionTaken = core.OrderMoveToUnitClamp(botBrain, unitSelf, unitTarget)
            end
        end
    end	
	
	

	    if not bActionTaken then
        local abilWards = skills.abilR
        if abilWards:CanActivate() and nLastHarassUtility > botBrain.abilRThreshold then
            local nRange = abilWards:GetRange()
            if nTargetDistanceSq < (nRange * nRange) then
                bActionTaken = core.OrderAbilityPosition(botBrain, abilWards, vecTargetPosition)
            
            end
        end
    end		
 
   if not bActionTaken then
        local abilTongue = skills.abilE
        if abilTongue:CanActivate() and nLastHarassUtility > botBrain.abilEThreshold then
            local nRange = abilTongue:GetRange()
            if nTargetDistanceSq < (nRange * nRange) then
                bActionTaken = core.OrderAbilityEntity(botBrain, abilTongue, unitTarget)
            
              
            end
        end
    end	 
    

 
    if not bActionTaken then
        return object.harassExecuteOld(botBrain)
    end 
end
end
-- overload the behaviour stock function with custom 
object.harassExecuteOld = behaviorLib.HarassHeroBehavior["Execute"]
behaviorLib.HarassHeroBehavior["Execute"] = HarassHeroExecuteOverride


----------------------------------
-- Retreating tactics as seen in Spennerino's ScoutBot 
-- with variations from Rheged's Emerald Warden Bot
----------------------------------
object.nRetreatTarThreshold = 15
object.nRetreatBufferThreshold = 15


function funcRetreatFromThreatExecuteOverride(botBrain)
	local actionTaken = false
	local self = core.unitSelf
	local target = behaviorLib.heroTarget
	if target == nil then
		return false
	end
	local targetPosition = target:GetPosition()
	local selfPosition = self:GetPosition()
	local distance = Vector3.Distance2DSq(selfPosition, targetPosition)
	local canSee = core.CanSeeUnit(botBrain, target)
	
if self:GetHealthPercent() < .5 then	
if not actionTaken and canSee then
local vecMyPosition = self:GetPosition()
	local vecTargetPosition = target:GetPosition()
	
		
		-- When retreating, will deploy a turret in front of him facing the opposite direction to slow enemies down.
			if not bActionTaken then
				local abilBuffer = skills.abilW
				if behaviorLib.lastRetreatUtil >= 15 and abilBuffer:CanActivate() then
					if bDebugEchos then BotEcho ("Backing...Depolying Turret") end
					bActionTaken = core.OrderAbilityEntity(botBrain, abilBuffer, target)
				end
			end
			
			if not bActionTaken then
			local itemPortalKey = core.itemPortalKey
			local vecPos = behaviorLib.PositionSelfBackUp()
				if itemPortalKey and nlastRetreatUtil >= 15 then
					if itemPortalKey:CanActivate()  then
						core.OrderItemPosition(botBrain, unitSelf, itemPortalKey, vecPos)
						return
					end
				end
			end
		end
	end
	if unitTarget == nil then
     	return object.RetreatFromThreatExecuteOld(botBrain)
		end
	if not bActionTaken then
		return object.RetreatFromThreatExecuteOld(botBrain)
	end
end
object.RetreatFromThreatExecuteOld = behaviorLib.RetreatFromThreatExecute
behaviorLib.RetreatFromThreatBehavior["Execute"] = funcRetreatFromThreatExecuteOverride



local function HitBuildingExecuteOverride(botBrain)
	--BotEcho('Derp')
	local bDebugLines = false
	local lineLen = 150
	
	local bActionTaken = false
	
	local abilWards = skills.abilR
	local nWardsLevel = abilWards:GetLevel()
	
	local nWardsBuildingDamage = 25
	if nWardsLevel == 2 then
		nFlareBuildingDamage = 50
	elseif nFlareLevel == 3 then
		nWardsBuildingDamage = 75
	elseif nFlareLevel == 4 then
		nWardsBuildingDamage = 100
	end
	
	local bShouldWards = false	
	local unitTarget = nil
	
	if abilWards:CanActivate() then
		local tEnemyBuildings = core.localUnits.EnemyBuildings
		for key, building in pairs(tEnemyBuildings) do
			if botBrain:CanSeeUnit(building) then
				if not building:IsInvulnerable() and building:GetHealth() < 700 and building:GetHealth() > 100 then
					unitTarget = building
					bShouldWards = true
					break
				end
			end
		end
	end
	
	if bShouldWards then
		local unitSelf = core.unitSelf
		local nWardsWardsRange = abilWards:GetRange() + core.GetExtraRange(unitSelf) + core.GetExtraRange(unitTarget)
		
		local vecTargetPosition = unitTarget:GetPosition()
		local vecMyPosition = unitSelf:GetPosition()
		
		if Vector3.Distance2DSq(vecTargetPosition, vecMyPosition) > (500 * 500) then
			--BotEcho("Move in to flare!")
			core.OrderMoveToPosClamp(botBrain, unitSelf, vecTargetPosition, false)
			bActionTaken = true
		else
			--BotEcho("Flarin!")
			bActionTaken = core.OrderAbilityPosition(botBrain, abilWards, vecTargetPosition)
		end		
	end
	
	if not bActionTaken then
		object.HitBuildingExecuteOld(botBrain)
	end
end
object.HitBuildingExecuteOld = behaviorLib.HitBuildingBehavior["Execute"]
behaviorLib.HitBuildingBehavior["Execute"] = HitBuildingExecuteOverride



function behaviorLib.GetCreepAttackTarget(botBrain, unitEnemyCreep, unitAllyCreep) --called pretty much constantly
    local unitSelf = core.unitSelf
    if botBrain:GetGold() > 3000 then
        local wellPos = core.allyWell and core.allyWell:GetPosition() or behaviorLib.PositionSelfBackUp()
        core.OrderMoveToPosAndHoldClamp(botBrain, unitSelf, wellPos, false)
    end

    core.nHarassBonus = 0

    local bDebugEchos = false
    -- no predictive last hitting, just wait and react when they have 1 hit left
    -- prefers LH over deny

    local unitSelf = core.unitSelf
    local nDamageMin = unitSelf:GetFinalAttackDamageMin()
    
    core.FindItems(botBrain)

    local nProjectileSpeed = unitSelf:GetAttackProjectileSpeed()

    if unitEnemyCreep and core.CanSeeUnit(botBrain, unitEnemyCreep) then
        local nTargetHealth = unitEnemyCreep:GetHealth()
        local tNearbyAllyCreeps = core.localUnits['AllyCreeps']
        local tNearbyAllyTowers = core.localUnits['AllyTowers']
        local nExpectedCreepDamage = 0
        local nExpectedTowerDamage = 0

        local vecTargetPos = unitEnemyCreep:GetPosition()
        local nProjectileTravelTime = Vector3.Distance2D(unitSelf:GetPosition(), vecTargetPos) / nProjectileSpeed
        if bDebugEchos then BotEcho ("Projectile travel time: " .. nProjectileTravelTime ) end 
        
        --Determine the damage expcted on the creep by other creeps
        for i, unitCreep in pairs(tNearbyAllyCreeps) do
            if unitCreep:GetAttackTarget() == unitEnemyCreep then
                --if unitCreep:IsAttackReady() then
                    local nCreepAttacks = 1 + math.floor(unitCreep:GetAttackSpeed() * nProjectileTravelTime)
                    nExpectedCreepDamage = nExpectedCreepDamage + unitCreep:GetFinalAttackDamageMin() * nCreepAttacks
                --end
            end
        end

        for i, unitTower in pairs(tNearbyAllyTowers) do
            if unitTower:GetAttackTarget() == unitEnemyCreep then
                --if unitTower:IsAttackReady() then

                    local nTowerAttacks = 1 + math.floor(unitTower:GetAttackSpeed() * nProjectileTravelTime)
                    nExpectedTowerDamage = nExpectedTowerDamage + unitTower:GetFinalAttackDamageMin() * nTowerAttacks
                --end
            end
        end
        
        if bDebugEchos then BotEcho ("Excpecting ally creeps to damage enemy creep for " .. nExpectedCreepDamage .. " - using this to anticipate lasthit time") end
        
        if nDamageMin >= (nTargetHealth - nExpectedCreepDamage - nExpectedTowerDamage) then
            local bActuallyLH = true
            
            -- [Tutorial] Make DS not mess with your last hitting before shit gets real
            if core.bIsTutorial and core.bTutorialBehaviorReset == false and core.unitSelf:GetTypeName() == "Hero_Shaman" then
                bActuallyLH = false
            end
            
            if bActuallyLH then
                if bDebugEchos then BotEcho("Returning an enemy") end
                return unitEnemyCreep
            end
        end
    end
	
	if unitAllyCreep then
        local nTargetHealth = unitAllyCreep:GetHealth()
        local tNearbyEnemyCreeps = core.localUnits['EnemyCreeps']
        local tNearbyEnemyTowers = core.localUnits['EnemyTowers']
        local nExpectedCreepDamage = 0
        local nExpectedTowerDamage = 0

        local vecTargetPos = unitAllyCreep:GetPosition()
        local nProjectileTravelTime = Vector3.Distance2D(unitSelf:GetPosition(), vecTargetPos) / nProjectileSpeed
        if bDebugEchos then BotEcho ("Projectile travel time: " .. nProjectileTravelTime ) end 
        
        --Determine the damage expcted on the creep by other creeps
        for i, unitCreep in pairs(tNearbyEnemyCreeps) do
            if unitCreep:GetAttackTarget() == unitAllyCreep then
                --if unitCreep:IsAttackReady() then
                    local nCreepAttacks = 1 + math.floor(unitCreep:GetAttackSpeed() * nProjectileTravelTime)
                    nExpectedCreepDamage = nExpectedCreepDamage + unitCreep:GetFinalAttackDamageMin() * nCreepAttacks
                --end
            end
        end
		
		for i, unitTower in pairs(tNearbyEnemyTowers) do
            if unitTower:GetAttackTarget() == unitAllyCreep then 
                --if unitTower:IsAttackReady() then

                    local nTowerAttacks = 1 + math.floor(unitTower:GetAttackSpeed() * nProjectileTravelTime)
                    nExpectedTowerDamage = nExpectedTowerDamage + unitTower:GetFinalAttackDamageMin() * nTowerAttacks
                --end
            end
        end
        
        if nDamageMin >= (nTargetHealth - nExpectedCreepDamage - nExpectedTowerDamage) then
            local bActuallyDeny = true
            
            --[Difficulty: Easy] Don't deny
            if core.nDifficulty == core.nEASY_DIFFICULTY then
                bActuallyDeny = false
            end         
            
            -- [Tutorial] Hellbourne *will* deny creeps after shit gets real
            if core.bIsTutorial and core.bTutorialBehaviorReset == true and core.myTeam == HoN.GetHellbourneTeam() then
                bActuallyDeny = true
            end
            
            if bActuallyDeny then
                if bDebugEchos then BotEcho("Returning an ally") end
                return unitAllyCreep
            end
        end
    end

    return nil
end

function AttackCreepsExecuteOverride(botBrain)
    local unitSelf = core.unitSelf
    local unitCreepTarget = core.unitCreepTarget

    if unitCreepTarget and core.CanSeeUnit(botBrain, unitCreepTarget) then      
        local vecTargetPos = unitCreepTarget:GetPosition()
        local nDistSq = Vector3.Distance2DSq(unitSelf:GetPosition(), vecTargetPos)
        local nAttackRangeSq = core.GetAbsoluteAttackRangeToUnit(unitSelf, currentTarget, true)
        
        local nDamageMin = unitSelf:GetFinalAttackDamageMin()

        if unitCreepTarget ~= nil then
            local nProjectileSpeed = unitSelf:GetAttackProjectileSpeed()            
            local nTargetHealth = unitCreepTarget:GetHealth()

            local vecTargetPos = unitCreepTarget:GetPosition()
            local nProjectileTravelTime = Vector3.Distance2D(unitSelf:GetPosition(), vecTargetPos) / nProjectileSpeed
            if bDebugEchos then BotEcho ("Projectile travel time: " .. nProjectileTravelTime ) end 
            
            local nExpectedCreepDamage = 0
            local nExpectedTowerDamage = 0
            local tNearbyAttackingCreeps = nil
            local tNearbyAttackingTowers = nil

            if unitCreepTarget:GetTeam() == unitSelf:GetTeam() then
                tNearbyAttackingCreeps = core.localUnits['EnemyCreeps']
                tNearbyAttackingTowers = core.localUnits['EnemyTowers']
            else
                tNearbyAttackingCreeps = core.localUnits['AllyCreeps']
                tNearbyAttackingTowers = core.localUnits['AllyTowers']
            end
        
            --Determine the damage expcted on the creep by other creeps
            for i, unitCreep in pairs(tNearbyAttackingCreeps) do
                if unitCreep:GetAttackTarget() == unitCreepTarget then
                    --if unitCreep:IsAttackReady() then
                        local nCreepAttacks = 1 + math.floor(unitCreep:GetAttackSpeed() * nProjectileTravelTime)
                        nExpectedCreepDamage = nExpectedCreepDamage + unitCreep:GetFinalAttackDamageMin() * nCreepAttacks
                    --end
                end
            end
        
            --Determine the damage expcted on the creep by other creeps
            for i, unitTower in pairs(tNearbyAttackingTowers) do
                if unitTower:GetAttackTarget() == unitCreepTarget then
                    --if unitTower:IsAttackReady() then
                        local nTowerAttacks = 1 + math.floor(unitTower:GetAttackSpeed() * nProjectileTravelTime)
                        nExpectedTowerDamage = nExpectedTowerDamage + unitTower:GetFinalAttackDamageMin() * nTowerAttacks
                    --end
                end
            end

            if nDistSq < nAttackRangeSq and unitSelf:IsAttackReady() and nDamageMin>=(unitCreepTarget:GetHealth() - nExpectedCreepDamage - nExpectedTowerDamage) then --only kill if you can get gold
                --only attack when in nRange, so not to aggro towers/creeps until necessary, and move forward when attack is on cd
                core.OrderAttackClamp(botBrain, unitSelf, unitCreepTarget)
            elseif (nDistSq > nAttackRangeSq * 0.6) then 
                --SR is a ranged hero - get somewhat closer to creep to slow down projectile travel time
                --BotEcho("MOVIN OUT")
                local vecDesiredPos = core.AdjustMovementForTowerLogic(vecTargetPos)
                core.OrderMoveToPosClamp(botBrain, unitSelf, vecDesiredPos, false)
            else
                core.OrderHoldClamp(botBrain, unitSelf, false)
            end
        end
    else
        return false
    end
end
object.AttackCreepsExecuteOld = behaviorLib.HarassHeroBehavior["Execute"]
behaviorLib.AttackCreepsBehavior["Execute"] = AttackCreepsExecuteOverride

-- Function for finding the center of a group
-- Credits to Stol3n_Id's RA Bot!
local function groupCenter(tGroup, nMinCount)
    if nMinCount == nil then nMinCount = 1 end
     
    if tGroup ~= nil then
        local vGroupCenter = Vector3.Create()
        local nGroupCount = 0 
        for id, creep in pairs(tGroup) do
            vGroupCenter = vGroupCenter + creep:GetPosition()
            nGroupCount = nGroupCount + 1
        end
         
        if nGroupCount < nMinCount then
            return nil
        else
            return vGroupCenter/nGroupCount-- center vector
        end
    else
        return nil   
    end
end

--------------------------------------------------------------
-- Function to determine utility of using Call in
-- farming situations.
--------------------------------------------------------------
function behaviorLib.CallUtility(botBrain)
	local unitSelf = core.unitSelf
	local nUtility = 0
	local nHowToFarmACreep = 40
	local abilJolt = skills.abilQ
	local nJoltRange = 500
	nJoltRange = nJoltRange * nJoltRange
	local nCandPos = 0
	local nRangeCheck = 0
	local nNumCand = 0
	local bDC = false
	local vCreepCenter = groupCenter(core.localUnits["EnemyCreeps"], 3)
	function DangerClose(vecHero, tEnemyHeroes, nType)
	local nDangerCloseDef = 650
	nDangerCloseDef = nDangerCloseDef * nDangerCloseDef
	local nDangerCloseOff = 900
	nDangerCloseOff = nDangerCloseOff * nDangerCloseOff
	local nEnemyNum1 = 0
	local nEnemyNum2 = 0
	local nDangerDist = 0

	for index, danger in pairs(tEnemyHeroes) do
		local dangerpos = danger:GetPosition()
		if dangerpos then
			nDangerDist = Vector3.Distance2DSq(vecHero, dangerpos)
		end
		if danger and nDangerDist <= nDangerCloseDef and nType == 1 then
			return true
		elseif danger and nDangerDist <= nDangerCloseOff and nType == 0 then
			nEnemyNum1 = nEnemyNum1 + 1
			if nEnemyNum1 >= 3 then
				return true
			end
		elseif danger and nDangerDist <= nDangerCloseOff and nType == 2 then
			nEnemyNum2 = nEnemyNum2 + 1
			if nEnemyNum2 >= 2 then
				return true
			end
		end
	end
	
	return false
end


	if abilJolt:CanActivate() then
		local tCreepin = core.CopyTable(core.localUnits["EnemyCreeps"])
		local tCloseHeroes = HoN.GetHeroes(core.enemyTeam)
		bDC = DangerClose(unitSelf:GetPosition(), tCloseHeroes, 2)
		local nManaCheck = unitSelf:GetManaPercent()
		if not bDC then
			for index, candidate in pairs(tCreepin) do
				if candidate then
					nCandPos = candidate:GetPosition()
					if nCandPos then
						nRangeCheck = Vector3.Distance2DSq(unitSelf:GetPosition(), nCandPos)
					end
				end
				if nRangeCheck and nRangeCheck <= nJoltRange then
					nNumCand = nNumCand + 1
				end
				if nNumCand >= 3 and nManaCheck > 0.6 then
					nUtility = nHowToFarmACreep
					return nUtility
				end
			end
		end
	end

	nUtility = 1
	
	return nUtility
end

function behaviorLib.CallExecute(botBrain)
	local abilJolt = skills.abilQ
	local vCreepCenter = groupCenter(core.localUnits["EnemyCreeps"], 3)
	local lowestEnemyHP = 9999
	local lowestEnemyCreep = nil
	local enemyCreeps = core.localUnits["EnemyCreeps"]
	local allyCreeps = 	core.localUnits["AllyCreeps"]
	local unitSelf = core.unitSelf
	local myPos = unitSelf:GetPosition()
    local unitCreepTarget = core.unitCreepTarget
	local curHP = 0
	for id, creep in pairs(enemyCreeps) do
		curHP = creep:GetHealth()
		--BotEcho('creepHealth '..curHP)
		if curHP < lowestEnemyHP then
			lowestEnemyHP = curHP
			lowestEnemyCreep = creep
		end
	end
	if abilJolt:CanActivate() and abilJolt:GetLevel()>2 then
		bActionTaken = core.OrderAbilityEntity(botBrain, abilJolt, unitCreepTarget)
	end
end

behaviorLib.CallBehavior = {}
behaviorLib.CallBehavior["Utility"] = behaviorLib.CallUtility
behaviorLib.CallBehavior["Execute"] = behaviorLib.CallExecute
behaviorLib.CallBehavior["Name"] = "Call"
tinsert(behaviorLib.tBehaviors, behaviorLib.CallBehavior)


