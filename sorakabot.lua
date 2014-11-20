if myHero.charName ~="soraka" then return 
end
local version = "0.4"
local TESTVERSION = false
local AUTOUPDATE = true
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/MarToxAk/SorakaBot1.0/master/sorakabot.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = LIB_PATH.."sorakabot.lua"
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

local function AutoupdaterMsg(msg) print("<font color=\"#6699ff\"><b>VPrediction:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") end
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
local DEFAULT_ULT_THRESHOLD = 35 --perceantage of hp soraka/ally/team must be at or missing for ult, eg 10 (10%)
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

--[[ ultMode notes:
1 = ult when Soraka is low/about to die, under ultThreshold% of hp [selfish ult]
2 = ult when ally is low/about to die, under ultThreshold% of hp [lane partner ult]
3 = ult when total missing health of entire team exceeds ultThreshold (ie 50% of entire team health is missing)
-]]

--[[ Main Functions ]]--

-- Soraka performs starcall to help push/farm a lane or harrass enemy champions (or both)


-- Soraka Heals the nearby most injured ally or herself, assumes heal is ready to be used




-- Soraka Infuses the most mana deprived ally donating them mana


--[[ Helper Functions ]]--


--[[ Helper Functions ]]--
-- Return player based on their resource or stat
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
  config = scriptConfig("UnifiedSoraka", "UnifiedSoraka") 

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
