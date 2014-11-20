--Inicio Complicado  Mais vamos
local version = "0.1"

--requerido  esse Pluguin
require 'VPrediction'

--Scrip para o  chapm abaixo
if myHero.charName ~="soraka" then return 
end
--fim
--Shop Itens Ainda a modifica
ShopList = {
  3301,
  3340,
  1004,1004,
  3096,
  3114,
  3069,
  1001,
  3108,
  3174,
  1028,
  1057,
  3105,
  3158,
  1011,
  3190,
  3143,
  3275,
  1058,
  3089
}
--Fim do shop itens

nextbuyIndex = 1 
lastBuy = 0

buyDelay = 100 --padrão 100

--sistema de update
local AutoUpdate = true
local SELF = SCRIPT_PATH..GetCurrentEnv() .FILE_NAME
local URL = "https://raw.githubusercontent.com/victorgrego/Bol/master/"..math.random(100)
local UPDATE_TMP_FILE = LIB_PATH.."UNSTmp.txt"
local versionmessage = "<font color=\"#51BEF7\" >Changelog: </font>"

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
        file:writ(content)
        file:flush()
        file:close()
        PrintChat("<font color=\"#81BEF7\" >UnifiedSoraka:</font> <font color=\"#00FF00\">Successfully updated to: v"..Version..". Please reload the script with F9.</font>")
      else
        PrintChat("<font color=\"#81BEF7\" >UnifiedSoraka:</font> <font color=\"#FF0000\">Error updating to new version (v"..Version..")</font>")
      end
      elseif (Version ~= nil) and (Version == tonumber(version)) then
        PrintChat("<font color=\"#81BEF7\" >UnifiedSoraka:</font> <font color=\"#00FF00\">No updates found, latest version: v"..Version.." </font>")
      end
    end
  end
end  


--teste   
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

--recal Check
local isRecalling = false
local RECAL_DELAY = 0.5

-- Auto Level
local levelSequence = {_W,_E,_Q,_W,_W,_R,_W,_E,_W,_E,_R,_E,_E,_Q,_Q,_R,_Q,_Q}

--target Selector
ts = TargetSelector(TARGET_LOW_HP, 1000, DAMAGE_MAGIC, true)

--teste  2 ...
function GetPlayer(team, includeDead, includeSelf, distanceTo, distanceAmount, resource)
  local target = nil

  for i=1, heroManager.iCount do
    local member = heroManager:GetHero(i)

    if member ~= nil and member.type == "AIHeroClient" and member.team == team and (member.dead ~= true or includeDead) then
      if member.charName ~= player.charName or includeSelf then
        if distanceAmount == GLOBAL_RANGE or member:GetDistance(distanceTo) <= distanceAmount then
          if target == nil then target = member end

          if resource == "health" then --least health
            if member.health < target.health then target = member end
          elseif resource == "mana" then --least mana
            if member.mana < target.mana then target = member end
          elseif resource == "AD" then --highest AD
            if member.totalDamage > target.totalDamage then target = member end
          elseif resource == NO_RESOURCE then
            return member -- as any member is eligible
          end
        end
      end
    end
  end

  return target
end


--compra de itens
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

--Draws menu
function drawMenu()
  -- Config Menu
  config = scriptConfig("UnifiedSoraka", "UnifiedSoraka") 

  config:addParam("enableScript", "Enable Script", SCRIPT_PARAM_ONOFF, true)
  config:addParam("autoBuy", "Auto Buy Items", SCRIPT_PARAM_ONOFF, true)
  config:addParam("autoLevel", "Auto Level", SCRIPT_PARAM_ONOFF, true)

end

-- teste 3
function OnCreateObj(obj)
  -- Check if player is recalling and set isrecalling
  if obj.name:find("TeleportHome") then
    if GetDistance(player, obj) <= 70 then
      isRecalling = true
    end
  end
end

--teste 4
function OnDeleteObj(obj)
  if obj.name:find("TeleportHome") then
    -- Set isRecalling off after short delay to prevent using abilities once at base
    DelayAction(function() isRecalling = false end, RECALL_DELAY)
  end
end

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

--teste op esse linhas ficam por ultimo
function OnLoad()
  player = GetMyHero()
  drawMenu()
  startingTime = GetTickCount()
  
  VP = VPrediction()
  
  if AutoUpdate then
    Update()
  end
end
