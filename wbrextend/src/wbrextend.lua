local json = require "json_imc"

local curPage = 0
local prevPage = 0

function WBREXTEND_ON_INIT(addon, frame)
	addon:RegisterMsg("GAME_START_3SEC", "WBREXTEND_LOAD");
end

function WBREXTEND_LOAD()
	 local f = io.open(WBREXTEND_GET_FILENAME(),"r")
	 if f~=nil then 
		io.close(f) 
	else 
		local file, error = io.open(WBREXTEND_GET_FILENAME(), "w");
	end
	_G["WBREXTEND"] = {};
	
	for line in io.lines(WBREXTEND_GET_FILENAME()) do
		local teamName,gs = line:match("([^=]+)=([^=]+)");

		local wbrextendname = _G["WBREXTEND"][teamName];

		if wbrextendname == nil then
			wbrextendname = gs;

			_G["WBREXTEND"][teamName] = gs;
		end
	end
end

function WBREXTEND_SAVE()

	local file, error = io.open(WBREXTEND_GET_FILENAME(), "w");

	if error then
		print("Failed to write wbrextend file!");
		return;
	end

	for k,v in pairs(_G["WBREXTEND"]) do
		file:write(k .. "=" .. v .. "\n");
	end

	file:flush();
	file:close();
end

function WBREXTEND_GET_FILENAME()
	return "../addons/wbrextend.txt";
end

function WBREXTEND_UPDATE(teamName,gearScore)
	WBREXTEND_LOAD();
	local addedName = false;
	
	local wbrextendname = _G["WBREXTEND"][teamName];
	
	if wbrextendname == nil then
		wbrextendname = gearScore;
		_G["WBREXTEND"][teamName] = gearScore;
		addedName = true;
	elseif wbrextendname ~= nil and tonumber(wbrextendname) < gearScore then
			_G["WBREXTEND"][teamName] = gearScore;
			addedName = true;
	end
	
	if addedName then
		WBREXTEND_SAVE();
	end
end
	
	
function callback_get_gear_score_ranking(code, ret_json)
	local frame = ui.GetFrame("gear_score_ranking")
	local userListBox = GET_CHILD_RECURSIVELY(frame,"userListBox")
	local playerBox = GET_CHILD_RECURSIVELY(frame,"playerBox")

	local pageText = GET_CHILD_RECURSIVELY(frame, "pageText")

	if code == 404 then		
		ui.SysMsg(ScpArgMsg('{datetime}CantUseFor', 'datetime', ret_json))
		curPage = prevPage -- 페이지 변경에 실패
		return
	end

	if code ~= 200 then
		curPage = prevPage -- 페이지 변경에 실패
		SHOW_GUILD_HTTP_ERROR(code, ret_json, "callback_get_party_info")
		return
	end
		
	local dic = json.decode(ret_json)
	local list_size = dic['size']
	if list_size == 0 then
		curPage = prevPage
		ui.SysMsg(ClMsg('NotExistRankInfo'))
		return
	end

	local myRank = dic["my_rank"]
	local myScore = dic['my_score']
	local rankList = dic["list"]

	userListBox:RemoveAllChild()
	playerBox:RemoveAllChild()
	pageText:SetTextByKey("page", curPage + 1)

    local myHandle = session.GetMyHandle();
	local myGuildIdx = 0
	local myTeamName = info.GetFamilyName(myHandle)
	local myCharName = info.GetName(myHandle)
	local myGuild = GET_MY_GUILD_INFO()
	local myValue = myScore
    if myGuild ~= nil then
		myGuildIdx = myGuild.info:GetPartyID()
	end
	

	local myRankInfoCtrl = playerBox:CreateOrGetControlSet('gearscore_ranking_ranker', 'USER_INFO', 0, 0)
	GEAR_SCORE_RANKING_CREATE_INFO(myRankInfoCtrl, myRank, myGuildIdx, myTeamName, myCharName, myValue)


	for k,v in pairs(rankList) do 
		local guildName = v["guild_name"]
		local teamName = v["team_name"]
		local charName = v["char_name"]
		local guildIdx = v["guild_idx"]
		local type = v["type"]
		local value = v["value"]
		local rank = v["rank"]
		local rankInfoCtrl = userListBox:CreateOrGetControlSet('gearscore_ranking_ranker', 'USER_INFO_'..rank, 0, 37 + (k - 1) * 64)
		
		WBREXTEND_UPDATE(teamName, value);
		
		rank = curPage * 10 + rank
		if teamName == myTeamName and charName == myCharName then
			teamName = "{#0000FF}"..teamName
			charName = "{#0000FF}"..charName
		end
		
		
		GEAR_SCORE_RANKING_CREATE_INFO(rankInfoCtrl, rank, guildIdx, teamName, charName, value)
	end
