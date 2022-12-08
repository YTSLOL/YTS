local Player = game.localPlayer

local _delayAction = { }
local yasuoShield = {100, 105, 110, 115, 120, 130, 140, 150, 165, 180, 200, 225, 255, 290, 330, 380, 440, 510}
local interrupt_spells = {
    ["anivia"] = { {menuslot = "R", slot = 3, spellname = "glacialstorm", channelduration = 6} },
    ["caitlyn"] = { {menuslot = "R", slot = 3, spellname = "caitlynaceinthehole", channelduration = 1}},
    ["fiddlesticks"] = {{menuslot = "W", slot = 1, spellname = "drainchannel", channelduration = 2}, {menuslot = "R", slot = 3, spellname = "crowstorm", channelduration = 1.5}},
    ["janna"] = { {menuslot = "R", slot = 3, spellname = "reapthewhirlwind", channelduration = 3} },
    ["karthus"] = {{menuslot = "R", slot = 3, spellname = "karthusfallenone", channelduration = 3}},
    ["katarina"] = {{menuslot = "R", slot = 3, spellname = "katarinar", channelduration = 2.5}},
    ["lucian"] = {{menuslot = "R", slot = 3, spellname = "lucianr", channelduration = 3}},
    ["malzahar"] = {{menuslot = "R", slot = 3, spellname = "malzaharr", channelduration = 2.5}},
    ["masteryi"] = { {menuslot = "W", slot = 1, spellname = "meditate", channelduration = 4} },
    ["missfortune"] = {{menuslot = "R", slot = 3, spellname = "missfortunebullettime", channelduration = 3}},
    ["nunu"] = {{menuslot = "R", slot = 3, spellname = "nunur", channelduration = 3}},
    ["pantheon"] = {{menuslot = "R", slot = 3, spellname = "pantheonrjump", channelduration = 2}, {menuslot = "Q", slot = 0, spellname = "pantheonq", channelduration = 4}},
    ["poppy"] = {{menuslot = "R", slot = 3, spellname = "poppyr", channelduration = 4}},
    ["quinn"] = { {menuslot = "R", slot = 3, spellname = "quinr", channelduration = 2}},
    ["shen"] = {{menuslot = "R", slot = 3, spellname = "shenr", channelduration = 3}},
    ["galio"] = {{menuslot = "R", slot = 3, spellname = "galior", channelduration = 3}},
    ["sion"] = { {menuslot = "Q", slot = 0, spellname = "sionq", channelduration = 2}},
    ["tahmkench"] = {{menuslot = "R", slot = 3, spellname = "tahmkenchnewr", channelduration = 3}},
    ["twistedfate"] = {{menuslot = "R", slot = 3, spellname = "gate", channelduration = 1.5}},
    ["varus"] = { {menuslot = "Q", slot = 0, spellname = "varusq", channelduration = 4}},
    ["velkoz"] = {{menuslot = "R", slot = 3, spellname = "velkozr", channelduration = 2.5}},
    ["warwick"] = { {menuslot = "R", slot = 3, spellname = "warwickrchannel", channelduration = 1.5}},
    ["xerath"] = {{menuslot = "Q", slot = 0, spellname = "xeratharcanopulsechargeup", channelduration = 3}, {menuslot = "R", slot = 3, spellname = "xerathlocusofpower2", channelduration = 10}},
    ["zac"] = {{menuslot = "E", slot = 2, spellname = "zace", channelduration = 4}},
    ["jhin"] = {{menuslot = "R", slot = 3, spellname = "jhinr", channelduration = 10}},
    ["pyke"] = {{menuslot = "Q", slot = 0, spellname = "pykeq", channelduration = 3}},
    ["vi"] = {{menuslot = "Q", slot = 0, spellname = "viq", channelduration = 4}},
    ["samira"] = {{menuslot = "R", slot = 3, spellname = "samirar", channelduration = 2}}
}

