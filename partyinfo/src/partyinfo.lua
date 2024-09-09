local addonName = 'partyinfo'

local acutil = require('acutil')
local loaded = false

_G['ADDONS'] = _G['ADDONS'] or {};
local PartyInfo = _G["ADDONS"][addonName] or {};

function PARTYINFO_GET_FILENAME()
	return "../wbrextend.txt";
end

function PARTYINFO_LOAD()
	for line in io.lines(PARTYINFO_GET_FILENAME()) do
		local teamName, gs = line:match("([^=]+)=([^=]+)");
		local partyinfoname = PartyInfo[teamName];

		if partyinfoname == nil then
			PartyInfo[teamName] = gs;
		end
	end
end

function MEMBERINFO_ONCLICK(frame, ctrl, argStr, argNum)
	ui.Chat('/memberinfo ' .. argStr);
end

function PartyInfo.new(self)
	local members = {}

	members.nameY = 0
	members.lvboxY = 0

	members.AddPartyInfo = function(self, partyInfoCtrlSet, partyMemberInfo)
		local mapCls = GetClassByType("Map", partyMemberInfo:GetMapID())
		if mapCls ~= nil then
			local location = partyInfoCtrlSet:CreateOrGetControl('richtext', "partyinfo_location", 0, 0, 0, 0)
			location:SetText(string.format("{s12}{ol}[%s-%d]", mapCls.Name, partyMemberInfo:GetChannel() + 1))
			location:Resize(100, 20)
			location:SetOffset(10, 0)
			location:ShowWindow(1)
		end

		local teamName = partyMemberInfo:GetName()

		if PartyInfo[teamName] ~= nil then
			local gearscore = partyInfoCtrlSet:CreateOrGetControl('richtext', "partyinfo_gearscore", 0, 0, 0, 0)
			gearscore:SetText(string.format("{s12}{ol}GS: %s", PartyInfo[teamName]))
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
		if (PartyInfo.instance.UPDATE_PARTYINFO_HP ~= nil) then
			UPDATE_PARTYINFO_HP = PartyInfo.instance.UPDATE_PARTYINFO_HP
		end
	end

	return setmetatable(members, { __index = self })
end

setmetatable(PartyInfo, { __call = PartyInfo.new });

function PARTYINFO_ON_INIT(addon, frame)
	if not loaded then
		PARTYINFO_LOAD()

		if (PartyInfo.instance.UPDATE_PARTYINFO_HP == nil) then
			PartyInfo.instance.UPDATE_PARTYINFO_HP = UPDATE_PARTYINFO_HP
		end

		UPDATE_PARTYINFO_HP = function(partyInfoCtrlSet, partyMemberInfo)
			PartyInfo.instance.UPDATE_PARTYINFO_HP(partyInfoCtrlSet, partyMemberInfo)
			if partyMemberInfo:GetMapID() > 0 then
				PartyInfo.instance:AddPartyInfo(partyInfoCtrlSet, partyMemberInfo)
			end
		end

		loaded = true
	end

	acutil.log("PartyInfo loaded!")
end

if (PartyInfo.instance ~= nil) then
	PartyInfo.instance:Destroy()
end
PartyInfo.instance = PartyInfo()