end



function WEEKLY_BOSS_RANK_UPDATE()
    local frame = ui.GetFrame("induninfo")
    local rankListBox = GET_CHILD_RECURSIVELY(frame, "rankListBox", "ui::CGroupBox");
    rankListBox:RemoveAllChild();
	local found = 0
	curPage = 0
	

    local cnt = session.weeklyboss.GetRankInfoListSize();
    if cnt == 0 then
        return;
    end

    local Width = frame:GetUserConfig("SCROLL_BAR_TRUE_WIDTH");
    if cnt < 6 then
        Width = frame:GetUserConfig("SCROLL_BAR_FALSE_WIDTH");
    end
    
    for i = 1, cnt do
		found = 0
		curPage = 0
        local ctrlSet = rankListBox:CreateControlSet("content_status_board_rank_attribute", "CTRLSET_" .. i,  ui.LEFT, ui.TOP, 0, (i - 1) * 73, 0, 0);
        ctrlSet:Resize(Width, ctrlSet:GetHeight());
        local attr_bg = GET_CHILD(ctrlSet, "attr_bg");
        attr_bg:Resize(Width, attr_bg:GetHeight());

        local rankpic = GET_CHILD(ctrlSet, "attr_rank_pic");
        local attr_rank_text = GET_CHILD(ctrlSet, "attr_rank_text");

        if i <= 3 then
            rankpic:SetImage('raid_week_rank_0'..i)
            rankpic:ShowWindow(1);

            attr_rank_text:ShowWindow(0);
        else
            rankpic:ShowWindow(0);

            attr_rank_text:SetTextByKey("value", i);
            attr_rank_text:ShowWindow(1);
        end

        local damage = session.weeklyboss.GetRankInfoDamage(i - 1);
        local teamname = session.weeklyboss.GetRankInfoTeamName(i - 1);
		
		local btn = rankListBox:CreateOrGetControl('button', "BTN_" .. i, 225,(i - 1) * 73+5,100,25);
        tolua.cast(btn, "ui::CButton");
        btn:SetText("Memberinfo");
        btn:SetEventScript(ui.LBUTTONUP, "MEMBERINFO_ONCLICK");
		btn:SetEventScriptArgString(ui.LBUTTONUP, teamname);
		btn:SetUserValue('TEAMNAME', teamname);
		
		if _G["WBREXTEND"][teamname] ~= nil then
			local txtGs = rankListBox:CreateOrGetControl('button', "txtGs_" .. i, 225,(i - 1) * 73 + 50,100,25);
			tolua.cast(txtGs, "ui::CButton");
			txtGs:SetText("GS: " .. _G["WBREXTEND"][teamname]);
			txtGs:SetEventScript(ui.LBUTTONUP, "GS_ONCLICK");
	
		end
		
        local guildID = session.weeklyboss.GetRankInfoGuildID(i - 1)
        if guildID ~= "0" then
            ctrlSet:SetUserValue("GUILD_IDX",guildID)
            GetGuildEmblemImage("WEEKLY_BOSS_EMBLEM_IMAGE_SET",guildID)
        end

        local name = GET_CHILD(ctrlSet, "attr_name_text", "ui::CRichText");
        name:SetTextByKey("value", teamname);
		

        local value = GET_CHILD(ctrlSet, "attr_value_text", "ui::CRichText");
        value:SetTextByKey("value", STR_KILO_CHANGE(damage));
    
    end

end

function MEMBERINFO_ONCLICK(frame, ctrl, argStr, argNum)
	ui.Chat('/memberinfo ' .. argStr);
end

function GS_ONCLICK(frame, ctrl, argStr, argNum)
	ui.OpenFrame("gear_score_ranking");
end
