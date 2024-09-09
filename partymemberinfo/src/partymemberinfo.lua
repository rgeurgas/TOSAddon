local addonName = 'partymemberinfo'

local acutil = require('acutil')
local loaded = false

_G['ADDONS'] = _G['ADDONS'] or {};
local PartyMemberInfo = _G["ADDONS"][addonName] or {};

function PARTYMEMBERINFO_GET_FILENAME()
	return "../wbrextend.txt";
end

function PARTYMEMBERINFO_LOAD()
	for line in io.lines(PARTYMEMBERINFO_GET_FILENAME()) do
		local teamName, gs = line:match("([^=]+)=([^=]+)");
		local partyinfoname = PartyMemberInfo[teamName];

		if partyinfoname == nil then
			PartyMemberInfo[teamName] = gs;
		end
	end
end

function MEMBERINFO_ONCLICK(frame, ctrl, argStr, argNum)
	ui.Chat('/memberinfo ' .. argStr);
end

function PartyMemberInfo.new(self)
	local members = {}

	members.nameY = 0
	members.lvboxY = 0

	members.AddPartyMemberInfo = function(self, partyInfoCtrlSet, partyMemberInfo)
		local mapCls = GetClassByType("Map", partyMemberInfo:GetMapID())
		if mapCls ~= nil then
			local location = partyInfoCtrlSet:CreateOrGetControl('richtext', "partymemberinfo_location", 0, 0, 0, 0)
			location:SetText(string.format("{s12}{ol}[%s-%d]", mapCls.Name, partyMemberInfo:GetChannel() + 1))
			location:Resize(100, 20)
			location:SetOffset(10, 0)
			location:ShowWindow(1)
		end

		local teamName = partyMemberInfo:GetName()

		if PartyMemberInfo[teamName] ~= nil then
			local gearscore = partyInfoCtrlSet:CreateOrGetControl('richtext', "partymemberinfo_gearscore", 0, 0, 0, 0)
			gearscore:SetText(string.format("{s12}{ol}GS: %s", PartyMemberInfo[teamName]))
			gearscore:Resize(100, 20)
			gearscore:SetOffset(10, 12)
			gearscore:ShowWindow(1)
		end

		local btn = partyInfoCtrlSet:CreateOrGetControl('button', "btn_" .. teamName, 0, 0, 0, 0);
		tolua.cast(btn, "ui::CButton");
		btn:SetText("Memberinfo");
		btn:SetEventScript(ui.LBUTTONUP, "MEMBERINFO_ONCLICK");
		btn:SetEventScriptArgString(ui.LBUTTONUP, teamName);
		btn:SetUserValue('TEAMNAME', teamName);
		btn:Resize(100, 20)
		btn:SetOffset(100, 5)
		btn:ShowWindow(1)

		local nameObj = partyInfoCtrlSet:GetChild('name_text')
		if (self.nameY == 0) then
			self.nameY = nameObj:GetY()
		end
		nameObj:SetOffset(nameObj:GetX(), self.nameY + 2)

		local lvbox = partyInfoCtrlSet:GetChild('lvbox')
		if (self.lvboxY == 0) then
			self.lvboxY = lvbox:GetY()
		end
		lvbox:SetOffset(lvbox:GetX(), self.lvboxY + 2)
	end

	members.Destroy = function(self)
		if (PartyMemberInfo.instance.UPDATE_PARTYMEMBERINFO_HP ~= nil) then
			UPDATE_PARTYMEMBERINFO_HP = PartyMemberInfo.instance.UPDATE_PARTYMEMBERINFO_HP
		end
	end

	return setmetatable(members, { __index = self })
end

setmetatable(PartyMemberInfo, { __call = PartyMemberInfo.new });

function PARTYMEMBERINFO_ON_INIT(addon, frame)
	if not loaded then
		PARTYMEMBERINFO_LOAD()

		if (PartyMemberInfo.instance.UPDATE_PARTYMEMBERINFO_HP == nil) then
			PartyMemberInfo.instance.UPDATE_PARTYMEMBERINFO_HP = UPDATE_PARTYMEMBERINFO_HP
		end

		UPDATE_PARTYMEMBERINFO_HP = function(partyInfoCtrlSet, partyMemberInfo)
			PartyMemberInfo.instance.UPDATE_PARTYMEMBERINFO_HP(partyInfoCtrlSet, partyMemberInfo)
			if partyMemberInfo:GetMapID() > 0 then
				PartyMemberInfo.instance:AddPartyMemberInfo(partyInfoCtrlSet, partyMemberInfo)
			end
		end

		loaded = true
	end

	acutil.log("PartyMemberInfo loaded!")
end

if (PartyMemberInfo.instance ~= nil) then
	PartyMemberInfo.instance:Destroy()
end
PartyMemberInfo.instance = PartyMemberInfo()
