-- Pebbs v0.1
-- This bot represent the BARE minimum required for HoN to spawn a bot
-- and contains some very basic overrides you can fill in
--

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

object.core 		= {}
object.eventsLib 	= {}
object.metadata 	= {}
object.behaviorLib 	= {}
object.skills 		= {}

runfile "bots/core.lua"
runfile "bots/botbraincore.lua"
runfile "bots/eventslib.lua"
runfile "bots/metadata.lua"
runfile "bots/behaviorlib.lua"

local core, eventsLib, behaviorLib, metadata, skills = object.core, object.eventsLib, object.behaviorLib, object.metadata, object.skills

local print, ipairs, pairs, string, table, next, type, tinsert, tremove, tsort, format, tostring, tonumber, strfind, strsub
	= _G.print, _G.ipairs, _G.pairs, _G.string, _G.table, _G.next, _G.type, _G.table.insert, _G.table.remove, _G.table.sort, _G.string.format, _G.tostring, _G.tonumber, _G.string.find, _G.string.sub
local ceil, floor, pi, tan, atan, atan2, abs, cos, sin, acos, max, random, sqrt
	= _G.math.ceil, _G.math.floor, _G.math.pi, _G.math.tan, _G.math.atan, _G.math.atan2, _G.math.abs, _G.math.cos, _G.math.sin, _G.math.acos, _G.math.max, _G.math.random, _G.math.sqrt

local BotEcho, VerboseLog, BotLog = core.BotEcho, core.VerboseLog, core.BotLog
local Clamp = core.Clamp

local sqrtTwo = math.sqrt(2)
local gold=0

BotEcho('loading pebbs_main...')

--####################################################################
--####################################################################
--#                                                                 ##
--#                  bot constant definitions                       ##
--#                                                                 ##
--####################################################################
--####################################################################

-- hero_<hero>  to reference the internal hon name of a hero, hero_yogi ==wildsoul
object.heroName = 'Hero_Pyromancer'

--   item buy order. internal names  
behaviorLib.StartingItems  = {"Item_RunesOfTheBlight", "Item_MinorTotem", "Item_MinorTotem", "Item_MarkOfTheNovice", "Item_PretendersCrown"}
behaviorLib.LaneItems  = {"Item_Steamboots", "Item_GraveLocket"}
behaviorLib.MidItems  = {"Item_PortalKey", "Item_Morph", "Item_Lightbrand"}
behaviorLib.LateItems  = {"Item_GrimoireOfPower"}


-- skillbuild table, 0=q, 1=w, 2=e, 3=r, 4=attri
object.tSkills = {
    1, 2, 0, 0, 0,
    3, 0, 1, 1, 1, 
    3, 2, 2, 2, 4,
    3, 4, 4, 4, 4,
    4, 4, 4, 4, 4,
}

-- bonus agression points if a skill/item is available for use


-- bonus agression points that are applied to the bot upon successfully using a skill/item


--thresholds of aggression the bot must reach to use these abilities





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
    --core.verboselog("skillbuild()")

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

-- well=phaseboots, bad=striders
-- well=portalkey, terrible=tablet
-- well=demonic, bad=HotBL
-- well=heart, bad=shamans

local nHiding=false;
------------------------------------------------------
--            onthink override                      --
-- Called every bot tick, custom onthink code here  --
------------------------------------------------------
-- @param: tGameVariables
-- @return: none
function object:onthinkOverride(tGameVariables)
    self:onthinkOld(tGameVariables)

	--BotEcho("thinking");
	--core.nHarassBonus=1000
	
	
	
	if (nHiding) then
		--run to jokespot and teleport
	end
end
object.onthinkOld = object.onthink
object.onthink 	= object.onthinkOverride