local hard_cc = {
    [5] = true, -- stun
    [8] = true, -- taunt
    [12] = true, -- snare
    [22] = true, -- fear
    [23] = true, -- charm
    [25] = true, -- suppression
    [29] = true, -- flee
    [30] = true, -- knockup
    [31] = true, -- knockback
}

local BuffType = {
    Internal = 0,
    Aura = 1,
    CombatEnchancer = 2,
    CombatDehancer = 3,
    SpellShield = 4,
    Stun = 5,
    Invisibility = 6,
    Silence = 7,
    Taunt = 8,
    Berserk = 9,
    Polymorph = 10,
    Slow = 11,
    Snare = 12,
    Damage = 13,
    Heal = 14,
    Haste = 15,
    SpellImmunity = 16,
    PhysicalImmunity = 17,
    Invulnerability = 18,
    AttackSpeedSlow = 19,
    NearSight = 20,
    Fear = 22,
    Charm = 23,
    Poison = 24,
    Suppression = 25,
    Blind = 26,
    Counter = 27,
    Currency = 21,
    Shred = 28,
    Flee = 29,
    Knockup = 30,
    Knockback = 31,
    Disarm = 32,
    Grounded = 33,
    Drowsy = 34,
    aSleep = 35,
    Obscured = 36,
    ClickProofToEnemies = 37,
    Unkillable = 38
}

