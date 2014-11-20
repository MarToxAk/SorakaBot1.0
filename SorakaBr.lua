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
local versionmessage = "<font color=\"#81BEF7\" >Changelog: Nova versão retirada alguns Bugs</font>"

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
local levelSequence = {_W,_E,_Q,_W,_W,_R,_W,_E,_W,_E,_R,_E,_E,_Q,_Q,_R,_Q,_Q}

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

--draws Menu
function drawMenu()
  -- Config Menu
  config = scriptConfig("SorakaBot", "SorakaBot") 

  config:addParam("enableScript", "Enable Script", SCRIPT_PARAM_ONOFF, true)
  config:addParam("autoBuy", "Auto Buy Items", SCRIPT_PARAM_ONOFF, true)
  config:addParam("autoLevel", "Auto Level", SCRIPT_PARAM_ONOFF, true)

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
    LevelSpell(levelSequence[GetHeroLeveled() + 1])
  end

  -- Recall Check
  if (isRecalling) then
    return -- Don't perform recall canceling actions
  end

  if config.autoBuy then buy() end 

end

function OnLoad()
  player = GetMyHero()
  drawMenu()
  startingTime = GetTickCount()
  
  VP = VPrediction()
  
  if AutoUpdate then
    Update()
  end
end