-- These are bonus agression points if a skill/item is available for use
object.nPhoenixUp = 15
object.nDragonUp = 15 
object.nBlazingUp = 40
object.nPortalKeyUp = 15
object.nSheepUp = 18
-- These are bonus agression points that are applied to the bot upon successfully using a skill/item
object.nPhoenixUse = 15
object.nDragonUse = 25
object.nBlazingUse = 55
object.nPortalKeyUse = 18
object.nSheepUse = 18
--These are thresholds of aggression the bot must reach to use these abilities
object.nPhoenixThreshold = 16
object.nDragonThreshold = 16
object.nBlazingThreshold = 60
object.nPortalKeyThreshold = 10
object.nSheepThreshold = 20

----------------------------------------------
--            oncombatevent override        --
-- use to check for infilictors (fe. buffs) --
----------------------------------------------
-- @param: eventdata
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
		
		if core.itemSheepstick ~= nil and EventData.SourceUnit == core.unitSelf:GetUniqueID() and EventData.InflictorName == core.itemSheepstick:GetName() then
            nAddBonus = nAddBonus + self.nSheepUse
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
--            customharassutility override          --
-- change utility according to usable spells here   --
------------------------------------------------------
-- @param: iunitentity hero
-- @return: number
local function AbilitiesUpUtility(hero) --how much to harrass, doesn't change combo order or anything
	local nUtility = 0 --already aggressive
	
	BotEcho("Rethinking hass")
	
    local unitSelf = core.unitSelf
	
    if skills.abilQ:CanActivate() then
        nUnility = nUtility + object.nPhoenixUp
    end
 
    if skills.abilW:CanActivate() then
        nUtility = nUtility + object.nDragonUp
    end
	
	if skills.abilR:CanActivate() then
        nUtility = nUtility + object.nBlazingUp
    end
	
	if object.itemPortalkey and object.itemPortalkey:CanActivate() then
        nUtility = nUtility + object.nPortalkeyUp
    end
	
	if object.itemSheepstick and object.itemSheepstick:CanActivate() then
        nUtility = nUtility + object.nSheepUp
    end
	
	--BotEcho("health:" .. hero:GetHealth());
	--local potentialDamage = (skills.abilQ:GetLevel()*60+40+skills.abilW:GetLevel()*75)/hero:GetMagicResistance()+unitSelf:GetFinalAttackDamageMin()*2/hero:GetPhysicalResistance()
	--BotEcho("potential damage:" .. potentialDamage );
	
	--calculate whether a kill is possible and probable.
	--if (unitSelf:GetMana()>265 and skills.abilQ:CanActivate() and skills.abilW:CanActivate() ) then

	--end
	-- if hero hp is low, combo up and in range, perhaps if someone is nearby and ping?(?)	
    return nUtility--nUtil -- no desire to attack AT ALL if 0.
end

local function CustomHarassUtilityFnOverride(hero)
	local nUtility = AbilitiesUpUtility(hero)	
	
	return Clamp(nUtility, 0, 100)
end
-- assisgn custom Harrass function to the behaviourLib object
behaviorLib.CustomHarassUtility = CustomHarassUtilityFnOverride   





--[[
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

]]--



