local gTerminal = gTerminal;
local timer = timer;
local OS = OS;

OS:NewCommand(":help", function(client, entity, arguments)
	gTerminal:Broadcast(entity, "=============================");
	gTerminal:Broadcast(entity, "  *Bienvenue sur le Terminal!");
	gTerminal:Broadcast(entity, "  *Cree par Chessnut, traduit par MisterTakaashi.");
	gTerminal:Broadcast(entity, "");
	gTerminal:Broadcast(entity, "    COMMANDES:");

	for k, v in SortedPairs( OS:GetCommands() ) do
		gTerminal:Broadcast(entity, "     "..k.." - "..v.help);
	end;

	gTerminal:Broadcast(entity, "=============================");
end, "Affiche une liste des commandes.");

OS:NewCommand(":cls", function(client, entity)
	for i = 0, 25 do
		timer.Simple(i * 0.01, function()
			if ( IsValid(entity) ) then
				gTerminal:Broadcast(entity, "", MSG_COL_NIL, i);
			end;
		end);
	end;
end, "Nettoyer l'ecran.");

OS:NewCommand(":os", function(client, entity, arguments)
	local command = arguments[1];

	if (command == "install") then
		local info = arguments[2];

		if (!info) then
			gTerminal:Broadcast(entity, "OS inconnu!", GT_COL_ERR);

			return;
		elseif (info == "default") then
			gTerminal:Broadcast(entity, "Impossible d'utiliser le systeme primaire!", GT_COL_ERR);

			return;
		end;

		local system = gTerminal.os[info];

		if (!system) then
			gTerminal:Broadcast(entity, "Impossible de trouver l'OS!", GT_COL_ERR);

			return;
		end;

		entity.locked = true;

		gTerminal:Broadcast(entity, "Preparation de l'installation...", GT_COL_INTL);

		timer.Simple(1, function()
			if ( !IsValid(entity) ) then
				return;
			end;

			for i = 0, 25 do
				gTerminal:Broadcast(entity, "", nil, i);
			end;

			gTerminal:Broadcast(entity, "=================================================", GT_COL_MSG, 16);
			gTerminal:Broadcast(entity, "Idle...", GT_COL_MSG, 18);
			gTerminal:Broadcast(entity, "", GT_COL_MSG, 19);
			gTerminal:Broadcast(entity, "     [                         ] 0%", GT_COL_MSG, 20);
			gTerminal:Broadcast(entity, "", GT_COL_MSG, 21);
			gTerminal:Broadcast(entity, "=================================================", GT_COL_MSG, 22);

			local messages = {
				"Inspection de l'espace disque.",
				"Allocation de l'espace disque.",
				"Recherche des ressources.",
				"Unpacking des resources.",
				"Recherche des prerequis systeme.",
				"Validation de l'integrite des fichiers.",
				"Compilation des packages.",
				"Exportation des packages.",
				"Reglage des donnees d'acces.",
				"Reglage des profiles.",
				"Reglage des commandes.",
				"Finalisation de l'installation."
			};

			local time = math.Rand(0.5, 1.5);

			for i = 1, 25 do
				time = time + math.Rand(0.05, 0.25);

				timer.Simple(time, function()
					if ( IsValid(entity) ) then
						local msgID = math.Clamp(i, 1, #messages);

						gTerminal:Broadcast(entity, "     "..messages[msgID], GT_COL_MSG, 18);
						gTerminal:Broadcast(entity, "     ["..string.rep("=", i)..string.rep(" ", 25 - i).."] "..( 100 * math.Round(i / 25, 2) ).."%", GT_COL_MSG, 20);

						if (i == 25) then
							for i = 0, 25 do
								if ( IsValid(entity) ) then
									gTerminal:Broadcast(entity, "", nil, i);
								end;
							end;

							gTerminal:Broadcast(entity, "ARRET DU SYSTEME, REDEMARREZ LE TERMINAL...", GT_COL_INTL, 1);

							timer.Simple(math.Rand(1, 3), function()
								if ( IsValid(entity) ) then
									entity:SetOS(info);
									entity:SetActive(false);
									entity.locked = false;
								end;
							end);
						end;
					end;
				end);
			end;
		end);
	elseif (command == "list") then
		local info = arguments[2];

		gTerminal:Broadcast(entity, "Packages d'OS disponibles:");
		gTerminal:Broadcast(entity, "", GT_COL_MSG);

		local count = 0;

		for k, v in SortedPairs(gTerminal.os) do
			if (type(v) == "table" and v.GetName and v.GetUniqueID and v:GetUniqueID() != "default") then
				count = count + 1;

				gTerminal:Broadcast(entity, "     "..count..". "..v:GetUniqueID().." ("..v:GetName()..")");
			end;
		end;
	else
		gTerminal:Broadcast(entity, "Configuration de l'OS");
		gTerminal:Broadcast(entity, "  INFO:");
		gTerminal:Broadcast(entity, "    Autorise la configuration de l'OS.");
		gTerminal:Broadcast(entity, "  AIDE:");
		gTerminal:Broadcast(entity, "    :os install - Installer un OS.");
		gTerminal:Broadcast(entity, "    :os list - Lister les OS disponibles.");
	end;
end, "Configuration de l'OS.");

OS:NewCommand(":x", function(client, entity)
	gTerminal:Broadcast( entity, "ARRET EN COURS..." );

	timer.Simple(math.Rand(2, 5), function()
		if ( IsValid(entity) ) then
			for i = 0, 25 do
				if ( IsValid(entity) ) then
					gTerminal:Broadcast(entity, "", nil, i);
				end;
			end;

			entity:SetActive(false);

			gTerminal.os:Call(entity, "ShutDown");
		end;
	end);
end, "Eteindre le terminal.");