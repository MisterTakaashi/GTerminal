local OS = OS;

include("sv_commands.lua");

function OS:GetName()
	return "PBCS";
end;

function OS:GetUniqueID()
	return "default";
end;

function OS:GetWarmUpText()
	return {
		"Initialisation de la sequence de boot.",
		"Finalisation de la premiere sequence de boot.",
        "Chargement de l'OS en RAM."
	};
end;