local function funcFindItemsOverride(botBrain)
	local bUpdated = object.FindItemsOld(botBrain)

	if core.itemPortalKey ~= nil and not core.itemPortalKey:IsValid() then
		core.itemPortalKey = nil
	end
	if core.itemSheepstick ~= nil and not core.itemSheepstick:IsValid() then
        core.itemSheepstick = nil
    end
	
    if bUpdated then
    	if core.itemPortalKey and core.itemSheepstick then
			return
		end

		local inventory = core.unitSelf:GetInventory(true)
		for slot = 1, 12, 1 do
			local curItem = inventory[slot]
			if curItem then
				if core.itemPortalKey == nil and curItem:GetName() == "Item_PortalKey" then
					core.itemPortalKey = core.WrapInTable(curItem)
				end
			if core.itemSheepstick == nil and curItem:GetName() == "Item_Morph" then
                    core.itemSheepstick = core.WrapInTable(curItem)
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
        return object.harassExecuteOld(botBrain) --Target is invalid, move on to the next behavior
    end
    
    
    local unitSelf = core.unitSelf
    local vecMyPosition = unitSelf:GetPosition() --me
    local nAttackRange = core.GetAbsoluteAttackRangeToUnit(unitSelf, unitTarget)
    local nMyExtraRange = core.GetExtraRange(unitSelf)
    
    local vecTargetPosition = unitTarget:GetPosition() --them
    local nTargetExtraRange = core.GetExtraRange(unitTarget)
    local nTargetDistanceSq = Vector3.Distance2DSq(vecMyPosition, vecTargetPosition)
    
    local nLastHarassUtility = behaviorLib.lastHarassUtil
    local bCanSee = core.CanSeeUnit(botBrain, unitTarget)    
    local bActionTaken = false
	
	
	--local nPredictStun = sqrt(nTargetDistanceSq)/1200
	--local relativeMov = relativeMovement("Stun", vecTargetPosition) * nPredictStun
	
    local abilDragon = skills.abilW
    local abilBlazing = skills.abilR
    local abilPhoenix = skills.abilQ
	
    if unitTarget == nil then
        return object.harassExecuteOld(botBrain) --Target is invalid, move on to the next behavior
    end
	
    --BotEcho('Attempting Harass')
	
    
    --- Insert abilities code here, set bActionTaken to true 
    --- if an ability command has been given successfully
    
     --since we are using an old pointer, ensure we can still see the target for entity targeting
    if core.CanSeeUnit(botBrain, unitTarget) then
	
		
		--BotEcho("potential damage:" .. potentialDamage );
	
		--BotEcho(unitSelf:GetMana()) --working
        local bTargetVuln = unitTarget:IsStunned() or unitTarget:IsImmobilized() or unitTarget:IsPerplexed()
		core.FindItems()
		local itemPortalKey = core.itemPortalKey
		core.FindItems()
        local itemSheepstick = core.itemSheepstick
		--core.OrderAbilityPosition(botBrain, abilStun, vecTargetPosition)
		--bActionTaken=true
    
        -- PORTAL KEY IN!
        if not bActionTaken then-- and not bTargetVuln then -- TODO AND COMBO CAN KILL
			----[[
            if itemPortalKey then
				local nPortalKeyRange = itemPortalKey:GetRange()
                if itemPortalKey:CanActivate() then--and unitSelf:GetMana()>315 and nLastHarassUtility > botBrain.nPortalkeyThreshold then
					--BotEcho(" " .. nTargetDistanceSq .. " " .. (nRange*nRange));
                    if nTargetDistanceSq <= (nPortalKeyRange*nPortalKeyRange) and nTargetDistanceSq>(750*750) then
						bActionTaken = core.OrderItemPosition(botBrain, unitSelf, itemPortalKey, vecTargetPosition) --teleport on that mofo
						
						bActionTaken = core.OrderAbilityPosition(botBrain, abilStun, vecTargetPosition, false, true)
--						bActionTaken = core.OrderAbilityPosition(botBrain, abilStun,(vecTargetPosition+relativeMov), false, true)
						timeStunned=HoN.GetGameTime()
					
						bActionTaken = core.OrderAttackClamp(botBrain, unitSelf, unitTarget, false, true)
						
					elseif nTargetDistanceSq>(nPortalKeyRange*nPortalKeyRange) then
						bActionTaken = core.OrderMoveToUnitClamp(botBrain, unitSelf, unitTarget)
					end
				end
            end
			--]]
			-- stun!
			if itemSheepstick then
                local nRange = itemSheepstick:GetRange()
                if itemSheepstick:CanActivate() and nLastHarassUtility > botBrain.nSheepThreshold then
                    if nTargetDistanceSq < (nRange * nRange) then
                        if bDebugEchos then BotEcho("Using sheepstick") end
                        bActionTaken = core.OrderItemEntityClamp(botBrain, unitSelf, itemSheepstick, unitTarget)
                    end
                end
            end
			
            if abilDragon:CanActivate() and unitSelf:GetMana()>265 and abilPhoenix:CanActivate() then
                local nRange = 600--abilStun:GetRange()
				--BotEcho( "Stun range is " .. abilStun:GetRange() )
                if nTargetDistanceSq < (nRange * nRange) then --TODO perhaps something smarter here. to account for distance and speed and direction etc.
				
                    bActionTaken = core.OrderAbilityPosition(botBrain, abilDragon, vecTargetPosition)
