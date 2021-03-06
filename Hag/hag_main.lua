--Batman Bot v.0.1
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


-- hero_<hero>  to reference the internal hon name of a hero, Hero_Yogi ==wildsoul
object.heroName = 'Hero_BabaYaga'


--   item buy order. internal names  
behaviorLib.StartingItems  = {"2 Item_RunesOfTheBlight", "Item_MinorTotem", "Item_MinorTotem", "Item_MarkOfTheNovice", "Item_MarkOfTheNovice"}
behaviorLib.LaneItems  = {"Item_Marchers", "Item_GraveLocket", "Item_Steamboots"}
behaviorLib.MidItems  = {"Item_Silence"}
behaviorLib.LateItems  = {"Item_Protect", "Item_Weapon3"}


-- skillbuild table, 0=q, 1=w, 2=e, 3=r, 4=attri
object.tSkills = {
    1, 0, 0, 2, 2,
    3, 2, 2, 1, 1, 
    3, 1, 0, 0, 4,
    3, 4, 4, 4, 4,
    4, 4, 4, 4, 4,
}

-- bonus agression points if a skill/item is available for use
object.abilQUp = 10
object.abilWUp = 10
object.abilEUp = 10
object.abilRUp = 30
object.nImmunityUp = 18
object.nIllusionUp = 20
object.nEnergizerUp = 10
object.nSilenceUp = 20
-- bonus agression points that are applied to the bot upon successfully using a skill/item
object.abilQUse = 5
object.abilWUse = 8
object.abilEUse = 10
object.abilRUse = 30
object.nImmunityUse = 18
object.nIllusionUse = 20
object.nEnergizerUse = 10
object.nSilenceUse = 20
--thresholds of aggression the bot must reach to use these abilities
object.abilQThreshold = 10
object.abilWThreshold = 10
object.abilEThreshold = 16
object.abilRThreshold = 60
object.nImmunityThreshold = 20
object.nIllusionThreshold = 30
object.nEnergizerThreshold = 10
object.nSilenceThreshold = 20

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
        if EventData.InflictorName == "Ability_BabaYaga1" then
            addBonus = addBonus + object.abilQUse
			object.abilQUseTime = EventData.TimeStamp
			BotEcho(object.abilQUseTime)
   elseif EventData.InflictorName == "Ability_BabaYaga2" then
            addBonus = addBonus + object.abilWUse
			object.abilWUseTime = EventData.TimeStamp
			BotEcho(object.abilWUseTime)
	elseif EventData.InflictorName == "Ability_BabaYaga3" then
            addBonus = addBonus + object.abilEUse
			object.abilWUseTime = EventData.TimeStamp
			BotEcho(object.abilWUseTime)		
	elseif EventData.InflictorName == "Ability_BabaYaga4" then
            addBonus = addBonus + object.abilRUse
			object.abilWUseTime = EventData.TimeStamp
			BotEcho(object.abilWUseTime)		
     end
	 elseif EventData.Type == "Item" then
			if core.itemImmunity ~= nil and EventData.SourceUnit == core.unitSelf:GetUniqueID() and EventData.InflictorName == core.itemImmunity:GetName() then
            nAddBonus = nAddBonus + self.nImmunityUse
			end
			if core.itemIllusion ~= nil and EventData.SourceUnit == core.unitSelf:GetUniqueID() and EventData.InflictorName == core.itemIllusion:GetName() then
			addBonus = addBonus + self.nIllusion
			end
			if core.itemSilence ~= nil and EventData.SourceUnit == core.unitSelf:GetUniqueID() and EventData.InflictorName == core.itemSilence:GetName() then
			addBonus = addBonus + self.nSilence
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
	
	if skills.abilR:CanActivate() then
        nUtility = nUtility + object.abilRUp
    end
	
	if object.itemSilence and object.itemSilence:CanActivate() then
        nUtility = nUtility + object.nPortalkeyUp
    end
	
	if object.itemEnergizer and object.itemEnergizer:CanActivate() then
        nUtility = nUtility + object.nEnergizerUp
    end

    return nUtility
end

local function CustomHarassUtilityFnOverride(hero)
	local nUtility = AbilitiesUpUtility(hero)	
	
	return Clamp(nUtility, 0, 100)
