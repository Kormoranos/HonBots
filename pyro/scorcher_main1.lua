-------------------------------------------------------------------
-------------------------------------------------------------------
--    _                          _                 
--   | |                        | |                
--    \ \   ____ ___   ____ ____| | _   ____  ____ 
--     \ \ / ___) _ \ / ___) ___) || \ / _  )/ ___)
-- _____) | (__| |_| | |  ( (___| | | ( (/ /| |    
--(______/ \____)___/|_|   \____)_| |_|\____)_| 
--
-------------------------------------------------------------------
-------------------------------------------------------------------
-- Scorcher v0.0000001
-- This is the tutorial bot.

--####################################################################
--####################################################################
--#                                                                 ##
--#                       Bot Initiation                            ##
--#                                                                 ##
--####################################################################
--####################################################################


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
local ceil, floor, pi, tan, atan, atan2, abs, cos, sin, acos, max, random, sqrt
    = _G.math.ceil, _G.math.floor, _G.math.pi, _G.math.tan, _G.math.atan, _G.math.atan2, _G.math.abs, _G.math.cos, _G.math.sin, _G.math.acos, _G.math.max, _G.math.random

local BotEcho, VerboseLog, BotLog = core.BotEcho, core.VerboseLog, core.BotLog
local Clamp = core.Clamp

local sqrtTwo = math.sqrt(2)
local gold=0

BotEcho(object:GetName()..' loading scorcher_main...')




--####################################################################
--####################################################################
--#                                                                 ##
--#                  Bot Constant Definitions                       ##
--#                                                                 ##
--####################################################################
--####################################################################

-- Hero_<hero>  to reference the internal HoN name of a hero, Hero_Yogi ==Wildsoul
object.heroName = 'Hero_Pyromancer'


--   Item Buy order. Internal names  
behaviorLib.StartingItems  = {"Item_RunesOfTheBlight", "Item_MinorTotem", "Item_MinorTotem", "Item_MarkOfTheNovice", "Item_PretendersCrown"}
behaviorLib.LaneItems  = {"Item_Steamboots", "Item_GraveLocket"}
behaviorLib.MidItems  = {"Item_PortalKey", "Item_Lightbrand" ,"Item_Morph"}
behaviorLib.LateItems  = {"Item_GrimoireOfPower"}


-- Skillbuild table, 0=Q, 1=W, 2=E, 3=R, 4=Attri
object.tSkills = {
    1, 2, 0, 0, 0,
    3, 0, 1, 1, 1, 
    3, 2, 2, 2, 4,
    3, 4, 4, 4, 4,
    4, 4, 4, 4, 4,
}

-- These are bonus agression points if a skill/item is available for use
object.nPhoenixUp = 30
object.nDragonUp = 35 
object.nBlazingUp = 40
object.nPortalKeyUp = 15

-- These are bonus agression points that are applied to the bot upon successfully using a skill/item
object.nPhoenixUse = 15
object.nDragonUse = 25
object.nBlazingUse = 55
object.nPortalKeyUse = 18


--These are thresholds of aggression the bot must reach to use these abilities
object.nPhoenixThreshold = 20
object.nDragonThreshold = 10
object.nBlazingThreshold = 60
object.nPortalKeyThreshold = 10




--####################################################################
--####################################################################
--#                                                                 ##
--#   Bot Function Overrides                                        ##
--#                                                                 ##
--####################################################################
--####################################################################

------------------------------
--     Skills               --
------------------------------
-- @param: none
-- @return: none
function object:SkillBuild()
    core.VerboseLog("SkillBuild()")

-- takes care at load/reload, <NAME_#> to be replaced by some convinient name.
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
    
   
    local nLev = unitSelf:GetLevel()
    local nLevPts = unitSelf:GetAbilityPointsAvailable()
    for i = nLev, nLev+nLevPts do
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
--            OncombatEvent Override        --
-- Use to check for Infilictors (fe. Buffs) --
----------------------------------------------
-- @param: EventData
-- @return: none 
function object:oncombateventOverride(EventData)
    self:oncombateventOld(EventData)

    local nAddBonus = 0

    if EventData.Type == "Ability" then
        if EventData.InflictorName == "Ability_Pyromancer2" then
            nAddBonus = nAddBonus + object.nDragonUse
        elseif EventData.InflictorName == "Ability_Pyromancer1" then
            nAddBonus = nAddBonus + object.nPhoenixUse
        elseif EventData.InflictorName == "Ability_Pyromancer4" then
            nAddBonus = nAddBonus + object.nBlazingUse
        end
	
	elseif EventData.Type == "Item" then
        if core.itemPortalkey ~= nil and EventData.SourceUnit == core.unitSelf:GetUniqueID() and EventData.InflictorName == core.itemPortalkey:GetName() then
            nAddBonus = nAddBonus + self.nPortalkeyUse
        end
    end
	

   if nAddBonus > 0 then
        core.DecayBonus(self)
        core.nHarassBonus = core.nHarassBonus + nAddBonus
    end
end
-- override combat event trigger function.
object.oncombateventOld = object.oncombatevent
object.oncombatevent     = object.oncombateventOverride



------------------------------------------------------
--            CustomHarassUtility Override          --
-- Change Utility according to usable spells here   --
------------------------------------------------------
-- @param: IunitEntity hero
-- @return: number
local function CustomHarassUtilityFnOverride(hero)
    local nUtil = 50
    
	BotEcho("Rethinking hass")
	
	local unitSelf = core.unitSelf
    
	if skills.abilQ:CanActivate() then
        nUtil = nUtil + object.nPhoenixUp
    end

    if skills.abilW:CanActivate() then
        nUtil = nUtil + object.nDragonUp
    end

    if skills.abilR:CanActivate() then
        nUtil = nUtil + object.nStrikeUp
    end

	
	if object.itemPortalkey and object.itemPortalkey:CanActivate() then
        nUtility = nUtility + object.nPortalkeyUp
    end

	if (unitSelf:GetMana()>400 and skills.abilQ:CanActivate() and skills.abilW:CanActivate()) then
		nUtil=100
	end
	
    return nUtil
end
-- assisgn custom Harrass function to the behaviourLib object
behaviorLib.CustomHarassUtilityFn = CustomHarassUtilityFnOverride   

--Relative Movement
local tRelativeMovements = {}
local function createRelativeMovementTable(key)
	--BotEcho('Created a relative movement table for: '..key)
	tRelativeMovements[key] = {
		vLastPos = Vector3.Create(),
		vRelMov = Vector3.Create(),
		timestamp = 0
	}
	BotEcho('Created a relative movement table for: '..tRelativeMovements[key].timestamp)
end
createRelativeMovementTable("Stun") -- for connecting stun

local function relativeMovement(sKey, vTargetPos)
	local debugEchoes = false
	
	local gameTime = HoN.GetGameTime()
	local key = sKey
	local vLastPos = tRelativeMovements[key].vLastPos
	local nTS = tRelativeMovements[key].timestamp
	local timeDiff = gameTime - nTS 
	
	if debugEchoes then
		BotEcho('Updating relative movement for key: '..key)
		BotEcho('Relative Movement position: '..vTargetPos.x..' | '..vTargetPos.y..' at timestamp: '..nTS)
		BotEcho('Relative lastPosition is this: '..vLastPos.x)
	end
	
	if timeDiff >= 90 and timeDiff <= 140 then -- 100 should be enough (every second cycle)
		local relativeMov = vTargetPos-vLastPos
		
		if vTargetPos.LengthSq > vLastPos.LengthSq
		then relativeMov =  relativeMov*-1 end
		
		tRelativeMovements[key].vRelMov = relativeMov
		tRelativeMovements[key].vLastPos = vTargetPos
		tRelativeMovements[key].timestamp = gameTime
		
		if debugEchoes then
			BotEcho('Relative movement -- x: '..relativeMov.x..' y: '..relativeMov.y)
			BotEcho('^r---------------Return new-'..tRelativeMovements[key].vRelMov.x)
		end
		
		return relativeMov
	elseif timeDiff >= 150 then
		tRelativeMovements[key].vRelMov =  Vector3.Create(0,0)
		tRelativeMovements[key].vLastPos = vTargetPos
		tRelativeMovements[key].timestamp = gameTime
	end
	
	if debugEchoes then BotEcho('^g---------------Return old-'..tRelativeMovements[key].vRelMov.x) end
	return tRelativeMovements[key].vRelMov
end

----------------------------------
--  FindItems Override
----------------------------------
local function funcFindItemsOverride(botBrain)
	local bUpdated = object.FindItemsOld(botBrain)

	
	
	if core.itemPortalKey ~= nil and not core.itemPortalKey:IsValid() then
		core.itemPortalKey = nil
	end

    if bUpdated then
    	if core.itemPortalKey then
			return
		end

		local inventory = core.unitSelf:GetInventory(true)
		for slot = 1, 12, 1 do
			local curItem = inventory[slot]
			if curItem then
				if core.itemPortalKey == nil and curItem:GetName() == "Item_PortalKey" then
					core.itemPortalKey = core.WrapInTable(curItem)
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
local timeStunned=0
local function HarassHeroExecuteOverride(botBrain)
    
    local unitTarget = behaviorLib.heroTarget
    if unitTarget == nil then
        return object.harassExecuteOld(botBrain)  --Target is invalid, move on to the next behavior
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
	
	local nPredictStun = sqrt(nTargetDistanceSq)/1200
	local relativeMov = relativeMovement("Stun", vecTargetPosition) * nPredictStun
	
	
    local abilDragon = skills.abilW
    local abilBlazing = skills.abilR
	
	if unitTarget == nil then
        return object.harassExecuteOld(botBrain) --Target is invalid, move on to the next behavior
    end

    --since we are using an old pointer, ensure we can still see the target for entity targeting
	if core.CanSeeUnit(botBrain, unitTarget) then
		
		local bTargetVuln = unitTarget:IsStunned() or unitTarget:IsImmobilized() or unitTarget:IsPerplexed()
       core.FindItems()
		local itemPortalKey = core.itemPortalKey 
		
        
     
   
        -- Dragon Fire or Sheep - on unit.
        if not bActionTaken and not bTargetVuln then            
                   
 		   if itemPortalKey then
				local nPortalKeyRange = itemPortalKey:GetRange()
            
			if itemPortalKey:CanActivate() then--and unitSelf:GetMana()>315 and nLastHarassUtility > botBrain.nPortalkeyThreshold then
					--BotEcho(" " .. nTargetDistanceSq .. " " .. (nRange*nRange));
                    if nTargetDistanceSq <= (nPortalKeyRange*nPortalKeyRange) and nTargetDistanceSq>(750*750) then
						bActionTaken = core.OrderItemPosition(botBrain, unitSelf, itemPortalKey, vecTargetPosition) --teleport on that mofo
						
						bActionTaken = core.OrderAbilityPosition(botBrain, abilStun,(vecTargetPosition+relativeMov), false, true)
						timeStunned=HoN.GetGameTime()
					
						bActionTaken = core.OrderAttackClamp(botBrain, unitSelf, unitTarget, false, true)
						
					elseif nTargetDistanceSq>(nPortalKeyRange*nPortalKeyRange) then
						bActionTaken = core.OrderMoveToUnitClamp(botBrain, unitSelf, unitTarget)
					end
				end
            end
			
			
   
            if abilDragon:CanActivate() and nLastHarassUtility > botBrain.nDragonThreshold then
                local nRange = abilDragon:GetRange()
                if nTargetDistanceSq < (nRange * nRange) then
                    bActionTaken = core.OrderAbilityPosition(botBrain, abilDragon, vecTargetPosition)
                end           
            end 
        
    


     -- Phoenix Wave
    if not bActionTaken then
        local abilPhoenix = skills.abilQ
        if abilPhoenix:CanActivate() and nLastHarassUtility > botBrain.nPhoenixThreshold then
            local nRange = abilPhoenix:GetRange()
            if nTargetDistanceSq < (nRange * nRange) then
				bActionTaken = core.OrderAbilityPosition(botBrain, abilPhoenix, vecTargetPosition)
            else
                bActionTaken = core.OrderMoveToUnitClamp(botBrain, unitSelf, unitTarget)
            end
        end
    end 

     -- Blazing Strike
    if core.CanSeeUnit(botBrain, unitTarget) then
        local abilBlazing = skills.abilR
        if not bActionTaken then --and bTargetVuln then
            if abilBlazing:CanActivate() and nLastHarassUtility > botBrain.nBlazingThreshold then
                local nRange = abilBlazing:GetRange()
                if nTargetDistanceSq < (nRange * nRange) then
        		    bActionTaken = core.OrderAbilityEntity(botBrain, abilBlazing, unitTarget)
                else
                    bActionTaken = core.OrderMoveToUnitClamp(botBrain, unitSelf, unitTarget)
                end
            end
        end  
    end  
end
 end   
    if not bActionTaken then
        return object.harassExecuteOld(botBrain) 
    end 
end

object.harassExecuteOld = behaviorLib.HarassHeroBehavior["Execute"]
behaviorLib.HarassHeroBehavior["Execute"] = HarassHeroExecuteOverride

function behaviorLib.GetCreepAttackTarget(botBrain, unitEnemyCreep, unitAllyCreep) --called pretty much constantly    local unitSelf = core.unitSelf
    if gold>2700 then
        --BotEcho("Returning to well!")
        local wellPos = core.allyWell and core.allyWell:GetPosition() or behaviorLib.PositionSelfBackUp()
        core.OrderMoveToPosAndHoldClamp(botBrain, unitSelf, wellPos, false)
    end
 
 
    local bDebugEchos = false
    -- prefers LH over deny
 
 
    local unitSelf = core.unitSelf
    local nDamageAverage = unitSelf:GetFinalAttackDamageMin()
    --BotEcho(nDamageAverage)
    gold=botBrain:GetGold()
     
    core.FindItems(botBrain)
 
 
    --[[ [Difficulty: Easy] Make bots worse at last hitting
    if core.nDifficulty == core.nEASY_DIFFICULTY then
        nDamageAverage = nDamageAverage + 120
    end
    ]]
 
 
    local nProjectileSpeed = unitSelf:GetAttackProjectileSpeed()
 
 
    if unitEnemyCreep and core.CanSeeUnit(botBrain, unitEnemyCreep) then
        local nTargetHealth = unitEnemyCreep:GetHealth()
        local tNearbyAllyCreeps = core.localUnits['AllyCreeps']
        local nExpectedCreepDamage = 0
 
 
        local vecTargetPos = unitEnemyCreep:GetPosition()
        local nProjectileTravelTime = Vector3.Distance2D(unitSelf:GetPosition(), vecTargetPos) / nProjectileSpeed
        if bDebugEchos then BotEcho ("Projectile travel time: " .. nProjectileTravelTime ) end
 
 
        --if bDebugEchos then BotEcho("Enemy creep is " .. tostring(unitEnemyCreep)) end
         
        --Determine the damage expcted on the creep by other creeps
        for i, unitCreep in pairs(tNearbyAllyCreeps) do
            if bDebugEchos and unitCreep then
                --BotEcho ("Ally creep is attacking " .. tostring(unitCreep:GetAttackTarget()))
                --BotEcho (" for damage of " .. unitCreep:GetFinalAttackDamageMin())
                --BotEcho ("Attack is ready: " .. tostring(unitCreep:IsAttackReady()))
            end   
            if unitCreep:GetAttackTarget() == unitEnemyCreep and unitCreep:IsAttackReady() then
                 
                local nCreepAttacks = unitCreep:GetAttackSpeed() / nProjectileTravelTime
                nExpectedCreepDamage = nExpectedCreepDamage + unitCreep:GetFinalAttackDamageMin() * nCreepAttacks
            end
        end
         
        if bDebugEchos then BotEcho ("Excpecting ally creeps to damage enemy creep for " .. nExpectedCreepDamage .. " - using this to anticipate lasthit time") end
         
        if nDamageAverage >= (nTargetHealth - nExpectedCreepDamage) then
            local bActuallyLH = true
             
            -- [Tutorial] Make DS not mess with your last hitting before **** gets real
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
        local nExpectedCreepDamage = 0
 
 
        local vecTargetPos = unitAllyCreep:GetPosition()
        local nProjectileTravelTime = Vector3.Distance2D(unitSelf:GetPosition(), vecTargetPos) / nProjectileSpeed
        if bDebugEchos then BotEcho ("Projectile travel time: " .. nProjectileTravelTime ) end
 
 
        --if bDebugEchos then BotEcho("Ally creep is " .. tostring(unitAllyCreep)) end
         
        --Determine the damage expcted on the creep by other creeps
        for i, unitCreep in pairs(tNearbyEnemyCreeps) do
            if bDebugEchos and unitCreep then
                --BotEcho ("Enemy creep is attacking " .. tostring(unitCreep:GetAttackTarget()))
                --BotEcho (" for damage of " .. unitCreep:GetFinalAttackDamageMin())
                --BotEcho ("Attack is ready: " .. tostring(unitCreep:IsAttackReady()))
            end   
            if unitCreep:GetAttackTarget() == unitAllyCreep and unitCreep:IsAttackReady() then
                local nCreepAttacks = unitCreep:GetAttackSpeed() / nProjectileTravelTime
                nExpectedCreepDamage = nExpectedCreepDamage + unitCreep:GetFinalAttackDamageMin() * nCreepAttacks
            end
        end
         
        if bDebugEchos then BotEcho ("Expecting enemy creeps to damage ally creep for " .. nExpectedCreepDamage .. " - using this to anticipate deny time") end
         
        if nDamageAverage >= (nTargetHealth - nExpectedCreepDamage) then
            local bActuallyDeny = true
             
            --[Difficulty: Easy] Don't deny
            if core.nDifficulty == core.nEASY_DIFFICULTY then
                bActuallyDeny = false
            end        
             
            -- [Tutorial] Hellbourne *will* deny creeps after **** gets real
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

-- overload the behaviour stock function with custom 

behaviorLib.AttackCreepsBehavior["Execute"] = AttackCreepsExecuteOverride