--                    bActionTaken = core.OrderAbilityPosition(botBrain, abilDragon,(vecTargetPosition+relativeMov))
					timeStunned=HoN.GetGameTime()
					
                    bActionTaken = core.OrderAttackClamp(botBrain, unitSelf, unitTarget, false, true)
                else
                    bActionTaken = core.OrderAttackClamp(botBrain, unitSelf, unitTarget)
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
				local potentialDamage = (skills.abilR:GetLevel()*220+220)
				if not bActionTaken then --and bTargetVuln then
					if abilBlazing:CanActivate() and nLastHarassUtility > botBrain.nBlazingThreshold and unitTarget:GetHealth() <= potentialDamage then
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

-- overload the behaviour stock function with custom 
object.harassExecuteOld = behaviorLib.HarassHeroBehavior["Execute"]
behaviorLib.HarassHeroBehavior["Execute"] = HarassHeroExecuteOverride

function GetClosestEnemyHero(botBrain)
	local unitClosestHero = nil
	local nClosestHeroDistSq = 99999*99999
	--core.printGetTypeNameTable(HoN.GetHeroes(core.enemyTeam))
	for id, unitHero in pairs(HoN.GetHeroes(core.enemyTeam)) do
		if unitHero ~= nil then
			if core.CanSeeUnit(botBrain, unitHero) then
		
				local nDistanceSq = Vector3.Distance2DSq(unitHero:GetPosition(), core.unitSelf:GetPosition())
				if nDistanceSq < nClosestHeroDistSq then
					nClosestHeroDistSq = nDistanceSq
					unitClosestHero = unitHero
				end
			end
		end
	end
	
	return unitClosestHero
end

function IsTowerThreateningUnit(unit)
	vecPosition = unit:GetPosition()
	--TODO: switch to just iterate through the enemy towers instead of calling GetUnitsInRadius
	
	local nTowerRange = 821.6 --700 + (86 * sqrtTwo)
	nTowerRange = nTowerRange
	local tBuildings = HoN.GetUnitsInRadius(vecPosition, nTowerRange, core.UNIT_MASK_ALIVE + core.UNIT_MASK_BUILDING)
	for key, unitBuilding in pairs(tBuildings) do
		if unitBuilding:IsTower() and unitBuilding:GetCanAttack() and (unitBuilding:GetTeam()==unit:GetTeam())==false then
			return true
		end
	end
	
	return false
end


----------------------------------
-- Retreating tactics as seen in Spennerino's ScoutBot 
-- with variations from Rheged's Emerald Warden Bot
----------------------------------
object.nRetreatDragonThreshold = 15



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
				local abilDragon = skills.abilW
		
				if behaviorLib.lastRetreatUtil >= object.nRetreatDragonThreshold and abilDragon:CanActivate() then
					if bDebugEchos then BotEcho("Backing...Stun") end
					bActionTaken = core.OrderAbilityPosition(botBrain, abilDragon, (vecMyPosition/2+vecTargetPosition/2))
				end
			end	
		end
	end
		
		
	if not bActionTaken then
		return object.RetreatFromThreatExecuteOld(botBrain)
	end
end
object.RetreatFromThreatExecuteOld = behaviorLib.RetreatFromThreatExecute
behaviorLib.RetreatFromThreatBehavior["Execute"] = funcRetreatFromThreatExecuteOverride