end

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
    
    if core.CanSeeUnit(botBrain, unitTarget) then
    local bTargetVuln = unitTarget:IsStunned() or unitTarget:IsImmobilized() or unitTarget:IsPerplexed()
    
	if not bActionTaken then 
		local abilFlash = skills.abilW
		local abilScream = skills.abilE
            if abilFlash:CanActivate() and (abilScream:CanActivate() or unitTarget:GetHealthPercent() < .2) and nLastHarassUtility > botBrain.abilWThreshold then
				local nRange = abilFlash:GetRange()
                if nTargetDistanceSq < (nRange * nRange)+100 and nTargetDistanceSq > (300 * 300) then 
					bActionTaken = core.OrderAbilityPosition(botBrain, abilFlash, vecTargetPosition)
                end
            end
        end 
	
	if not bActionTaken then 
			core.FindItems()
			local itemSilence = core.itemSilence
			if itemSilence then
				local nRange = itemSilence:GetRange()
				if itemSilence:CanActivate() and nLastHarassUtility > botBrain.nSilenceThreshold and not unitTarget:IsSilenced() then
					if nTargetDistanceSq < (nRange * nRange) then
						bActionTaken = core.OrderItemEntityClamp(botBrain, unitSelf, itemSilence, unitTarget)
					end
				end
			end
		end
	
    if not bActionTaken then
		local abilHaunt = skills.abilQ
		if abilHaunt:CanActivate() and nLastHarassUtility > botBrain.abilQThreshold and abilHaunt:GetLevel()>1 then
			local nRange = abilHaunt:GetRange()
            if nTargetDistanceSq < (nRange * nRange) then
                bActionTaken = core.OrderAbilityEntity(botBrain, abilHaunt, unitTarget)
            
            end
		end
	end	
		
	if not bActionTaken then 
		local abilScream = skills.abilE
            if abilScream:CanActivate() and nLastHarassUtility > botBrain.abilEThreshold then
				local nRange = 420--abilScream:GetRange()
                if nTargetDistanceSq < (nRange * nRange) then 
					bActionTaken = core.OrderAbility(botBrain, abilScream)
                end
            end
        end 
		
	if not bActionTaken then 
		local abilBlast = skills.abilR
            if abilBlast:CanActivate() and nLastHarassUtility > botBrain.abilRThreshold then
				local nRange = abilBlast:GetRange()
                if nTargetDistanceSq < (nRange * nRange)-30 then 
					bActionTaken = core.OrderAbilityPosition(botBrain, abilBlast, vecTargetPosition)
                end
            end
        end 
		
        return object.harassExecuteOld(botBrain)
    end 
end
-- overload the behaviour stock function with custom 
object.harassExecuteOld = behaviorLib.HarassHeroBehavior["Execute"]
behaviorLib.HarassHeroBehavior["Execute"] = HarassHeroExecuteOverride

--Retreat From Threat Override
function funcRetreatFromThreatExecuteOverride(botBrain)
	local bDebugEchos = true
	local bActionTaken = false
	local unitSelf = core.unitSelf	
	local vecMyPosition = unitSelf:GetPosition()
	local nlastRetreatUtil = behaviorLib.lastRetreatUtil
	local unitTarget = behaviorLib.heroTarget
	local tEnemies = core.localUnits["EnemyHeroes"]
	local nCount = 0
	
	
	if unitSelf:GetHealthPercent() < .4 then
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
				local vecPos = behaviorLib.PositionSelfBackUp()
				local abilFlash = skills.abilW
				if behaviorLib.lastRetreatUtil >= 30 and abilFlash:CanActivate() then
					if bDebugEchos then BotEcho ("Backing...Blink") end
					bActionTaken = core.OrderAbilityPosition(botBrain, abilFlash, vecPos)
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

--Last Hit Override
function behaviorLib.GetCreepAttackTarget(botBrain, unitEnemyCreep, unitAllyCreep)
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


--------------------------------------------------------------
-- Function to determine utility of using Scream in
-- farming situations.
--------------------------------------------------------------
function behaviorLib.ScreamUtility(botBrain)
	local unitSelf = core.unitSelf
	local nUtility = 0
	local nHowToFarmACreep = 40
	local abilScream = skills.abilE
	local nScreamRange = 400
	nScreamRange = nScreamRange * nScreamRange
	local nCandPos = 0
	local nRangeCheck = 0
	local nNumCand = 0
	local bDC = false
	
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


	if abilScream:CanActivate() then
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
				if nRangeCheck and nRangeCheck <= nScreamRange then
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

function behaviorLib.ScreamExecute(botBrain)
	local abilScream = skills.abilE

	if abilScream:CanActivate() then
		bActionTaken = core.OrderAbility(botBrain, abilScream)
	end
end

behaviorLib.ScreamBehavior = {}
behaviorLib.ScreamBehavior["Utility"] = behaviorLib.ScreamUtility
behaviorLib.ScreamBehavior["Execute"] = behaviorLib.ScreamExecute
behaviorLib.ScreamBehavior["Name"] = "Scream"
tinsert(behaviorLib.tBehaviors, behaviorLib.ScreamBehavior)



