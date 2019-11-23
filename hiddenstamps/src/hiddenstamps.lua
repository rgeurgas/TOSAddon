function HIDDENSTAMPS_ON_INIT(addon, frame)
	local acutil = require("acutil");
	acutil.slashCommand('/hiddenstamps', hiddenstamps);
end

function hiddenstamps()
	-- 1 identify items
	-- 2 use warpstones
	-- 3 total attribute levels
	-- 4 use player shops
	local aobj = GetMyAccountObj(); 
	
	--Mission 1
	if (aobj.REGULAR_EVENT_STAMP_TOUR_HIDDEN_COND1 > 300) then
		CHAT_SYSTEM("Identify Items: 300/300");
	else
		CHAT_SYSTEM("Identify Items: " .. aobj.REGULAR_EVENT_STAMP_TOUR_HIDDEN_COND1 .. "/300");
	end
	
	--Mission 2
	if (aobj.REGULAR_EVENT_STAMP_TOUR_HIDDEN_COND2 > 150) then
		CHAT_SYSTEM("Use Warpstones: 150/150");
	else
		CHAT_SYSTEM("Use Warpstones: " .. aobj.REGULAR_EVENT_STAMP_TOUR_HIDDEN_COND2 .. "/150");
	end
	
	--Mission 3
	if (aobj.REGULAR_EVENT_STAMP_TOUR_HIDDEN_COND3 > 150) then
		CHAT_SYSTEM("Total Attribute Levels: 150/150");
	else
		CHAT_SYSTEM("Total Attribute Levels: " .. aobj.REGULAR_EVENT_STAMP_TOUR_HIDDEN_COND3 .. "/150");
	end
	
	--Mission 4
	if (aobj.REGULAR_EVENT_STAMP_TOUR_HIDDEN_COND4 > 100) then
		CHAT_SYSTEM("Use Player Shops: 100/100");
	else
		CHAT_SYSTEM("Use Player Shops: " .. aobj.REGULAR_EVENT_STAMP_TOUR_HIDDEN_COND4 .. "/100");
	end
end