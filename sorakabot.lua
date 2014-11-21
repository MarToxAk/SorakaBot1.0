

if myHero.charName ~= "Soraka" then return end

local _ScriptName = "Soraka Bot"
local Version = 0.1
local _ScriptAuthor = "MarTox"

--Update
local TESTVERSION = false
local AUTOUPDATE = true
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/MarToxAk/SorakaBot1.0/master/sorakabot.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH.."sorakabot.lua"
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

local function AutoupdaterMsg(msg) print("<font color=\"#6699ff\"><b>Soraka:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if AUTOUPDATE then
  local ServerData = GetWebResult(UPDATE_HOST, "/MarToxAk/SorakaBot1.0/master/sorakabot.version")
  if ServerData then
    ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil
    if ServerVersion then
      if tonumber(version) < ServerVersion then
        AutoupdaterMsg("New version available"..ServerVersion)
        AutoupdaterMsg("Updating, please don't press F9")
        DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () AutoupdaterMsg("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3)
      else
        AutoupdaterMsg("You have got the latest version ("..ServerVersion..")")
      end
    end
  else
    AutoupdaterMsg("Error downloading version info")
  end
end

local orbwalker = "SOW"

local levelSequence = {_W,_E,_Q,_W,_W,_R,_W,_E,_W,_E,_R,_E,_E,_Q,_Q,_R,_Q,_Q}

function SendMessage(msg)

    PrintChat("<font color='#7D1935'><b>[" .. _ScriptName .. " " .. myHero.charName .. "]</b> </font><font color='#FFFFFF'>" .. tostring(msg) .. "</font>")

end



local Recalling

function OnLoad()

    __initVars()
    __load()
    __initLibs()
    __initMenu()
    __initPriorities()
    __initOrbwalkers()

end
--acara so  foda
shopList = {
  3301,-- coin
  3340,--ward trinket
  1004,1004,--Faerie Charm
  3028,
  --1028,--Ruby Crystal
  --2049,--Sighstone
  3096,--Nomad Medallion
  3114,--Forbidden Idol
  3069,--Talisman of Ascension
  1001,--Boots 
  3108,--Fiendish Codex
  3174,--Athene's Unholy Grail
  --2045,--Ruby Sighstone
  1028,--Ruby Crystal
  1057,--Negatron Cloak
  3105,--Aegis of Legion
  3158,--Ionian Boots
  1011,--Giants Belt
  3190,--Locket of Iron Solari
  3143,--Randuins
  3275,--Homeguard
  1058,--Large Rod
  3089--Rabadon
}

nextbuyIndex = 1
lastBuy = 0

buyDelay = 100 --default 100


--digidin
--Fuction nova
function buy()
  if InFountain() or player.dead then
      -- Item purchases
    if GetTickCount() > lastBuy + buyDelay then
      if GetInventorySlotItem(shopList[nextbuyIndex]) ~= nil then
        --Last Buy successful
        nextbuyIndex = nextbuyIndex + 1
      else
        --Last Buy unsuccessful (buy again)
        --[[local p = CLoLPacket(0x82)
        p.dwArg1 = 1
        p.dwArg2 = 0
        p:EncodeF(myHero.networkID)
        p:Encode4(shopList[nextbuyIndex])
        SendPacket(p)           
        lastBuy = GetTickCount()]]
        lastBuy = GetTickCount()
        BuyItem(shopList[nextbuyIndex])
      end
    end
  end
end
--fim da fuction nova

function OnTick()

    -- Auto Level
  if Menu.bot.autoLevel and player.level > GetHeroLeveled() then
    LevelSpell(levelSequence[GetHeroLeveled() + 1])
  end

  if Menu.bot.autoBuy then buy() end 

    if not _G.SorakaPred_Loaded then return end

    __modes()
    __update()

end 

function OnUnload()

    if not _G.SorakaPred_Loaded then return end

end

function OnDraw()

    if not _G.SorakaPred_Loaded then return end

    __draw()

end

function OnProcessSpell(unit, spell)

    if not _G.SorakaPred_Loaded then return end

end

function OnCreateObj(obj)

    if not _G.SorakaPred_Loaded then return end

end

function OnDeleteObj(obj)

    if not _G.SorakaPred_Loaded then return end

end

-- INITIALIZE GLOBAL VARIABLES --
function __initVars()

    -- SCRIPT GLOBALS
    _G.SorakaPred_Loaded = false
    

    SKILLSHOT_LINEAR, SKILLSHOT_CONE, SKILLSHOT_CIRCULAR, ENEMY_TARGETED, SELF_TARGETED, MULTI_TARGETED, UNIDENTIFIED = 0, 1, 2, 3, 4, 5, -1

local Ranges = { AA = 550 }
    -- TABLE OF HERO SKILLS
    SpellTable = {
    
        [_Q] = {

            id = "q",
            name = myHero:GetSpellData(_Q).name,
            ready = false,
            range = 900,
            width = 110,
            speed = 1500,
            delay = 0.5,
            sType = SKILLSHOT_CIRCULAR
        },


       [_W] = {

            id = "w",
            name = myHero:GetSpellData(_E).name,
            ready = false,
            range = 450,
            width = 0,
            speed = 1000,
            delay = 0.5,
            sType = UNIDENTIFIED

        },


        [_E] = {

            id = "e",
            name = myHero:GetSpellData(_E).name,
            ready = false,
            range = 875,
            width = 25,
            speed = 2000,
            delay = .5,
            sType = SKILLSHOT_CIRCULAR,

        },

       [_R] = {

            id = "r",
            name = myHero:GetSpellData(_R).name,
            ready = false,
            range = nil,
            width = nil,
            speed = nil,
            delay = .5,
            sType = UNIDENTIFIED,

        }


    }

  

    -- TABLE FOR ARRANGING TARGETING PRIORITIES
    PriorityTable = {
        AP = {
            "Annie", "Ahri", "Akali", "Anivia", "Annie", "Azir", "Brand", "Cassiopeia", "Diana", "Evelynn", "FiddleSticks", "Fizz", "Gragas", "Heimerdinger", "Karthus",
            "Kassadin", "Katarina", "Kayle", "Kennen", "Leblanc", "Lissandra", "Lux", "Malzahar", "Mordekaiser", "Morgana", "Nidalee", "Orianna",
            "Ryze", "Sion", "Swain", "Syndra", "Teemo", "TwistedFate", "Veigar", "Viktor", "Vladimir", "Xerath", "Ziggs", "Zyra", "Velkoz"
        },

        Support = {
            "Alistar", "Blitzcrank", "Braum", "Janna", "Karma", "Leona", "Lulu", "Nami", "Nunu", "Sona", "Soraka", "Taric", "Thresh", "Zilean", "Braum"
        },

        Tank = {
            "Amumu", "Chogath", "DrMundo", "Galio", "Hecarim", "Malphite", "Maokai", "Nasus", "Rammus", "Sejuani", "Nautilus", "Shen", "Singed", "Skarner", "Volibear",
            "Warwick", "Yorick", "Zac"
        },

        AD_Carry = {
            "Ashe", "Caitlyn", "Corki", "Draven", "Ezreal", "Graves", "Jayce", "Jinx", "KogMaw", "Lucian", "MasterYi", "MissFortune", "Pantheon", "Quinn", "Shaco", "Sivir",
            "Talon","Tryndamere", "Tristana", "Twitch", "Urgot", "Varus", "Vayne", "Yasuo", "Zed"
        },

        Bruiser = {
            "Aatrox", "Darius", "Elise", "Fiora", "Gangplank", "Garen", "Irelia", "JarvanIV", "Jax", "Khazix", "LeeSin", "Nocturne", "Olaf", "Poppy",
            "Renekton", "Rengar", "Riven", "Rumble", "Shyvana", "Trundle", "Udyr", "Vi", "MonkeyKing", "XinZhao"
        }
    }

end

-- LOAD SEQUENCE -- SCRIPT LOADUP - SEND START MESSAGES AND ARRANGE GLOBALS
function __load()

    SendMessage("SorakaPred by Isexcats")
    SendMessage("Script version v" .. Version .. " loaded for " .. myHero.charName)

   

end

-- LIBRARY INITIALIZATION --
function __initLibs()

    VP = VPrediction()
    PROD = Prodiction

    enemyMinions = minionManager(MINION_ENEMY, GetMaxRange(), myHero, MINION_SORT_HEALTH_ASC) -- MINION MANAGER FOR LANE CLEAR

end

function __initMenu()

    Menu = scriptConfig("[" .. _ScriptName .. "] " .. myHero.charName, "SorakaPred"..myHero.charName)
    
    Menu:addSubMenu("[" .. myHero.charName.. "] Menu Auto Bot", "bot")
      Menu.bot:addParam("autoBuy", "Auto Buy Items", SCRIPT_PARAM_ONOFF, true)
      Menu.bot:addParam("autoLevel", "Auto Level", SCRIPT_PARAM_ONOFF, true)

    Menu:addSubMenu("[" .. myHero.charName.. "] Keybindings", "keys")
        Menu.keys:addParam("carry", "Carry Mode Key:", SCRIPT_PARAM_ONOFF, true, 32)
        Menu.keys:addParam("harass", "Harass Mode Key:", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('C'))
        Menu.keys:addParam("farm", "Lane Clear Mode Key:", SCRIPT_PARAM_ONOFF, true)


    Menu:addSubMenu("[" .. myHero.charName.. "] Combo", "combo")
        Menu.combo:addParam("useQ", "Enable Q (".. SpellTable[_Q].name ..")", SCRIPT_PARAM_ONOFF, true)
        Menu.combo:addParam("useE", "Enable E (".. SpellTable[_E].name ..")", SCRIPT_PARAM_ONOFF, true)
        Menu.combo:addParam("mana", "Min Mana For Combo", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
        Menu.combo:addParam("minE", "Minimum targets to use E", SCRIPT_PARAM_SLICE, 1, 1, 4, 0)

    Menu:addSubMenu("[" .. myHero.charName.. "] Harass", "harass")
        Menu.harass:addParam("useQ", "Enable Q (".. SpellTable[_Q].name ..")", SCRIPT_PARAM_ONOFF, true)
        Menu.harass:addParam("useE", "Enable E (".. SpellTable[_E].name ..")", SCRIPT_PARAM_ONOFF, true)
        Menu.harass:addParam("minE", "Minimum targets to use E", SCRIPT_PARAM_SLICE, 1, 1, 4, 0)
     
        Menu.harass:addParam("mana", "Min Mana For Harass", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)

    Menu:addSubMenu("[" .. myHero.charName.. "] Farm", "farm")
        Menu.farm:addParam("useW", "Enable Q (".. SpellTable[_Q].name ..")", SCRIPT_PARAM_ONOFF, true)
        Menu.farm:addParam("mana", "Min Mana For Lane Clear", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)

    Menu:addSubMenu("[" .. myHero.charName.. "] Ultimate", "ult")
        Menu.ult:addParam("UltCast", "Auto Ultimate On: ", SCRIPT_PARAM_LIST, 3, {"Only Me", "Allies", "Both"})
        Menu.ult:addParam("UltMode", "Auto Ultimate Mode: ", SCRIPT_PARAM_LIST, 1, {"Global", "In Range"})
        Menu.ult:addParam("UltManager", "Ultimate allies under", SCRIPT_PARAM_SLICE, 25, 0, 100, 0)
        Menu.ult:addParam("UltManager2", "Ultimate me under", SCRIPT_PARAM_SLICE, 25, 0, 100, 0)

      Menu:addSubMenu("[" .. myHero.charName.. "] Heal", "heal")        
        Menu.heal:addParam("UseHeal", "Auto Heal Allies", SCRIPT_PARAM_ONOFF, true)
        Menu.heal:addParam("HealManager", "Heal allies under", SCRIPT_PARAM_SLICE, 65, 0, 100, 0)
        Menu.heal:addParam("HPManager", "Don't heal under (my hp)", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)
        
            


 


    Menu:addSubMenu("[" .. myHero.charName .. "] Prediction", "prediction")
        if VIP_USER then
            Menu.prediction:addParam("type", "Prediction:", SCRIPT_PARAM_LIST, 1, {"Prodiction", "VPrediction"})
        else
            Menu.prediction:addParam("type", "Prediction:", SCRIPT_PARAM_INFO, "VPrediction")
        end
        Menu.prediction:addParam("", "", SCRIPT_PARAM_INFO, "")

        for index, skill in pairs(SpellTable) do
            if (skill.sType == SKILLSHOT_LINEAR) or (skill.sType == SKILLSHOT_CONE) or (skill.sType == SKILLSHOT_CIRCULAR) then
                Menu.prediction:addParam(skill.id, string.upper(skill.id) .. " hit chance", SCRIPT_PARAM_SLICE, 2, 1, 3, 0)
            end
        end

  
    Menu:addSubMenu("[" .. myHero.charName.. "] Draw", "draw")
        Menu.draw:addParam("enabled", "Enable All Drawings", SCRIPT_PARAM_ONOFF, true)
        Menu.draw:addParam("drawAA", "Draw AutoAttack Range", SCRIPT_PARAM_ONOFF, true)
        Menu.draw:addParam("drawQ", "Draw ".. SpellTable[_Q].name .." Range", SCRIPT_PARAM_ONOFF, true)
        Menu.draw:addParam("drawW", "Draw ".. SpellTable[_W].name .." Range", SCRIPT_PARAM_ONOFF, true)
        Menu.draw:addParam("drawE", "Draw ".. SpellTable[_E].name .." Range", SCRIPT_PARAM_ONOFF, true)
        Menu.draw:addParam("drawTarget", "Draw Circle on Target", SCRIPT_PARAM_ONOFF, true)
        Menu.draw:addParam("lfc", "Use Lag Free Circles", SCRIPT_PARAM_ONOFF, true)

    Menu:addSubMenu("[" .. myHero.charName.. "] Misc", "misc")
        if VIP_USER then
            Menu.misc:addParam("packet", "Use Packets to Cast Spells", SCRIPT_PARAM_ONOFF, false)
        end
        
    
    TargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, 1250, DAMAGE_MAGIC, true)
    TargetSelector.name = "Swag"
    Menu:addTS(TargetSelector)

end


 --DETECT AND INITIALIZE ORBWALKERS -- USES SIMPLE ORBWALKER IF NONE FOUND
function __initOrbwalkers()

    if _G.Reborn_Loaded then -- SIDA'S AUTO CARRY REBORN LOADED - DISABLE SOW

        SendMessage("SAC:R Detected. Disabling SOW.")
        orbwalker = "SAC"
        Menu.orbwalk.Enabled = false

    elseif _G.MMA_Loaded then -- MARKSMAN'S MIGHTY ASSISTANT LOADED - DISABLE SOW

        SendMessage("MMA Detected. Disabling SOW.")
        orbwalker = "MMA"
        Menu.orbwalk.Enabled = false

    elseif _G.SxOrbMenu then -- SXORBWALK LOADED - DISABLE SOW

        SendMessage("SxOrbwalk Detected. Disabling SOW.")
        orbwalker = "SxOrb"
        Menu.orbwalk.Enabled = false

    end

    if not _G.SorakaPred_Loaded then _G.SorakaPred_Loaded = true end

end

-- ACTIVATE MODES
function __modes()

    carryKey    = Menu.keys.carry
    harassKey   = Menu.keys.harass
    farmKey     = Menu.keys.farm

    if carryKey     then Combo(Target)  end -- ACTIVATE CARRY MODE
    if harassKey    then Harass(Target) end -- ACTIVATE MIXED MODE
    if farmKey      then Farm()         end -- ACTIVATE CLEAR MODE


    if Target ~= nil and ValidTarget(Target) and not Target.canMove and Menu.misc.e then CastE(target, Menu.prediction.e) end
    
end

-- TICK UPDATE --
function __update() -- UPDATE VARIABLES ON TICK
if Menu.heal.UseHeal then --ENABLE AUTO HEAL
            AutoHeal()
        end

        if Menu.ult.UseUlt then --ENABLE AUTO ULT
            AutoUltimate()
        end


    -- SKILLS -- CHECK IF SPELLS ARE READY
    for i in pairs(SpellTable) do
        SpellTable[i].ready = myHero:CanUseSpell(i) == READY
    end
    -- SKILLS --

    

    TargetSelector:update() -- UPDATE TARGETS IN RANGE
    Target = GetTarget() -- GET DESIRED TARGET IN GLOBAL

end


-- SCRIPT FUNCTIONS --

function Combo(target) -- CARRY MODE BEHAVIOUS

    if ValidTarget(target) and target ~= nil and target.type == myHero.type then

        if myManaPct() >= Menu.combo.mana and Menu.combo.useQ then CastQ(target, Menu.prediction.q) end
        if myManaPct() >= Menu.combo.mana and Menu.combo.useE then CastE(target, Menu.prediction.e) end
        

    end

end

function Harass(target) -- HARASS MODE BEHAVIOUR

    if ValidTarget(target) and target ~= nil and target.type == myHero.type and (myManaPct() >= Menu.harass.mana) then

        if Menu.harass.useQ then CastQ(target, Menu.prediction.q) end
        if Menu.harass.useE then CastE(target, Menu.prediction.e) end


    end

end

function Farm() -- LANE CLEAR

    enemyMinions:update()

    if not (myManaPct() < Menu.farm.mana) then
            if SpellTable[_Q].ready then
        
        for _, minion in pairs(enemyMinions.objects) do
            if minion ~= nil and ValidTarget(minion) then
                if Menu.farm.useW and GetDistance(minion) <= SpellTable[_Q].range then
                    local pos, hit = GetBestCircularFarmPos(SpellTable[_Q].range, SpellTable[_Q].width, enemyMinions.objects)
                    if pos ~= nil then
                        if VIP_USER and Menu.misc.packet then -- PACKET CAST Q
                            local packet = GenericSpellPacket(_Q, pos.x, pos.z)
                            Packet("S_CAST", packet):send()
                        else -- NORMAL CAST Q
                            CastSpell(_Q, pos.x, pos.z)
                        end
                    end
                end
            end
        end
            end
    end

end

-- SKILL FUNCTIONS --
function CastQ(target, chance) -- CAST W SKILL

    chance = chance or 2

    local n = 0

    if target ~= nil and ValidTarget(target) and GetDistance(target) <= SpellTable[_Q].range and SpellTable[_Q].ready then

        local aoeCastPos, hitChance, castInfo, nTargets
        if VIP_USER and Menu.prediction.type and Menu.prediction.type == 1 then
            aoeCastPos, castInfo = Prodiction.GetCircularAOEPrediction(target, SpellTable[_Q].range, SpellTable[_Q].speed, SpellTable[_Q].delay, SpellTable[_Q].width, myHero)
            hitChance = tonumber(castInfo.hitchance)
        else
            aoeCastPos, hitChance, nTargets = VP:GetCircularAOECastPosition(target, SpellTable[_Q].delay, SpellTable[_Q].width, SpellTable[_Q].range, SpellTable[_Q].speed, myHero)
        end




        if GetEnemyCountInPos(aoeCastPos, SpellTable[_Q].range) >= n then
            if VIP_USER and Menu.misc.packet then

                local packet = GenericSpellPacket(_Q, aoeCastPos.x, aoeCastPos.z)
                Packet("S_CAST", packet):send()

            else

                CastSpell(_Q, aoeCastPos.x, aoeCastPos.z)

            end
        end

    end

end

function CastE(target, chance) -- CAST W SKILL

    chance = chance or 2

    local n = 0

    if target ~= nil and ValidTarget(target) and GetDistance(target) <= SpellTable[_E].range and SpellTable[_E].ready then

        local aoeCastPos, hitChance, castInfo, nTargets
        if VIP_USER and Menu.prediction.type and Menu.prediction.type == 1 then
            aoeCastPos, castInfo = Prodiction.GetCircularAOEPrediction(target, SpellTable[_Q].range, SpellTable[_Q].speed, SpellTable[_Q].delay, SpellTable[_Q].width, myHero)
            hitChance = tonumber(castInfo.hitchance)
        else
            aoeCastPos, hitChance, nTargets = VP:GetCircularAOECastPosition(target, SpellTable[_E].delay, SpellTable[_E].width, SpellTable[_E].range, SpellTable[_E].speed, myHero)
        end

      if GetMode() == 1 then
            n = Menu.combo.minE
        else
            n = Menu.harass.minE
        end


        if GetEnemyCountInPos(aoeCastPos, SpellTable[_E].range) >= n then
            if VIP_USER and Menu.misc.packet then

                local packet = GenericSpellPacket(_E, aoeCastPos.x, aoeCastPos.z)
                Packet("S_CAST", packet):send()

            else

                CastSpell(_E, aoeCastPos.x, aoeCastPos.z)

            end
        end

    end

end

function AutoHeal()
        for i, ally in ipairs(GetAllyHeroes()) do
            if SpellTable[_W].ready and Menu.heal.UseHeal then
                if (ally.health / ally.maxHealth < Menu.heal.HealManager /100) and (myHero.health / myHero.maxHealth > Menu.heal.HPManager /100) then
                    if GetDistance(ally, myHero) <= SpellTable[_W].range then
                        if Menu.misc.packet then
                            Packet("S_CAST", {spellId = _W, targetNetworkId = ally.networkID}):send()
                            return
                        end

                        if not Menu.misc.packet then
                            CastSpell(_W, ally)
                        end
                    end
                end
            end
        end
    end

function AutoUltimate()
        for i, ally in ipairs(GetAllyHeroes()) do

            ------------------------------
            if ally.dead then return end
            if myHero.dead then return end
            ------------------------------

            if SpellTable[_R].ready and Menu.ult.UseUlt then
                if Menu.ult.UltCast == 2 then
                    if (ally.health / ally.maxHealth < Menu.ult.UltManager /100) then
                        if Menu.ult.UltMode == 1 then
                            if Menu.misc.packet then
                                Packet("S_CAST", {spellId = _R, targetNetworkId = myHero.networkID}):send()
                            elseif not Menu.misc.packet then
                                CastSpell(_R)
                            end
                        elseif Menu.ult.UltMode == 2 then
                            if GetDistance(ally, myHero) <= 1500 then
                                if Menu.misc.packet then
                                    Packet("S_CAST", {spellId = _R, targetNetworkId = myHero.networkID}):send()
                                elseif not Menu.misc.packet then
                                    CastSpell(_R)
                                end
                            end
                        end
                    end
                elseif Menu.ult.UltCast == 1 then
                    if (myHero.health / myHero.maxHealth < Menu.ult.UltManager2 /100) then
                        if Menu.misc.packet then
                            Packet("S_CAST", {spellId = _R, targetNetworkId = myHero.networkID}):send()
                        elseif not Menu.misc.packet then
                            CastSpell(_R)
                        end
                    end
                elseif Menu.ult.UltCast == 3 then
                    if (ally.health / ally.maxHealth < Menu.ult.UltManager /100) or (myHero.health / myHero.maxHealth < Menu.ult.UltManager2 /100) then
                        if Menu.ult.UltMode == 1 then
                            if Menu.misc.packet then
                                Packet("S_CAST", {spellId = _R, targetNetworkId = myHero.networkID}):send()
                            elseif not Menu.misc.packet then
                                CastSpell(_R)
                            end
                        elseif Menu.ult.UltMode == 2 then
                            if GetDistance(ally, myHero) <= 1500 then
                                if Menu.misc.packet then
                                    Packet("S_CAST", {spellId = _R, targetNetworkId = myHero.networkID}):send()
                                elseif not Menu.misc.packet then
                                    CastSpell(_R)
                                end
                            end
                        end
                    end
                end
            end
        end
    end








    -- MAIN DRAW FUNCTION --
function __draw()

    DrawCircles()
    DrawText()
    DrawMisc()

end
-- MAIN DRAW FUNCION --

-- DRAW FUNCTIONS -- 
function DrawCircles() -- CIRCLE DRAWINGS ON SCREEN

    if Menu and Menu.draw and Menu.draw.enabled then

        if Menu.draw.lfc then -- LAG FREE CIRCLES

            if Menu.draw.drawAA then DrawCircleLFC(myHero.x, myHero.y, myHero.z, GetTrueRange(), ARGB(255,255,255,255)) end -- DRAW AA RANGE

            if Menu.draw.drawQ and SpellTable[_Q].ready then DrawCircleLFC(myHero.x, myHero.y, myHero.z, SpellTable[_Q].range, ARGB(255,255,255,255)) end -- DRAW Q RANGE

            if Menu.draw.drawW and SpellTable[_W].ready then DrawCircleLFC(myHero.x, myHero.y, myHero.z, SpellTable[_W].range, ARGB(255,255,255,255)) end -- DRAW W RANGE

            if Menu.draw.drawE and SpellTable[_E].ready then DrawCircleLFC(myHero.x, myHero.y, myHero.z, SpellTable[_E].range, ARGB(255,255,255,255)) end -- DRAW E RANGE

          

            if Menu.draw.drawTarget and GetTarget() ~= nil then DrawCircleLFC(GetTarget().x, GetTarget().y, GetTarget().z, 150, ARGB(255,255,255,255)) end -- DRAW TARGET

        else -- NORMAL CIRCLES

            if Menu.draw.drawAA then DrawCircle(myHero.x, myHero.y, myHero.z, GetTrueRange(), ARGB(255,255,255,255)) end -- DRAW AA RANGE

            if Menu.draw.drawQ and SpellTable[_Q].ready then DrawCircle(myHero.x, myHero.y, myHero.z, SpellTable[_Q].range, ARGB(255,255,255,255)) end -- DRAW Q RANGE

            if Menu.draw.drawW and SpellTable[_W].ready then DrawCircle(myHero.x, myHero.y, myHero.z, SpellTable[_W].range, ARGB(255,255,255,255)) end -- DRAW W RANGE

            if Menu.draw.drawE and SpellTable[_E].ready then DrawCircle(myHero.x, myHero.y, myHero.z, SpellTable[_E].range, ARGB(255,255,255,255)) end -- DRAW E RANGE

            

            if Menu.draw.drawTarget and GetTarget() ~= nil then DrawCircle(GetTarget().x, GetTarget().y, GetTarget().z, 150, ARGB(255,255,255,255)) end -- DRAW TARGET

        end

    end

end

function DrawText() -- TEXT DRAWINGS ON SCREEN

    if Menu and Menu.draw and Menu.draw.enabled then

    end

end

function DrawMisc() -- MISC DRAWINGS LIKE LINES OR SPRITES ON SCREEN

    if Menu and Menu.draw and Menu.draw.enabled then

    end

end
-- DRAW FUNCTIONS --

function GetBestCircularFarmPos(range, radius, objects) -- RETURN: POSITION AND NUMBER OF BEST POSSIBLE W FARM - pos, number
    local bestPos
    local bestHit = 0
    for _, object in ipairs(objects) do
        local hit = CountObjectsNearPos(objects.visionPos or object, range, radius, objects)
        if hit > bestHit then
            bestHit = hit
            bestPos = Vector(object)
            if bestHit == #objects then
                break
            end
        end
    end
    return bestPos, bestHit
end

function __initPriorities()

    if heroManager.iCount < 10 and (GetGame().map.shortName == "twistedTreeline" or heroManager.iCount < 6) then

        SendMessage("Too few champs to arrange priorities.")

    elseif heroManager.iCount == 6 then

        ArrangePrioritiesTT()

    else

        ArrangePriorities()

    end

end

function SetPriority(table, hero, priority)

    for i = 1, #table, 1 do

        if hero.charName:find(table[i]) ~= nil then
            TS_SetHeroPriority(priority, hero.charName)
        end

    end

end

function ArrangePriorities()

    for _, enemy in ipairs(GetEnemyHeroes()) do

        SetPriority(PriorityTable.AD_Carry, enemy, 1)
        SetPriority(PriorityTable.AP, enemy, 2)
        SetPriority(PriorityTable.Support, enemy, 3)
        SetPriority(PriorityTable.Bruiser, enemy, 4)
        SetPriority(PriorityTable.Tank, enemy, 5)

    end

end

function ArrangePrioritiesTT()

    for _, enemy in ipairs(GetEnemyHeroes()) do

        SetPriority(PriorityTable.AD_Carry, enemy, 1)
        SetPriority(PriorityTable.AP, enemy, 1)
        SetPriority(PriorityTable.Support, enemy, 2)
        SetPriority(PriorityTable.Bruiser, enemy, 2)
        SetPriority(PriorityTable.Tank, enemy, 3)

    end

end

-- SUPP PLOX GLOBAL FUNCTIONS --
function myManaPct() return (myHero.mana * 100) / myHero.maxMana end -- RETURN: HERO MANA PERCENTAGE - %number
function myHealthPct() return (myHero.health * 100) / myHero.maxHealth end -- RETURN: HERO HEALTH PERCENTAGE - %number

function getManaPercent(unit) -- RETURN: TARGET MANA PERCENTAGE - %number

    local obj = unit or myHero
    return (onj.mana / obj.maxMana) * 100

end

function getHealthPercent(unit) -- RETURN: TARGET HEALTH PERCENTAGE - %number

    local obj = unit or myHero
    return (obj.health / obj.maxHealth) * 100

end

function GetMaxRange() -- RETURN: MAX RANGE AMONGST HERO SKILLS - number

    return math.max(myHero.range, SpellTable[_Q].range or 0,  SpellTable[_E].range or 0)

end

function GetTrueRange() -- RETURN: REAL AUTO ATTACK RANGE - number
    return myHero.range + GetDistance(myHero, myHero.minBBox)
end

function GetHitBoxRadius(target) -- RETURN: HITBOX RADIUS OF TARGET - number

    return GetDistance(target.minBBox, target.maxBBox)/2

end

function CheckHeroCollision(pos, spell) -- RETURN: WILL THE SKILL COLLIDE - boolean, unit

    for _, enemy in ipairs(GetEnemyHeroes()) do

        if ValidTarget(enemy) and _GetDistanceSqr(enemy) < math.pow(SpellTable[spell].range * 1.5, 2) then -- TODO ADD TARGET MENU HERE

            local projectile, pointLine, onSegment = VectorPointProjectionOnLineSegment(Vector(player), pos, Vector(enemy))

            if (_GetDistanceSqr(enemy, projectile) <= math.pow(VP:GetHitBox(enemy) * 2 + SpellTable[spell].width, 2)) then

                return true, enemy

            end

        end

    end

    return false

end

function CountObjectsNearPos(pos, range, radius, objects) -- RETURN: NUMBER OF OBJECTS - number
    local n = 0
    for i, object in ipairs(objects) do
        if GetDistanceSqr(pos, object) <= radius * radius then
            n = n + 1
        end
    end
    return n
end

function GetEnemyCountInPos(pos, radius)
    local n = 0
    for _, enemy in ipairs(GetEnemyHeroes()) do
        if GetDistanceSqr(pos, enemy) <= radius * radius then n = n + 1 end 
    end
    return n
end

function AlliesInRange(range, point) -- RETURN: NUMBER OF ALLIES - number
    local n = 0
    for _, ally in ipairs(GetAllyHeroes()) do
        if ValidTarget(ally, math.huge, false) and GetDistanceSqr(point, ally) <= range * range then
            n = n + 1
        end
    end
    return n
end

function GetLowestHealthAlly() -- RETURN: ALLY, HEALTH PERCENT - unit, %number

    local leastHp = myHealthPct()
    local leastHpAlly = myHero

    for _, ally in ipairs(GetAllyHeroes()) do
        local allyHpPct = getHealthPercent(ally)
        if allyHpPct <= leastHp and not ally.dead and _GetDistanceSqr(ally) < 700 * 700 then
            leastHp = allyHpPct
            leastHpAlly = ally
        end
    end

    return leastHpAlly, leastHp

end

-- Lag free circles (by barasia, vadash and viseversa)
function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
    radius = radius or 300
  quality = math.max(8,round(180/math.deg((math.asin((chordlength/(2*radius)))))))
  quality = 2 * math.pi / quality
  radius = radius*.92
    local points = {}
    for theta = 0, 2 * math.pi + quality, quality do
        local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
        points[#points + 1] = D3DXVECTOR2(c.x, c.y)
    end
    DrawLines2(points, width or 1, color or 4294967295)
end

function round(num) 
 if num >= 0 then return math.floor(num+.5) else return math.ceil(num-.5) end
end

function DrawCircleLFC(x, y, z, radius, color)
    local vPos1 = Vector(x, y, z)
    local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
    local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
    local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
    if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y }) then
        DrawCircleNextLvl(x, y, z, radius, 1, color, 75) 
    end
end

function GetTarget()

    TargetSelector:update()

    if orbwalker == 'SAC' then

        if _G.AutoCarry and _G.AutoCarry.Crosshair and _G.AutoCarry.Attack_Crosshair and _G.AutoCarry.Attack_Crosshair.target and _G.AutoCarry.Attack_Crosshair.target.type == myHero.type then

            return _G.AutoCarry.Attack_Crosshair.target

        end

    end

    if orbwalker == 'MMA' then

        if _G.MMA_Target and _G.MMA_Target.type == myHero.type then

            return _G.MMA_Target

        end

    end

    if orbwalker == 'SxOrb' then

        if SxOrb and SxOrb:GetTarget() and SxOrb:GetTarget().type == myHero.type then

            return SxOrb:GetTarget()

        end

    end

    return TargetSelector.target

end

function GetMode()

    if carryKey then  return 1 end
    if harassKey then return 2 end
    if farmKey then   return 3 end

    return nil

end

-- SPELL PACKET FUNCTIONS --
function TargetedSpellPacket(spell, target)

    return { spellId = spell, targetNetworkId = target.networkID }

end

function GenericSpellPacket(spell, x, y)

    return { spellId = spell, toX = x, toY = y, fromX = x, fromY = y }

end

function SpellPacket(spell)

    return { spellId = spell }

end
