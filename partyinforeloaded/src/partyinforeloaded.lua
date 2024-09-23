local addonName = 'partyinforeloaded'
local json = require('json_imc')

_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][addonName] = _G['ADDONS'][addonName] or {}
_G['ADDONS'][addonName]['INSTANCE'] = _G['ADDONS'][addonName]['INSTANCE'] or {}
_G['ADDONS'][addonName]['SCORES'] = _G['ADDONS'][addonName]['SCORES'] or {}

local scores = _G['ADDONS'][addonName]['SCORES']
local g = _G['ADDONS'][addonName]['INSTANCE']

function PARTYINFORELOADED_GET_FILENAME()
	return '../partyinforeloaded.txt'
end

function PARTYINFORELOADED_LOAD()
	local f = io.open(PARTYINFORELOADED_GET_FILENAME(), 'r')
	if f ~= nil then
		io.close(f)
	else
		local file, error = io.open(PARTYINFORELOADED_GET_FILENAME(), 'w');
		io.close(file)
	end
	scores = {};

	for line in io.lines(PARTYINFORELOADED_GET_FILENAME()) do
		local teamName, gs = line:match('([^=]+)=([^=]+)')

		if scores[teamName] == nil then
			scores[teamName] = gs
		end
	end
end

function PARTYINFORELOADED_SAVE()
	local file, error = io.open(PARTYINFORELOADED_GET_FILENAME(), 'w');

	if error then
		print('Failed to write partyinforeloaded file!');
		return;
	end

	for teamName, gs in pairs(scores) do
		file:write(teamName .. '=' .. gs .. '\n');
	end

	file:flush();
	file:close();
end

function PARTYINFORELOADED_UPDATE(teamName, charName, gearScore)
	PARTYINFORELOADED_LOAD()
	local addedName = false

	if scores[teamName] == nil then
		scores[teamName] = gearScore
		addedName = true
	elseif tonumber(scores[teamName]) < gearScore then
		scores[teamName] = gearScore
		addedName = true
	end

	if addedName then
		PARTYINFORELOADED_SAVE()
	end
end

function MEMBERINFO_ONCLICK(frame, ctrl, argStr, argNum)
	ui.Chat('/memberinfo ' .. argStr)
end

function g.new(self)
	local members = {}

	members.AddPartyInfoReloaded = function(self, partyInfoCtrlSet, partyInfoReloaded)
		if partyInfoReloaded:GetMapID() > 0 then
			local mapCls = GetClassByType('Map', partyInfoReloaded:GetMapID())

			if mapCls ~= nil then
				local location = partyInfoCtrlSet:CreateOrGetControl('richtext', 'partyinforeloaded_location', 0, 0, 0, 0)
				location:SetText(string.format('{s12}{ol}[%s-%d]', mapCls.Name, partyInfoReloaded:GetChannel() + 1))
				location:Resize(100, 20)
				location:SetOffset(10, 0)
				location:ShowWindow(1)
			end
		end

		local teamName = partyInfoReloaded:GetName()

		if scores[teamName] ~= nil and scores[teamName] ~= nil then
			local gearscore = partyInfoCtrlSet:CreateOrGetControl('richtext', 'partyinforeloaded_gearscore', 0, 0, 0, 0)
			gearscore:SetText(string.format('{s12}{ol}GS: %s', scores[teamName]))
			gearscore:Resize(100, 20)
			gearscore:SetOffset(10, 12)
			gearscore:ShowWindow(1)
		end

		local btn = partyInfoCtrlSet:CreateOrGetControl('button', 'btn_' .. teamName, 0, 0, 0, 0)
		tolua.cast(btn, 'ui::CButton')
		btn:SetText('Memberinfo')
		btn:SetEventScript(ui.LBUTTONUP, 'MEMBERINFO_ONCLICK')
		btn:SetEventScriptArgString(ui.LBUTTONUP, teamName)
		btn:SetUserValue('TEAMNAME', teamName)
		btn:Resize(100, 20)
		btn:SetOffset(100, 0)
		btn:SetAlpha(0)
		btn:ShowWindow(1)

		local nameObj = partyInfoCtrlSet:GetChild('name_text')
		nameObj:SetOffset(nameObj:GetX(), -11)

		local lvbox = partyInfoCtrlSet:GetChild('lvbox')
		lvbox:SetOffset(lvbox:GetX(), 15)
	end

	members.Destroy = function(self)
		if (g.instance.UPDATE_PARTYINFO_HP ~= nil) then
			UPDATE_PARTYINFO_HP = g.instance.UPDATE_PARTYINFO_HP
		end
	end

	return setmetatable(members, { __index = self })
end

setmetatable(g, { __call = g.new });

function PARTYINFORELOADED_ON_INIT(addon, frame)
	if g.instance.UPDATE_PARTYINFO_HP == nil then
		g.instance.UPDATE_PARTYINFO_HP = UPDATE_PARTYINFO_HP
	end

	if g.instance.callback_get_gear_score_ranking == nil then
		g.instance.callback_get_gear_score_ranking = callback_get_gear_score_ranking
	end

	PARTYINFORELOADED_LOAD()

	UPDATE_PARTYINFO_HP = function(partyInfoCtrlSet, partyMemberInfo)
		g.instance.UPDATE_PARTYINFO_HP(partyInfoCtrlSet, partyMemberInfo)
		g.instance:AddPartyInfoReloaded(partyInfoCtrlSet, partyMemberInfo)
	end

	callback_get_gear_score_ranking = function(code, ret_json)
		local dic = json.decode(ret_json)
		local rankList = dic['list']

		for k, v in pairs(rankList) do
			local teamName = v['team_name']
			local charName = v['char_name']
			local value = v['value']

			PARTYINFORELOADED_UPDATE(teamName, charName, value)
		end

		g.instance.callback_get_gear_score_ranking(code, ret_json)
	end
end

if (g.instance ~= nil) then
	g.instance:Destroy()
end
g.instance = g()
