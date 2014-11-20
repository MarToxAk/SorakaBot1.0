local version = "0.1"

require 'VPrediction'
--[[
SorakaBot Br By MarToxAk
Teste
Funções da Soraka Bot auto Compra 
Auto Up Skill
--]]

-- Personagem a ser checado 
if myHero.charName ~= "Soraka" then return end

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

buyDelay = 100 --padrão 100

--Sistema de Update
local AutoUpdate = true
local SELF = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local URL = "https://raw.githubusercontent.com/MarToxAk/SorakaBot1.0/master/SorakaBr.lua?"..math.random(100)
local UPDATE_TMP_FILE = LIB_PATH.."UNSTmp.txt"
local versionmessage = "<font color=\"#81BEF7\" >Changelog: Adicionado  Auto Farm Fase de teste ^^</font>"

function Update()
  DownloadFile(URL, UPDATE_TMP_FILE, UpdateCallback)
end

function UpdateCallback()
  file = io.open(UPDATE_TMP_FILE, "rb")
  if file ~= nil then
    content = file:read("*all")
    file:close()
    os.remove(UPDATE_TMP_FILE)
    if content then
      tmp, sstart = string.find(content, "local version = \"")
      if sstart then
        send, tmp = string.find(content, "\"", sstart+1)
      end
      if send then
        Version = tonumber(string.sub(content, sstart+1, send-1))
      end
      if (Version ~= nil) and (Version > tonumber(version)) and content:find("--EOS--") then
        file = io.open(SELF, "w")
      if file then
        file:write(content)
        file:flush()
        file:close()
        PrintChat("<font color=\"#81BEF7\" >SorakaBot:</font> <font color=\"#00FF00\">Update feito  com Sucesso: v"..Version..". Por favor Aperte F9 para recarregar.</font>")
      else
        PrintChat("<font color=\"#81BEF7\" >SorakaBot:</font> <font color=\"#FF0000\">Erro no Update da nova versão(v"..Version..")</font>")
      end
      elseif (Version ~= nil) and (Version == tonumber(version)) then
        PrintChat("<font color=\"#81BEF7\" >SorakaBot:</font> <font color=\"#00FF00\">Nenhuma Atualização  Foi encontrada, essa é a Ultima Versão: v"..Version.." </font>")
      end
    end
  end
end
-- Constants (do not change)
local GLOBAL_RANGE = 0
local NO_RESOURCE = 0
local DEFAULT_STARCALL_MODE = 3
local DEFAULT_STARCALL_MIN_MANA = 300 --Starcall will not be cast if mana is below this level
local DEFAULT_NUM_HIT_MINIONS = 3 -- number of minions that need to be hit by starcall before its cast
local DEFAULT_HEAL_MODE = 2
local DEFAULT_HEAL_THRESHOLD = 75 -- for healMode 3, default 75 (75%)
local DEFAULT_INFUSE_MODE = 2 
local DEFAULT_MIN_ALLY_SILENCE = 70 -- percentage of mana nearby ally lolshould have before soraka uses silence
local DEFAULT_ULT_MODE = 2
local DEFAULT_ULT_THRESHOLD = 35 --percentage of hp soraka/ally/team must be at or missing for ult, eg 10 (10%)
local DEFAULT_DENY_THRESHOLD = 75
local DEFAULT_STEAL_THRESHOLD = 60
local MAX_PLAYER_AA_RANGE = 850
local HEAL_DISTANCE = 700
local HL_slot = nil
local CL_slot = nil
local DEFAULT_MANA_CLARITY = 50

-- Recall Check
local isRecalling = false
local RECALL_DELAY = 0.5

-- Auto Level
local levelSequence1 = {_W,_E,_W,_Q,_W,_R,_W,_Q,_W,_Q,_R,_Q,_Q,_E,_E,_R,_E,_E}

--Target Selector
ts = TargetSelector(TARGET_LOW_HP, 1000, DAMAGE_MAGIC, true)


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

--Menu no Game Soraka Bot
function __initMenu()
--Menu do Auto  Ataque Persnoagem inimigos "caso Bot"
Menu = scriptConfig("[" .. _ScriptName .. "] ".. myHero.charName, "SorakaBot"..myHero.charName)
Menu.addsubMenu("[" .. myHero.charName.. "] ativaredesativar", "onoff")
	Menu.onoff.addParam("AutoAtaque", "Ativar Auto Ataque:", SCRIPT_PARAM_ONOFF, true)
	Menu.onoff.addParam("farm", "Limpa a Line:", SCRIPT_PARAM_ONOFF, true)

	--Menu do  Farm Ativa e desativar no menu  acima o tanto de mana que pode usa para farma a line #recomendado Até 70%
