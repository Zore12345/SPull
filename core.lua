local SPULL_MSG_PREFIX = "SPULL"
RegisterAddonMessagePrefix(SPULL_MSG_PREFIX)
if not RegisterAddonMessagePrefix(SPULL_MSG_PREFIX) then
	print("error unable to register prefix")
end

local defaults = {}
defaults["DefaultPullTime"] = 5
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
--elseif (SPullSettings["Version"]<defaults["Version"]) then
--	progressiveSettingInit();
--end

function progressiveSettingInit()			--finish stub.

end

function showSPullLoadMessage()
	print("|cFF5194ffSPull(|r".. SPullSettings["Version"] .."|cFF5194ff)|r succesfully loaded.");
end

SLASH_SPULL1, SLASH_SPULL2 = '/simplepull', '/spull'
local function slashHandler(msg, editbox)
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
	print("|cFF00AA00You receive loot:|r |cFFFF8000|Hitem:18254::::::::::::|h[HOLY GRAIL]|h.|r");
end
SlashCmdList["HIDDENINTHECODE"] = slashHiddenStuff;

--Message Format for SPull
--  (type)#  -Format to send Pulls to other users.
--    type:
--      i = simple pull  -in this mode the number is pull length.
--      e = serverPull  -in this mode the number is the end server time.
--      y = syncPull  -in this mode the number is pull length.
--  p  -used to ping user to determine time offset for syncpull.
--  r  -used to reply to a ping.
function formatSPull(number)
	if SPullSettings["PullType"]==2 then
		syncPullHandler(number);
	else
		print(SPullSettings["PullType"]==0 and 'i' or 'e'..number);
		sendSPull(SPullSettings["PullType"]==0 and 'i' or 'e'..number);
	end
end

function syncPullHandler(number)		--todo:flush out

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
	name, realm = UnitName("player")
	if realm==nil then
		realm = GetRealmName()
	end
	--if sender~=(name.."-"..realm) then
		print("got " .. message .. " from " .. sender)
	--end
end
eventFrame:SetScript("OnEvent", eventhandler)