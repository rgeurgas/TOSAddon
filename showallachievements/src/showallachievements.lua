function STATUS_ACHIEVE_INIT(frame)

    local achieveGbox = frame:GetChild('achieveGbox');
    local internalBox = achieveGbox:GetChild("internalBox");

    local clslist, clscnt = GetClassList("Achieve");
    local etcObj = GetMyEtcObject();
    local x = 10;
    local y = 10;

    local equipAchieveName = pc.GetEquipAchieveName();

    for i = 0, clscnt - 1 do

        local cls = GetClassByIndexFromList(clslist, i);
        if cls == nil then
            break;
        end


        local nowpoint = GetAchievePoint(GetMyPCObject(), cls.NeedPoint)

        local eachAchiveCSet = internalBox:CreateOrGetControlSet('each_achieve', 'ACHIEVE_RICHTEXT_' .. i, x, y);
        tolua.cast(eachAchiveCSet, "ui::CControlSet");

        eachAchiveCSet:SetUserValue('ACHIEVE_ID', cls.ClassID);

        local NORMAL_SKIN = eachAchiveCSet:GetUserConfig("NORMAL_SKIN")
        local HAVE_SKIN = eachAchiveCSet:GetUserConfig("HAVE_SKIN")

        local eachAchiveGBox = GET_CHILD_RECURSIVELY(eachAchiveCSet, 'each_achieve_gbox')
        local eachAchiveDescTitle = GET_CHILD_RECURSIVELY(eachAchiveCSet, 'achieve_desctitle')
        local eachAchiveReward = GET_CHILD_RECURSIVELY(eachAchiveCSet, 'achieve_reward')
        local eachAchiveGauge = GET_CHILD_RECURSIVELY(eachAchiveCSet, 'achieve_gauge')
        local eachAchiveStaticAccomplishment = GET_CHILD_RECURSIVELY(eachAchiveCSet, 'achieve_static_accomplishment')
        local eachAchiveAccomplishment = GET_CHILD_RECURSIVELY(eachAchiveCSet, 'achieve_accomplishment')
        local eachAchiveStaticDesc = GET_CHILD_RECURSIVELY(eachAchiveCSet, 'achieve_static_desc')
        local eachAchiveDesc = GET_CHILD_RECURSIVELY(eachAchiveCSet, 'achieve_desc')
        local eachAchiveName = GET_CHILD_RECURSIVELY(eachAchiveCSet, 'achieve_name')
        local eachAchiveReqBtn = GET_CHILD_RECURSIVELY(eachAchiveCSet, 'req_reward_btn')

            --조건과 칭호의 위치를 텍스트 길이가 가장 긴 "달성도" 기준으로 맞춘다
        eachAchiveReqBtn:ShowWindow(0);
        eachAchiveDesc:SetOffset(eachAchiveStaticDesc:GetX() + eachAchiveStaticAccomplishment:GetWidth() + 10, eachAchiveDesc:GetY())
        eachAchiveAccomplishment:SetOffset(eachAchiveStaticAccomplishment:GetX() + eachAchiveStaticAccomplishment:GetWidth() + 10, eachAchiveAccomplishment:GetY())
        eachAchiveGauge:SetOffset(eachAchiveStaticAccomplishment:GetX() + eachAchiveStaticAccomplishment:GetWidth() + 10, eachAchiveGauge:GetY())
        eachAchiveGauge:Resize(eachAchiveGBox:GetWidth() - eachAchiveStaticAccomplishment:GetWidth() -50, eachAchiveGauge:GetHeight())
        eachAchiveAccomplishment:SetText("(" .. nowpoint .. "/" .. cls.NeedCount .. ")")

        local isHasAchieve = 0;
        if HAVE_ACHIEVE_FIND(cls.ClassID) == 1 and nowpoint >= cls.NeedCount then
            isHasAchieve = 1;
        end

        if isHasAchieve == 1 then
            if equipAchieveName ~= 'None' and equipAchieveName == cls.Name then
                eachAchiveDescTitle:SetText(cls.DescTitle .. ScpArgMsg('Auto__(SayongJung)'));
            else
                eachAchiveDescTitle:SetText(cls.DescTitle);
            end
            eachAchiveGBox:SetSkinName(HAVE_SKIN)
        else
            eachAchiveDescTitle:SetText(cls.DescTitle);
            eachAchiveGBox:SetSkinName(NORMAL_SKIN)
        end

        eachAchiveDesc:SetText(cls.Desc);
        eachAchiveGauge:SetPoint(nowpoint, cls.NeedCount);
        eachAchiveName:SetTextByKey('name', cls.Name);
        eachAchiveReward:SetTextByKey('reward', cls.Reward);

        if isHasAchieve == 1 then
            eachAchiveGauge:ShowWindow(0);
            eachAchiveStaticAccomplishment:ShowWindow(0);
            eachAchiveAccomplishment:ShowWindow(0);

            eachAchiveStaticDesc:SetOffset(eachAchiveStaticDesc:GetX(), eachAchiveStaticAccomplishment:GetY())
            eachAchiveDesc:SetOffset(eachAchiveDesc:GetX(), eachAchiveStaticDesc:GetY())
               
            local etcObjValue = TryGetProp(etcObj, 'AchieveReward_' .. cls.ClassName);
                -- if etcObj['AchieveReward_' .. cls.ClassName] == 0 then
            if etcObjValue ~= nil and etcObjValue == 0 then
                eachAchiveReqBtn:ShowWindow(1);
            end
        else
                eachAchiveGauge:ShowWindow(1)
            eachAchiveStaticAccomplishment:ShowWindow(1);
            eachAchiveAccomplishment:ShowWindow(1);
        end

        local suby = eachAchiveDesc:GetY() + eachAchiveDesc:GetHeight() + 10;


        if cls.Name ~= 'None' then
            eachAchiveName:ShowWindow(1)
            eachAchiveName:SetOffset(eachAchiveName:GetX(), suby)
            suby = eachAchiveName:GetY() + eachAchiveName:GetHeight() + 10
        else
            eachAchiveName:ShowWindow(0)
        end

        if cls.Reward ~= 'None' then
            eachAchiveReward:ShowWindow(1)
            eachAchiveReward:SetOffset(eachAchiveReward:GetX(), suby)
            suby = eachAchiveReward:GetY() + eachAchiveReward:GetHeight() + 10
        else
            eachAchiveReward:ShowWindow(0)
        end

        eachAchiveGBox:Resize(eachAchiveGBox:GetWidth(), suby)

        eachAchiveCSet:Resize(eachAchiveCSet:GetWidth(), eachAchiveGBox:GetHeight())

        y = y + eachAchiveCSet:GetHeight() + 10;
    end

    
    local customizingGBox =  GET_CHILD_RECURSIVELY(frame, 'customizingGBox')

    -- 가발 염색 목록 보여주기.
    STATUS_ACHIEVE_INIT_HAIR_COLOR(customizingGBox)
    

    DESTROY_CHILD_BYNAME(customizingGBox, "ACHIEVE_RICHTEXT_");
    local index = 0;
    local x = 40;
    local y = 145;
    

	local useableTitleList = GET_CHILD_RECURSIVELY(frame, "useableTitleList", "ui::CDropList");
	useableTitleList:SelectItemByKey(config.GetXMLConfig("SelectAchieveKey"))
	if equipAchieveName == nil or equipAchieveName == 'None' then
		useableTitleList:ClearItems()
	end
	local myAchieveCount = 0;
	local myAchieveCount_ExceptPeriod = 0
	local currentAchieveCls = nil
	local nextAchieveCls = nil
	frame:SetUserValue("ShowNextStatReward", 0)
	local showNextStatRewardCheckBox = GET_CHILD_RECURSIVELY(frame, 'showNextStatReward')
	showNextStatRewardCheckBox:SetCheck(0)

	local defaultTitleText = frame:GetUserConfig("DEFAULT_TITLE_TEXT")

	useableTitleList:AddItem(0, defaultTitleText)

    for i = 0, clscnt - 1 do

        local cls = GetClassByIndexFromList(clslist, i);
        if cls == nil then
            break;
        end

        local nowpoint = GetAchievePoint(GetMyPCObject(), cls.NeedPoint)

        local isHasAchieve = 0;
        if HAVE_ACHIEVE_FIND(cls.ClassID) == 1 and nowpoint >= cls.NeedCount then
            isHasAchieve = 1;
        end

        if isHasAchieve == 1 and cls.Name ~= "None" then
			local itemString = string.format("{@st42b}%s{/}", cls.Name);
			useableTitleList:AddItem(i, itemString);
			myAchieveCount = myAchieveCount + 1			
			if cls.PeriodAchieve ~= "YES" then
				myAchieveCount_ExceptPeriod = myAchieveCount_ExceptPeriod + 1
			end
        end
    end
				
	local nextAchieveCount = 0
	local list, cnt = GetClassList("AchieveStatReward");

	for i = 0, cnt - 1 do
		local cls = GetClassByIndexFromList(list, i);

		if i + 1 <= cnt - 1 then
			local achieveCount = cls.AchieveCount
			local tempNextAchieveCls = GetClassByIndexFromList(list, i + 1);
			nextAchieveCount = tempNextAchieveCls.AchieveCount
			if achieveCount <= myAchieveCount_ExceptPeriod and myAchieveCount_ExceptPeriod < nextAchieveCount then
				currentAchieveCls = cls
				nextAchieveCls = tempNextAchieveCls
				break
			end
		else
			currentAchieveCls = cls
			nextAchieveCls = cls
		end		
	end

	local titleListStatic = GET_CHILD_RECURSIVELY(frame, "titleListStatic")
	titleListStatic:SetTextByKey("value1", myAchieveCount)

	local currentbuffText = GET_CHILD_RECURSIVELY(frame, "currentbuffText")
	local nextbuffText = GET_CHILD_RECURSIVELY(frame, "nextbuffText")
	if myAchieveCount_ExceptPeriod == 0 then
		currentbuffText:SetTextByKey("value", 0)
		nextbuffText:SetTextByKey("value", 1)
    elseif myAchieveCount_ExceptPeriod >= 60 then
        currentbuffText:SetTextByKey("value", currentAchieveCls.ClassID - 1)
        nextbuffText:SetTextByKey("value", 0)
	else
		currentbuffText:SetTextByKey("value", currentAchieveCls.ClassID - 1)
		nextbuffText:SetTextByKey("value", nextAchieveCount - myAchieveCount_ExceptPeriod)
	end
					
	frame : SetUserValue("currentAchieveClassID", currentAchieveCls.ClassID)
	frame : SetUserValue("nextAchieveClassID", nextAchieveCls.ClassID)

	CHANGE_STAT_FONT(frame, 'STR', currentAchieveCls.STR_BM, 1)
	CHANGE_STAT_FONT(frame, 'CON', currentAchieveCls.CON_BM, 1)
	CHANGE_STAT_FONT(frame, 'INT', currentAchieveCls.INT_BM, 1)
	CHANGE_STAT_FONT(frame, 'MNA', currentAchieveCls.MNA_BM, 1)
	CHANGE_STAT_FONT(frame, 'DEX', currentAchieveCls.DEX_BM, 1)
	CHANGE_STAT_FONT(frame, 'PATK', currentAchieveCls.PATK_BM, 1)
	CHANGE_STAT_FONT(frame, 'MATK', currentAchieveCls.MATK_BM, 1)
	CHANGE_STAT_FONT(frame, 'DEF', currentAchieveCls.DEF_BM, 1)
	CHANGE_STAT_FONT(frame, 'MDEF', currentAchieveCls.MDEF_BM, 1)
	CHANGE_STAT_FONT(frame, 'MSP', currentAchieveCls.MSP_BM, 1)
				
	frame:Invalidate();
end