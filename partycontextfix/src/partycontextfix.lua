function SET_PARTYINFO_ITEM(frame, msg, partyMemberInfo, count, makeLogoutPC, leaderFID, isCorsairType, ispipui, partyID)
    if partyID ~= nil and partyMemberInfo ~= nil and partyID ~= partyMemberInfo:GetPartyID() then
        return nil;
    end

	local partyinfoFrame = ui.GetFrame('partyinfo')
	local FAR_MEMBER_FACE_COLORTONE = partyinfoFrame:GetUserConfig("FAR_MEMBER_FACE_COLORTONE")
	local NEAR_MEMBER_FACE_COLORTONE = partyinfoFrame:GetUserConfig("NEAR_MEMBER_FACE_COLORTONE")
	local FAR_MEMBER_NAME_FONT_COLORTAG = partyinfoFrame:GetUserConfig("FAR_MEMBER_NAME_FONT_COLORTAG")
	local NEAR_MEMBER_NAME_FONT_COLORTAG = partyinfoFrame:GetUserConfig("NEAR_MEMBER_NAME_FONT_COLORTAG")

	local mapName = geMapTable.GetMapName(partyMemberInfo:GetMapID());
	local partyMemberName = partyMemberInfo:GetName();
	
	local myHandle = session.GetMyHandle();
	local ctrlName = 'PTINFO_'.. partyMemberInfo:GetAID();
	if mapName == 'None' and makeLogoutPC == false then
		frame:RemoveChild(ctrlName);
		return nil;
	end	

	local partyInfoCtrlSet = frame:CreateOrGetControlSet('partyinfo', ctrlName, 10, count * 100);
		
	UPDATE_PARTYINFO_HP(partyInfoCtrlSet, partyMemberInfo);

	local leaderMark = GET_CHILD(partyInfoCtrlSet, "leader_img", "ui::CPicture");
	leaderMark:SetImage('None_Mark');
	leaderMark:ShowWindow(0)
	-- 머리
	local jobportraitImg = GET_CHILD(partyInfoCtrlSet, "jobportrait_bg", "ui::CPicture");
	local nameObj = partyInfoCtrlSet:GetChild('name_text');
	local nameRichText = tolua.cast(nameObj, "ui::CRichText");	
	local hpGauge = GET_CHILD(partyInfoCtrlSet, "hp", "ui::CGauge");
	local spGauge = GET_CHILD(partyInfoCtrlSet, "sp", "ui::CGauge");
	
	if jobportraitImg ~= nil then
		local jobIcon = GET_CHILD(jobportraitImg, "jobportrait", "ui::CPicture");
		local iconinfo = partyMemberInfo:GetIconInfo();
		local jobCls  = GetClassByType("Job", iconinfo.repre_job)
		if nil ~= jobCls then
			jobIcon:SetImage(jobCls.Icon);
		end
			
		local partyMemberCID = partyInfoCtrlSet:GetUserValue("partyMemberCID")
		if partyMemberCID ~= nil and partyMemberCID ~= 0 and partyMemberCID ~= "None" then
			local jobportraitImg = GET_CHILD(partyInfoCtrlSet, "jobportrait_bg", "ui::CPicture");
			if jobportraitImg ~= nil then
				local jobIcon = GET_CHILD(jobportraitImg, "jobportrait", "ui::CPicture");
				local partyinfoFrame = ui.GetFrame("partyinfo");	
				PARTY_JOB_TOOLTIP(partyinfoFrame, partyMemberCID, jobIcon, jobCls, 1);  
					
				local partyFrame = ui.GetFrame('party');
				local gbox = partyFrame:GetChild("gbox");
				local memberlist = gbox:GetChild("memberlist");					
				PARTY_JOB_TOOLTIP(memberlist, partyMemberCID, jobIcon, jobCls, 1);            
			end;
		end

		local tooltipID = jobIcon:GetTooltipIESID();		
		if nil == tooltipID then	
			jobName = GET_JOB_NAME(jobCls, iconinfo.gender);	
			jobIcon:SetTextTooltip(jobName);
		end
		
		local stat = partyMemberInfo:GetInst();
		local pos = stat:GetPos();

		local dist = info.GetDestPosDistance(pos.x, pos.y, pos.z, myHandle);
		local sharedcls = GetClass("SharedConst",'PARTY_SHARE_RANGE');

		local mymapname = session.GetMapName();

		local partymembermapName = GetClassByType("Map", partyMemberInfo:GetMapID()).ClassName;
		local partymembermapUIName = GetClassByType("Map", partyMemberInfo:GetMapID()).Name;

		if ispipui == true then
			partyMemberName = ScpArgMsg("PartyMemberMapNChannel","Name",partyMemberName,"Mapname",partymembermapUIName,"ChNo",partyMemberInfo:GetChannel() + 1)
		end
				

		if dist < sharedcls.Value and mymapname == partymembermapName then
			jobportraitImg:SetColorTone(NEAR_MEMBER_FACE_COLORTONE)
			partyMemberName = NEAR_MEMBER_NAME_FONT_COLORTAG..partyMemberName;
			nameRichText:SetTextByKey("name", partyMemberName);
			hpGauge:SetColorTone(NEAR_MEMBER_FACE_COLORTONE);
			spGauge:SetColorTone(NEAR_MEMBER_FACE_COLORTONE);
		else
			jobportraitImg:SetColorTone(FAR_MEMBER_FACE_COLORTONE)
			partyMemberName = FAR_MEMBER_NAME_FONT_COLORTAG..partyMemberName;
			nameRichText:SetTextByKey("name", partyMemberName);
			hpGauge:SetColorTone(FAR_MEMBER_FACE_COLORTONE);
			spGauge:SetColorTone(FAR_MEMBER_FACE_COLORTONE);
		end

	end
	
	partyInfoCtrlSet:EnableHitTest(1);
	partyInfoCtrlSet:SetEventScript(ui.RBUTTONUP, "CONTEXT_PARTY");
	partyInfoCtrlSet:SetEventScriptArgString(ui.RBUTTONUP, partyMemberInfo:GetAID());

	if partyMemberInfo:GetAID() == leaderFID then
		leaderMark:ShowWindow(1)
		if isCorsairType == true then
			leaderMark:SetImage('party_corsair_mark');
		else
			leaderMark:SetImage('party_leader_mark');
		end
	end

	partyInfoCtrlSet:SetUserValue("MEMBER_NAME", partyMemberName);

	if hpGauge:GetStat() == 0 then
		hpGauge:AddStat("%v / %m");
		hpGauge:SetStatOffset(0, 0, -1);
		hpGauge:SetStatAlign(0, ui.CENTER_HORZ, ui.CENTER_VERT);
		hpGauge:SetStatFont(0, 'white_12_ol');
	end
	
	if spGauge:GetStat() == 0 then
		spGauge:AddStat("%v / %m");
		spGauge:SetStatOffset(0, 0, -1);
		spGauge:SetStatAlign(0, ui.CENTER_HORZ, ui.CENTER_VERT);
		spGauge:SetStatFont(0, 'white_12_ol');
	end

	-- 파티원 레벨 표시 -- 
	local lvbox = partyInfoCtrlSet:GetChild('lvbox');
	local levelObj = partyInfoCtrlSet:GetChild('lvbox');
	local levelRichText = tolua.cast(levelObj, "ui::CRichText");
	local level = partyMemberInfo:GetLevel();	
	levelRichText:SetTextByKey("lv", level);
	levelRichText:SetColorTone(NEAR_MEMBER_FACE_COLORTONE);
	lvbox:Resize(levelRichText:GetWidth(), lvbox:GetHeight());
		
	if frame:GetName() == 'partyinfo' then
		frame:Resize(frame:GetOriginalWidth(), count * partyInfoCtrlSet:GetHeight());
	else
		frame:Resize(frame:GetOriginalWidth(), frame:GetOriginalHeight());
	end
	
	return 1;