Menu:addSubMenu("[" .. myHero.charName.. "] Farm", "farm")
  Menu.farm:addParam("useW", "Enable Q (".. SpellTable[_Q].name ..")", SCRIPT_PARAM_ONOFF, true)
  Menu.farm:addParam("mana", "Min Mana For Lane Clear", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)

Menu.addSubMenu("[" .. myHero.charName.. "] autoBuy", "autoBuy")
  menu.autoBuy:addParam("autoBuy", "Auto compra Itens", SCRIPT_PARAM_ONOFF, true)

Menu.addSubMenu("[" .. myHero.charName.. "] autoLevel", "Auto Level")
  menu.autoLevel:addParam("autoLevel1", "Auto level Skills W E W Foco W Cura", SCRIPT_PARAM_ONOFF, true)
  menu.autoLevel:addParam("", "Embreve Novos Auto Level")

Menu:addSubMenu("[" .. myHero.charName.. "] Combo", "combo")
  Menu.combo:addParam("useQ", "Enable Q (".. SpellTable[_Q].name ..")", SCRIPT_PARAM_ONOFF, true)
  Menu.combo:addParam("useE", "Enable E (".. SpellTable[_E].name ..")", SCRIPT_PARAM_ONOFF, true)
  Menu.combo:addParam("mana", "Min Mana For Combo", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
  Menu.combo:addParam("minE", "Minimum targets to use E", SCRIPT_PARAM_SLICE, 1, 1, 4, 0)


end

--[[function drawMenu()
  Config Menu
  config = scriptConfig("SorakaBot", "SorakaBot")
  config:addParam("enableScript", "Enable Script", SCRIPT_PARAM_ONOFF, true)
  config:addParam("autoBuy", "Auto Buy Items", SCRIPT_PARAM_ONOFF, true)
  config:addParam("autoLevel", "Auto Level", SCRIPT_PARAM_ONOFF, true)
  config:addParam("Farm", "Auto Farming", SCRIPT_PARAM_ONOFF, true)

end
]]--

--Outro em teste 

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

--Function em teste 
function __modes()

    carryKey    = Menu.keys.carry
    harassKey   = Menu.keys.harass
    farmKey     = Menu.keys.farm

    if carryKey     then Combo(Target)  end -- ACTIVATE CARRY MODE
    if harassKey    then Harass(Target) end -- ACTIVATE MIXED MODE
    if farmKey      then Farm()         end -- ACTIVATE CLEAR MODE


    if Target ~= nil and ValidTarget(Target) and not Target.canMove and Menu.misc.e then CastE(target, Menu.prediction.e) end
    
end

--Combo teste pronto
function Combo(target) -- CARRY MODE BEHAVIOUS

    if ValidTarget(target) and target ~= nil and target.type == myHero.type then

        if myManaPct() >= Menu.combo.mana and Menu.combo.useQ then CastQ(target, Menu.prediction.q) end
        if myManaPct() >= Menu.combo.mana and Menu.combo.useE then CastE(target, Menu.prediction.e) end
        

    end
    

--Fuction Farm Para Farming  Minions usando o Speel "Q"
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

-- obCreatObj
function OnCreateObj(obj)
  -- Check if player is recalling and set isrecalling
  if obj.name:find("TeleportHome") then
    if GetDistance(player, obj) <= 70 then
      isRecalling = true
    end
  end
end

-- OnDeleteObj
function OnDeleteObj(obj)
  if obj.name:find("TeleportHome") then
    -- Set isRecalling off after short delay to prevent using abilities once at base
    DelayAction(function() isRecalling = false end, RECALL_DELAY)
  end
end

--[[ OnTick ]]--
function OnTick()
  ts:update()
  --if(ts.target) then print(ts.target.charName) end
  -- Auto Level
  if config.autoLevel and player.level > GetHeroLeveled() then
    LevelSpell(levelSequence1[GetHeroLeveled() + 1])
  end

  -- Recall Check
  if (isRecalling) then
    return -- Don't perform recall canceling actions
  end

  if config.autoBuy then buy() end 

end

function OnLoad()
  player = GetMyHero()
  __initMenu()
  startingTime = GetTickCount()
  
  VP = VPrediction()
  
  if AutoUpdate then
    Update()
  end
end
