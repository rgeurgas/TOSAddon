local addonName = 'partyinforeloaded'

local acutil = require('acutil')

_G['ADDONS'] = _G['ADDONS'] or {};
local PartyInfoReloaded = _G["ADDONS"][addonName] or {};
local UPDATE_PARTYINFO_HP_OG = UPDATE_PARTYINFO_HP

function PARTYINFORELOADED_GET_FILENAME()
	return "../wbrextend.txt";
end

function PARTYINFORELOADED_LOAD()
	for line in io.lines(PARTYINFORELOADED_GET_FILENAME()) do
		local teamName, gs = line:match("([^=]+)=([^=]+)");
		local partyinfoname = PartyInfoReloaded[teamName];

		if partyinfoname == nil then
			PartyInfoReloaded[teamName] = gs;
		end
	end
end

function MEMBERINFO_ONCLICK(frame, ctrl, argStr, argNum)
	ui.Chat('/memberinfo ' .. argStr);
end

function PartyInfoReloaded:new(o)
	acutil.log("Creating new obj...")

	o = o or {}
	setmetatable(o, self)
	self.__index = self

	PARTYINFORELOADED_LOAD()

	return o
end

function PartyInfoReloaded:AddPartyInfoReloaded(partyInfoCtrlSet, partyInfoReloaded)
	if partyInfoReloaded:GetMapID() > 0 then
		local mapCls = GetClassByType("Map", partyInfoReloaded:GetMapID())

		if mapCls ~= nil then
			local location = partyInfoCtrlSet:CreateOrGetControl('richtext', "partyinforeloaded_location", 0, 0, 0, 0)
			location:SetText(string.format("{s12}{ol}[%s-%d]", mapCls.Name, partyInfoReloaded:GetChannel() + 1))
			location:Resize(100, 20)
			location:SetOffset(10, 0)
			location:ShowWindow(1)
		end
	end

	local teamName = partyInfoReloaded:GetName()

	if PartyInfoReloaded[teamName] ~= nil then
		local gearscore = partyInfoCtrlSet:CreateOrGetControl('richtext', "partyinforeloaded_gearscore", 0, 0, 0, 0)
		gearscore:SetText(string.format("{s12}{ol}GS: %s", PartyInfoReloaded[teamName]))
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
	btn:SetOffset(100, 0)
	btn:SetAlpha(0)
	btn:ShowWindow(1)

	local nameObj = partyInfoCtrlSet:GetChild('name_text')
	nameObj:SetOffset(nameObj:GetX(), -11)

	local lvbox = partyInfoCtrlSet:GetChild('lvbox')
	lvbox:SetOffset(lvbox:GetX(), 15)
end

function PartyInfoReloaded:Destroy()
	UPDATE_PARTYINFO_HP = UPDATE_PARTYINFO_HP_OG
end

function PARTYINFORELOADED_ON_INIT(addon, frame)
	UPDATE_PARTYINFO_HP = function(partyInfoCtrlSet, partyInfoReloaded)
		UPDATE_PARTYINFO_HP_OG(partyInfoCtrlSet, partyInfoReloaded)
		PartyInfoReloaded.instance:AddPartyInfoReloaded(partyInfoCtrlSet, partyInfoReloaded)
	end

	acutil.log("PartyInfoReloaded loaded!")
end

if (PartyInfoReloaded.instance ~= nil) then
	PartyInfoReloaded.instance:Destroy()
end
PartyInfoReloaded.instance = PartyInfoReloaded:new(nil)