end

function SET_LOGOUT_PARTYINFO_ITEM(frame, msg, partyMemberInfo, count, makeLogoutPC, leaderFID, isCorsairType, partyID)
    if partyID ~= nil and partyMemberInfo ~= nil and partyID ~= partyMemberInfo:GetPartyID() then
        return nil;
    end

	local partyinfoFrame = ui.GetFrame('partyinfo')
	local FAR_MEMBER_FACE_COLORTONE = partyinfoFrame:GetUserConfig("FAR_MEMBER_FACE_COLORTONE")
	local FAR_MEMBER_NAME_FONT_COLORTAG = partyinfoFrame:GetUserConfig("FAR_MEMBER_NAME_FONT_COLORTAG")

	local mapName = geMapTable.GetMapName(partyMemberInfo:GetMapID());
	local partyMemberName = partyMemberInfo:GetName();

	local ctrlName = 'PTINFO_'.. partyMemberInfo:GetAID();
	local partyInfoCtrlSet = frame:CreateOrGetControlSet('partyinfo', ctrlName, 10, count * 60);
	
	partyInfoCtrlSet:SetEventScript(ui.RBUTTONUP, "None");
	AUTO_CAST(partyInfoCtrlSet);
		
	-- 파티원 hp / sp 표시 --
	local hpObject 				= partyInfoCtrlSet:GetChild('hp');
	local hpGauge 				= tolua.cast(hpObject, "ui::CGauge");
	local spObject 				= partyInfoCtrlSet:GetChild('sp');
	local spGauge 				= tolua.cast(spObject, "ui::CGauge");
	
	hpGauge:SetPoint(0, 0);
	spGauge:SetPoint(0, 0);
	
	local nameObj = partyInfoCtrlSet:GetChild('name_text');
	local nameRichText = tolua.cast(nameObj, "ui::CRichText");		
	nameRichText:SetTextByKey("name", FAR_MEMBER_NAME_FONT_COLORTAG .. partyMemberName);		
	partyInfoCtrlSet:SetUserValue("MEMBER_NAME", partyMemberName);

	local leaderMark = GET_CHILD(partyInfoCtrlSet, "leader_img", "ui::CPicture");
	leaderMark:SetImage('None_Mark');
	leaderMark:ShowWindow(0)
	
	if partyMemberInfo:GetAID() == leaderFID then
		leaderMark:ShowWindow(1)
		if isCorsairType == true then
			leaderMark:SetImage('party_corsair_mark');
		else
			leaderMark:SetImage('party_leader_mark');
		end	
	end
				
	-- 머리
	local jobportraitImg = GET_CHILD(partyInfoCtrlSet, "jobportrait_bg", "ui::CPicture");
	if jobportraitImg ~= nil then
		jobIcon = GET_CHILD(jobportraitImg, "jobportrait", "ui::CPicture");
		local iconinfo = partyMemberInfo:GetIconInfo();
		local jobCls  = GetClassByType("Job", iconinfo.repre_job);
		if nil ~= jobCls then
			jobIcon:SetImage(jobCls.Icon);
		end
	end

	-- 파티원 레벨 표시 -- 
	local lvbox = partyInfoCtrlSet:GetChild('lvbox');
	local levelObj = partyInfoCtrlSet:GetChild('lvbox');
	local levelRichText = tolua.cast(levelObj, "ui::CRichText");

	levelRichText:SetTextByKey("lv", 'Out');
	lvbox:Resize(levelRichText:GetWidth(), lvbox:GetHeight());

	partyInfoCtrlSet:EnableHitTest(1);
	partyInfoCtrlSet:SetEventScript(ui.RBUTTONUP, "CONTEXT_PARTY");
	partyInfoCtrlSet:SetEventScriptArgString(ui.RBUTTONUP, partyMemberInfo:GetAID());

	local color = FAR_MEMBER_FACE_COLORTONE
	jobportraitImg:SetColorTone(color);
	levelRichText:SetColorTone(color);
	hpGauge:SetColorTone(color);
	spGauge:SetColorTone(color);

	frame:Resize(frame:GetWidth(), count * partyInfoCtrlSet:GetHeight());
	return 1;
end