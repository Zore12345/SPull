local SPULL_MSG_PREFIX = "SPULL"
RegisterAddonMessagePrefix(SPULL_MSG_PREFIX)
if not RegisterAddonMessagePrefix(SPULL_MSG_PREFIX) then
	print("error unable to register prefix")
end

local defaults = {}
defaults["DefaultPullTime"] = 30
-- 0 = simple pull
-- 1 = server pull
-- 2 = sync pull
defaults["PullType"] = 1
defaults["UseBlizzardTimer"] = false		--currently unimplemented but put feild in here for easy implementation.
defaults["UseRaidWarning"] = false			--currently unimplemented but put feild in here for easy implementation.
defaults["UseVoice"] = false				--currently unimplemented but put feild in here for easy implementation.
defaults["VoiceProfile"] = 'M'				--currently unimplemented but put feild in here for easy implementation.
defaults["Version"] = 0.21					--currently unimplemented but put feild in here for easy implementation.

local SPull = {}
SPull.panel = CreateFrame( "Frame", "SPull", UIParent )
SPull.panel.name = "|cFF5194ffSPull|r"
InterfaceOptions_AddCategory(SPull.panel)
											--finish
											--interface
											--options
											--menu

--if not type(SPullSettings) then
    SPullSettings = defaults				--currently just overides all settings as changes to basic setting format might (and has) broken code.
-- (SPullSettings["Version"]<defaults["Version"]) then
--	print("updating")
--	progressiveSettingInit();
--end

--function progressiveSettingInit()			--finish stub.
--	for key,value in pairs(defaults) do 
--		if(SPullSettings[""..key]==nil) then
--			print(key,value)
--		end
--	end
--end

function showSPullLoadMessage()
	print("|cFF5194ffSPull(|r".. SPullSettings["Version"] .."|cFF5194ff)|r succesfully loaded.");
end


SLASH_SPULL1, SLASH_SPULL2 = '/simplepull', '/spull'
local function slashHandler(msg, editbox)				--implement help and command line modifiers.
	if msg ~= '' then
		local count = tonumber(msg)
		if count ~= nil then
			formatSPull(count)
		elseif string.lower(msg) == 'util' then
			InterfaceOptionsFrame_OpenToCategory(SPull.panel)
		end
	else
		formatSPull(SPullSettings["DefaultPullTime"])
	end
end
SlashCmdList["SPULL"] = slashHandler;

SLASH_HIDDENINTHECODE1 = '/hiddenspullslashcommandthatsreallylong.'
local function slashHiddenStuff(msg, editbox)
	print("|cFF00AA00You receive loot:|r |cFFFF8000|Hitem:18267::::::::::::|h[Holy Grail]|h.|r");
end
SlashCmdList["HIDDENINTHECODE"] = slashHiddenStuff;


SLASH_SERVERTIME1 = '/showservertime'
local function slashServerTimeStuff(msg, editbox)
	local hour,minute = GetGameTime();
	print("Current Server Time is "..string.format("%02i:%02i:%02i",hour,minute, math.floor(serverseconds + .5)));
end
SlashCmdList["SERVERTIME"] = slashServerTimeStuff;

--Message Format for SPull
--  (type)#  -Format to send Pulls to other users.
--    type:
--      i = simple pull  -in this mode the number is pull length.
--      e = serverPull  -in this mode the number is the end server time. formated as hh:mm:ss.
--      y = syncPull  -in this mode the number is pull length. could just use i but prefer to clarify just in case.
--  p  -used to ping user to determine time offset for syncpull.
--  r  -used to reply to a ping.

serverseconds = 0;
previousminute = 0;
local function onUpdate(self,elapsed)
	serverseconds = serverseconds + elapsed;
	local hour,minute = GetGameTime();
	if serverseconds >= 60 then
		serverseconds = serverseconds%60;
	end
	if minute > previousminute and elapsed < 1 then
		previousminute = minute;
		serverseconds=0;
	end
end
 
local f = CreateFrame("Frame")
f:SetScript("OnUpdate", onUpdate)

function formatSPull(number)
	if SPullSettings["PullType"]==2 then
		syncPullHandler(number);
	elseif SPullSettings["PullType"]==0 then
		sendSPull('i'..number);
	else
		local hour,minute = GetGameTime();
		second=0;
		second=serverseconds+number;
		if second>=60 then
			minute=minute+1;
			second=second%60;
		end
		if minute>=60 then
			hour=hour+1;
			minute=minute%60;
		end
		hour=hour%24; --00:00 to 23:59
		sendSPull('e'..string.format("%02i:%02i:%02i",hour,minute, math.floor(second + .5)));
	end
end

function syncPullHandler(number)		--todo:flush out
	party={};
	
end

function sendSPull(message)
	SendAddonMessage(SPULL_MSG_PREFIX, message, "RAID");
end

function sendTargetedSPull(message,target)
	SendAddonMessage(SPULL_MSG_PREFIX, message, "WHISPER", target);
end

if not eventFrame then
	eventFrame = CreateFrame("Frame")
end

eventFrame:RegisterEvent("CHAT_MSG_ADDON")
function eventhandler(self, event, prefix, message, channel, sender)
	if  prefix~=SPULL_MSG_PREFIX then
		return
	end
	name, realm = UnitName("player")
	if realm==nil then
		realm = GetRealmName()
	end
	--if sender~=(name.."-"..realm) then
		print("got [" .. message .. "] from [" .. sender .. "]")
	--end
	startStopwatchCountdown(true,tonumber(string.sub(message, 2, 3)),tonumber(string.sub(message, 5, 6)),tonumber(string.sub(message, 8, 9)))
end
eventFrame:SetScript("OnEvent", eventhandler)

function startStopwatchCountdown(IsServerPull,hours,minutes,seconds)
	if IsServerPull==true then
		local serverhours,serverminutes = GetGameTime();
		hours = hours - serverhours;
		minutes = minutes - serverminutes;
		seconds = seconds - serverseconds;
		if seconds < 0 then
			seconds = seconds + 60;
			minutes = minutes-1;
		end
		if minutes < 0 then
			minutes = minutes + 60;
			hours = hours-1;
		end
		if hours < 0 then
			print("Pull Finished");
			return;
		end
	end
	Stopwatch_StartCountdown(hours, minutes, seconds);
	Stopwatch_Play();
end