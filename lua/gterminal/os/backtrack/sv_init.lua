local OS = OS;

include("sv_commands.lua");

function OS:GetName()
	return "BacktrackOS";
end;

function OS:GetUniqueID()
	return "backtrack";
end;

function OS:GetWarmUpText()
	return {
        "             )                  )  ",
        "            ( /(  (       (    ( /(  ",
        "            )\\()) )\\      )\\   )\\()) ",
        "           ((_)((((_)(  (((_)|((_)\\  ",
        "            _((_)\\ _ )\\ )\\___|_ ((_) ",
        "           | || (_)_\\(_|(/ __| |/ /  ",
        "           | __ |/ _ \\  | (__  ' <   ",
        "           |_||_/_/ \\_\\  \\___|_|\\_\\  ",                
		" The quieter you become the more you are able to hear."
	};
end;