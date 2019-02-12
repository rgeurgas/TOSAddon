function RESTARTME_ON_INIT(addon, frame)
	local acutil = require("acutil");
	acutil.slashCommand('/resme', resme);
	acutil.slashCommand('/resmenow', resmenow);
end

function resme()
	local fsmActor = GetMyActor();
	if fsmActor:IsDead() == 1 then
		RESTART_ON_MSG(ui.GetFrame('restart'), 'RESTART_HERE', 'None', 6);
	end		
end

function resmenow()
	local fsmActor = GetMyActor();
	if fsmActor:IsDead() == 1 then
		restart.SendRestartSavePointMsg();
	end
end