function behaviorLib.GetCreepAttackTarget(botBrain, unitEnemyCreep, unitAllyCreep) --called pretty much constantly
unitSelf=core.unitSelf
	if gold>5600 then
		--BotEcho("Returning to well!")
		local wellPos = core.allyWell and core.allyWell:GetPosition() or behaviorLib.PositionSelfBackUp()
		core.OrderMoveToPosAndHoldClamp(botBrain, unitSelf, wellPos, false)
	end
	-- random stuff that should be called each frame!
	target = GetClosestEnemyHero(botBrain)
	--BotEcho(target:GetDisplayName())
	if (target==nil) then --cant use target != nill, weird
		--BotEcho("what")
		core.nHarassBonus=0
	else
		--												 60
		
		--BotEcho("Looking at " .. target:GetHealth())
		if core.CanSeeUnit(botBrain, target) then
			--BotEcho("Looking at " .. potentialDamage .. " " .. target:GetHealth() .. " " .. target:GetMagicResistance())
			if target:HasState("State_HealthPotion") or IsTowerThreateningUnit(target) then
				core.nHarassBonus=1000
				--BotEcho("Healing, in tower range or killable...... ATTACK!")
			else
				core.nHarassBonus=0
			end
		else
			core.nHarassBonus=0
		end
	end
	


	local bDebugEchos = false
	-- no predictive last hitting, just wait and react when they have 1 hit left
	-- prefers LH over deny

	local unitSelf = core.unitSelf
	local nDamageAverage = unitSelf:GetFinalAttackDamageMin()+40 --make the hero go to the unit
	--BotEcho(nDamageAverage)
	gold=botBrain:GetGold()
	
	core.FindItems(botBrain)
	if core.itemHatchet then
		nDamageAverage = nDamageAverage * core.itemHatchet.creepDamageMul
	end	
	
	-- [Difficulty: Easy] Make bots worse at last hitting
	if core.nDifficulty == core.nEASY_DIFFICULTY then
		nDamageAverage = nDamageAverage + 120
	end

	if unitEnemyCreep and core.CanSeeUnit(botBrain, unitEnemyCreep) then
		local nTargetHealth = unitEnemyCreep:GetHealth()
		if nDamageAverage >= nTargetHealth then
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
		if nDamageAverage >= nTargetHealth then
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
	local currentTarget = core.unitCreepTarget

	if currentTarget and core.CanSeeUnit(botBrain, currentTarget) then		
		local vecTargetPos = currentTarget:GetPosition()
		local nDistSq = Vector3.Distance2DSq(unitSelf:GetPosition(), vecTargetPos)
		local nAttackRangeSq = core.GetAbsoluteAttackRangeToUnit(unitSelf, currentTarget, true)
		
		local nDamageAverage = unitSelf:GetFinalAttackDamageMin()

		if currentTarget ~= nil then
			if nDistSq < nAttackRangeSq and unitSelf:IsAttackReady() and nDamageAverage>=currentTarget:GetHealth() then --only kill if you can get gold
				--only attack when in nRange, so not to aggro towers/creeps until necessary, and move forward when attack is on cd
				core.OrderAttackClamp(botBrain, unitSelf, currentTarget)
			elseif (nDistSq > nAttackRangeSq) then
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



--HarassHeroExecuteOverride
--behaviorLib.GetCreepAttackTarget
--object.harassExecuteOld = behaviorLib.HarassHeroBehavior["Execute"]
--behaviorLib.HarassHeroBehavior["Execute"] = HarassHeroExecuteOverride

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
	local abilStun = skills.abilW
	local nStunRange = 500
	nStunRange = nStunRange * nStunRange
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


	if abilStun:CanActivate() then
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
				if nRangeCheck and nRangeCheck <= nStunRange then
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
	local abilStun = skills.abilW
	local abilph = skills.abilQ
	local vCreepCenter = groupCenter(core.localUnits["EnemyCreeps"], 3)
	if abilStun:CanActivate() and abilph:GetLevel()>2 and unitSelf:GetMana() > 800 then
		bActionTaken = core.OrderAbilityPosition(botBrain, abilStun, vCreepCenter)
		bActionTaken = core.OrderAbilityPosition(botBrain, abilph, vCreepCenter)
	end
end

behaviorLib.CallBehavior = {}
behaviorLib.CallBehavior["Utility"] = behaviorLib.CallUtility
behaviorLib.CallBehavior["Execute"] = behaviorLib.CallExecute
behaviorLib.CallBehavior["Name"] = "Call"
tinsert(behaviorLib.tBehaviors, behaviorLib.CallBehavior)











BotEcho('finished loading pebbs_main')