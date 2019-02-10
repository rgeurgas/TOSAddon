function LIKE_FAILED()

end

function REQUEST_LIKE_STATE(familyName)
	local otherpcinfo = session.otherPC.GetByFamilyName(familyName);
	
	local frame = ui.GetFrame("compare");
	local likeCheck = GET_CHILD_RECURSIVELY(frame,"likeCheck")
	if session.likeit.AmILikeYou(familyName) == false then
		if false == geClientInteraction.RequestLikeIt(otherpcinfo:GetAID(), otherpcinfo:GetCID()) then
			likeCheck:ToggleCheck();
		end
	else
		if false == geClientInteraction.RequestUnlikeIt(otherpcinfo:GetAID(), otherpcinfo:GetCID()) then
			likeCheck:ToggleCheck();
		end
	end
end

function DO_CLICK_LIKECHECK()

end