local DelayAction = function(delay, funct, args)
    _delayAction[#_delayAction + 1] = { funct = funct, time = game.GameTick + delay, args = args}
end

local ExecuteDelay = function()
    for i = #_delayAction, 1, -1 do
        if _delayAction[i].time < game.GameTick then
            _delayAction[i].funct(unpack(_delayAction[i].args or {}))
            _delayAction[i] = _delayAction[#_delayAction]
            _delayAction[#_delayAction] = nil
        end
    end
end

local function HasBuff(name, source)
    source = source or Player
	if not name then
		return false
	end

	local hash = game.FNV(name)

	for i, userdata in pairs(source:Buffs()) do
		if userdata.NameHash == hash and game.GameTime > userdata.EndTime then
			return true, userdata
		end
	end

	return false
end

local function GetBuffValid(target, name)
    assert(target, "getBuffValid: no target")
    assert(name, "getBuffValid: no buffname/type")

	local hash = game.FNV(name)

    for i, buff in pairs(target:Buffs()) do
		if buff.NameHash == hash then
            return buff and buff.EndTime > game.GameTick and math.max(buff.Count, buff.Count) > 0
        end
    end

    return false
end

local function GetBuffTypeValid(target, bType)
    assert(target, "getBuffValid: no target")
    assert(bType, "getBuffValid: no type")

    for i, buff in pairs(target:Buffs()) do
		if buff.Type == bType then
            return buff and buff.EndTime > game.GameTick and math.max(buff.Count, buff.Count) > 0
        end
    end

    return false
end

local function GetBuffStacks(target, name, validate)
    assert(target, "getBuffStacks: no target")
    assert(name, "getBuffStacks: no buffname/type")

	local hash = game.FNV(name)

    for i, buff in pairs(target:Buffs()) do
		if buff.NameHash == hash then
            return buff and (validate == false or buff.EndTime > game.GameTick) and math.max(buff.Count, buff.Count) or 0
        end
    end

    return 0
end

local function GetBuffStartTime(target, name, validate)
    assert(target, "getBuffStartTime: no target")
    assert(name, "getBuffStartTime: no buffname/type")

	local hash = game.FNV(name)

    for i, buff in pairs(target:Buffs()) do
		if buff.NameHash == hash then
            return buff and (validate == false or buff.EndTime > game.GameTick) and buff.StartTime or 0
        end
    end

    return 0
end

local function GetBuffEndTime(target, name, validate)
    assert(target, "getBuffEndTime: no target")
    assert(name, "getBuffEndTime: no buffname/type")

	local hash = game.FNV(name)

    for i, buff in pairs(target:Buffs()) do
		if buff.NameHash == hash then
            return buff and (validate == false or buff.EndTime > game.GameTick) and buff.EndTime or 0
        end
    end

    return 0
end

local function GetPercentHealth(source)
    source = source or Player
    return ((source:Health() / source:MaxHealth()) * 100)
end

local function GetPercentMana(source)
    source = source or Player
    return ((source:Mana() / source:MaxMana()) * 100)
end

local function GetReductionDamage(target)
    local multiplier = 1
    for i, userdata in pairs(target:Buffs()) do
        name = userdata.NameHash

        --increased damage
        if name == game.FNV("vladimirhemoplaguedebuff") then
            multiplier = multiplier * 1.10
        elseif name == game.FNV("VladimirHemoplagueDebuff") then
            multiplier = multiplier * 1.10
        elseif name == game.FNV("itemphantomdancerdebuff") then
            multiplier = multiplier * 0.88
        elseif name == game.FNV("itemsmitechallenge") then
            multiplier = multiplier * 0.8
        elseif name == game.FNV("ferocioushowl") then
            multiplier = multiplier * (0.55 - (target:GetSpellBook():GetSpellSlotByID(SpellSlot.R):Level() * 0.1))
        elseif name == game.FNV("GarenW") then --first 0.75 seconds reduces 60%
            multiplier = multiplier * 0.7
        elseif name == game.FNV("gragaswself") then
            multiplier = multiplier * (0.92 - (target:GetSpellBook():GetSpellSlotByID(SpellSlot.W):Level() * 0.02))
        elseif name == game.FNV("moltenshield") then
            multiplier = multiplier * (0.90 - (target:GetSpellBook():GetSpellSlotByID(SpellSlot.E):Level() * 0.06))
        elseif name == game.FNV("meditate") then
            multiplier = multiplier * (0.55 - (target:GetSpellBook():GetSpellSlotByID(SpellSlot.W):Level() * 0.05))
        elseif name == game.FNV("sonapassivedebuff") then
            multiplier = multiplier * (0.75 - (0.04 * (target:TotalAttackDamage() / 100)))
        elseif name == game.FNV("malzaharpassiveshield") then
            multiplier = multiplier * 0.1
        elseif name == game.FNV("warwicke") then
            multiplier = multiplier * (0.70 - (target:GetSpellBook():GetSpellSlotByID(SpellSlot.E):Level() * 0.05))
        elseif name == game.FNV("ireliawdefense") then
            multiplier = multiplier * ((0.60 - (target:GetSpellBook():GetSpellSlotByID(SpellSlot.W):Level() * 0.05)) - (0.07 * (target:TotalAbilityPower() / 100)))
        end

        if name == game.FNV("BlitzcrankManaBarrierCD") or name == game.FNV("ManaBarrier") then
            multiplier = multiplier - target:Mana() / 2
        end
    end

    --decreased damage
    if HasBuff("SummonerExhaust", Player) then
        multiplier = multiplier * 0.6
    end

    return multiplier
end

local function CanPlayerMove(obj)
    local obj = obj or Player
    for i, buff in pairs(obj:Buffs()) do
        if hard_cc[buff.Type] then
            return false
        end
    end
    return true
end

local function IsReady(SpellSlot)
    if Player:GetSpellBook():GetSpellSlotByID(SpellSlot):IsReady() then 
        return true 
    end 
    return false
end

local function IsInRange(range, p1, p2)
    if (p1:DistanceSquared(p2) <= range*range) then
        return true
    end
    return false
end

local function IsInAutoAttackRange(target, source)
    source = source or Player
    local range = source:RealAttackRange()

    if (target:Position():DistanceSquared(source:Position()) <= range * range) then
        return true
    end
    return false
end

local function GetShieldedHealth(damageType, target)
    local shield = 0
    if damageType:find"AD" then
      shield = target:PhysicalShield()
    elseif damageType:find"AP" then
      shield = target:MagicalShield()
    elseif damageType:find"ALL" then
      shield = target:AllShield() + (target:ChampionName() == "Yasuo" and target:Mana() == target:MaxMana() and yasuoShield[target:Level()] or 0)
      + (target:ChampionName() == "Blitzcrank" and (not HasBuff("blitzcrankmanabarriercd", target) and not HasBuff("manabarrier", target) and target:Mana() / 2) or 0)
    end

    return target:Health() + shield
end

--"morganae", "itemmagekillerveil", "bansheesveil","sivire",
local function HasShield(target)
    for i, buff in pairs(target:Buffs()) do
        if buff.NameHash == game.FNV("morganae") then
            return treu
        elseif buff.NameHash == game.FNV("sivire") then
            return true
        elseif buff.Type == 4 then
            return true
        end
    end

    return false
end

local function IsUnderEnemyTurret(posti, range)
    range = range or 950

    for i, tower in pairs(game.turrets) do
        if tower and tower:IsValidTarget() and tower:Health() > 5 and tower:Team() ~= Player:Team() then
            if tower:Position():DistanceSquared(posti) < range * range then
                return true
            end
        end
    end

    return false
end

local function IsUnderAllyTurret(posti)
    for i, tower in pairs(game.turrets) do
        if tower and tower:IsValidTarget() and tower:Health() > 5 and tower:Team() == Player:Team() then
            if tower:Position():DistanceSquared(posti) < 980 * 980 then
                return true
            end
        end
    end

    return false
end

local function closeToObject(unit, list_obj, range)
    unit = unit or Player:Position()
    list_obj = list_obj or game.enemy_heros
    range = range or Player:RealAttackRange()

    local closeTarget = nil
    local distance = math.huge

    for i, target in pairs(list_obj) do
        if (target and target:IsAlive() and target:IsVisible() and target:IsTargetable()) then
            local distanceToObj = unit:Distance(target:Position())
            if distanceToObj < distance and unit:Distance(target:Position()) <= range then
                closeTarget = target
                distance = distanceToObj
            end
        end
    end

    return closeTarget
end

local function GetEnemyHeroesInRange(position, range, netTarget)
	local result = { }

	for _, enemy in pairs(game.enemy_heros) do
		if enemy and enemy:IsValidTarget() and enemy:Position():Distance(position) <= range
		and (not netTarget or (netTarget:NetworkID() ~= enemy:NetworkID())) then
			table.insert(result, enemy)
		end
	end

	return result
end

local function GetAllyHeroesInRange(position, range)
    local result = { }

	for _, enemy in pairs(game.ally_heros) do
		if enemy and enemy:IsValidTarget() and enemy:Position():DistanceSquared(position) <= range*range
		and Player:NetworkID() ~= enemy:NetworkID() then
			table.insert(result, enemy)
		end
	end

	return result
end

local function GetEnemyMinionsInRange(position, range)
    local result = { }

	for _, enemy in pairs(game.enemy_minions) do
		if enemy and enemy:Health() > 5 and enemy:IsValidTarget() and enemy:IsAlive() and enemy:ServerPosition():DistanceSquared(position) <= range*range then
			table.insert(result, enemy)
		end
	end

	return result
end

local function GetEnemyNeutralInRange(position, range)
    local result = { }

	for _, enemy in pairs(game.jungles) do
		if enemy and enemy:IsValidTarget() and enemy:Position():DistanceSquared(position) <= range*range then
			table.insert(result, enemy)
		end
	end

	return result
end

local function VectorPointProjectionOnLineSegment(v1, v2, v)
    local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y)
    local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2)
    local pointLine = Vector2(ax + rL * (bx - ax), ay + rL * (by - ay))
    local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
    local isOnSegment = rS == rL
    local pointSegment = isOnSegment and pointLine or Vector2(ax + rS * (bx - ax), ay + rS * (by - ay))

    return pointSegment, pointLine, isOnSegment
end

local function ProjectOn(point, segmentStart, segmentEnd)
	local cx = point.x
    local cy = point.z

    local ax = segmentStart.x
    local ay = segmentStart.z

    local bx = segmentEnd.x
    local by = segmentEnd.z

    local mathPowX = (bx - ax) ^ 2
    local mathPowY = (by - ay) ^ 2

    local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / (mathPowX +  mathPowY)
    local pointLine = Vector3(ax + rL * (bx - ax), 0, ay + rL * (by - ay))

    if (rL < 0) then
        rS = 0;
    elseif (rL > 1) then
        rS = 1;
    else
        rS = rL;
    end

    if rS == rL then
    	isOnSegment = true
    	pointSegment = pointLine
    else
    	isOnSegment = false
    	pointSegment = Vector3(ax + rS * (bx - ax), 0, ay + rS * (by - ay))
    end

    return isOnSegment, pointSegment, pointLine
end

local function GetEnemyForKill(range)
    range = range or Player:RealAttackRange()

    local result = { }

    for i, target in pairs(game.enemy_heros) do
        if target and target:IsValidTarget() and Player:Position():Distance(target:Position()) <= range then
            table.insert(result, target)
        end
    end

    table.sort(result, function (a, b)
        return a:Health() < b:Health()
    end)

    return result
end

local function GetMinions(range, pos)
    local result = { }

    for _, object in pairs(game.enemy_minions) do
        if object and object:IsValidTarget() and pos:Distance(object:Position()) <= range then
            table.insert(result, object)
        end
    end

    table.sort(result, function(a, b) return a:Health() < b:Health() end)
    return result
end

local function GetLastHitMinions(range, pos, delay)
    delay = delay or 0.25
    local result = { }

    for _, object in pairs(game.enemy_minions) do
        if object and object:IsValidTarget() and pos:Distance(object:Position()) <= range and game.orbwalker:GetHealthPrediction(object, 0.25, 0.25) > 0 then
            table.insert(result, object)
        end
    end

    table.sort(result, function(a, b) return a:Health() < b:Health() end)
    return result
end

local function BestJungleClear(range)
    local bestTarget = { }

    for _, obj in pairs(game.jungles) do
		if obj and obj:IsValidTarget() and Player:Position():Distance(obj:Position()) <= range then
            if Player:GetAutoAttackDamage(obj) * 2 <= GetShieldedHealth("AD", obj) then
                table.insert(bestTarget, obj)
            end
		end
	end

    --table.sort(bestTarget, function(a, b) return a:MaxHealth() < b:MaxHealth() end)

    return bestTarget
end

local function GetPhysicalReduction(target, source)
    source = source or Player
    if (target.armor == 0) then
        return 1
    end

    local armor = (target:BonusArmor() * source:PercentBonusArmorPenetration() + target:Armor() - target:BonusArmor()) * source:PercentArmorPenetration()
    if (source:GetType() ~= Player:GetType()) then
        armor = (target:BonusArmor() * 1 + target:Armor() - target:BonusArmor()) * 1
    end

    local lethality = source:GetType() == Player:GetType() and (source:PhysicalLethality() * (.6 + .4 * source:Level() / 18)) or 0
    return armor >= 0 and (100 / (100 + math.max(armor - lethality, 0))) or 1
end

local function getMagicalReduction(target, source)
    source = source or Player
    local magicResist = target:BonusMagicDamage() * source:PercentMagicPenetration() - source:FlatMagicPenetration()
    return magicResist >= 0 and (100 / (100 + magicResist)) or (2 - (100 / (100 - magicResist)))
end

local function CalculatePhysicalDamage(target, source, ad_dmg)
    assert(target, "calculatePhysicalDamage: target is nil")
    if type(source) == "number" then
        source, ad_dmg = ad_dmg, source
    end

    source = source or Player
    return (ad_dmg or source:TotalAttackDamage()) * GetPhysicalReduction(target, source)
end

local function CalculateMagicalDamage(target, source, ap_dmg)
    assert(target, "calculateMagicalDamage: target is nil")
    if type(source) == "number" then
        source, ap_dmg = ap_dmg, source
    end

    source = source or Player
    return (ap_dmg or source:TotalAbilityPower()) * getMagicalReduction(target, source)
end


local function RotateAroundPoint(v1, v2, angle)
    local cos, sin = math.cos(angle), math.sin(angle)
    local x = ((v1.x - v2.x) * cos) - ((v2.z - v1.z) * sin) + v2.x
    local z = ((v2.z - v1.z) * cos) + ((v1.x - v2.x) * sin) + v2.z
    return Vector3(x, v1.y, z or 0)
end

local function CirclePoints(CircleLineSegmentN, radius, position)
    local points = {}
    for i = 1, CircleLineSegmentN, 1 do
        local angle = i * 2 * math.pi / CircleLineSegmentN
        local point = Vector3(position.x + radius * math.cos(angle), position.y, position.z + radius * math.sin(angle));
        table.insert(points, point)
    end
    return points
end

local function InAARange(point)
    local orbCombat = game.orbwalker:GetTarget()

    if (orbCombat and orbCombat:GetType() == Player:GetType()) then
        return point:Distance(orbCombat:Position()) <= Player:RealAttackRange()
    else
        return #GetEnemyHeroesInRange(point, Player:RealAttackRange()) > 0
    end
end

local function GetWallPosition(target, range)
    range = range or 400

    for i= 0, 360, 45 do
        local angle = i * math.pi/180
        local targetPosition = target:Position()
        local targetRotated = Vector3(targetPosition.x + range, targetPosition.y, targetPosition.z)
        local pos = RotateAroundPoint(targetRotated, targetPosition, angle)

        if pos and game.IsWall(pos) and targetPosition:Distance(pos) < range then
            return pos, pos:Distance(Player:Position())
        end
    end

    return nil
end

return {
    IsReady = IsReady,
    IsInAutoAttackRange = IsInAutoAttackRange,
    IsInRange = IsInRange,

    ExecuteDelay = ExecuteDelay,
    DelayAction = DelayAction,

    GetShieldedHealth = GetShieldedHealth,
    HasBuff = HasBuff,
    GetBuffValid = GetBuffValid,
    GetBuffTypeValid = GetBuffTypeValid,
    GetBuffStacks = GetBuffStacks,
    GetBuffStartTime = GetBuffStartTime,
    GetBuffEndTime = GetBuffEndTime,

    interrupt_spells = interrupt_spells,

    GetPercentHealth = GetPercentHealth,
    GetPercentMana = GetPercentMana,

    HasShield = HasShield,
    IsUnderEnemyTurret = IsUnderEnemyTurret,
    isUnderEnemyTurret = IsUnderEnemyTurret, --lower
    IsUnderAllyTurret = IsUnderAllyTurret,
    closeToObject = closeToObject,

    CanPlayerMove = CanPlayerMove,

    GetEnemyHeroesInRange = GetEnemyHeroesInRange,
    GetEnemyMinionsInRange = GetEnemyMinionsInRange,
    GetEnemyNeutralInRange = GetEnemyNeutralInRange,
    GetAllyHeroesInRange = GetAllyHeroesInRange,
    GetMinions = GetMinions,
    GetLastHitMinions = GetLastHitMinions,
    BestJungleClear = BestJungleClear,

    ProjectOn = ProjectOn,
    GetEnemyForKill = GetEnemyForKill,
    BuffType = BuffType,

    RotateAroundPoint = RotateAroundPoint,
    CalculatePhysicalDamage = CalculatePhysicalDamage,
    CalculateMagicalDamage = CalculateMagicalDamage,

    InAARange = InAARange,
    CirclePoints = CirclePoints, 

    VectorPointProjectionOnLineSegment = VectorPointProjectionOnLineSegment, 
    GetWallPosition = GetWallPosition
}
