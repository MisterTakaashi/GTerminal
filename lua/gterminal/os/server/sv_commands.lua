local gTerminal = gTerminal;
local timer = timer;
local OS = OS;

OS:NewCommand(":help", function(client, entity, arguments)
	gTerminal:Broadcast(entity, "=============================");
	gTerminal:Broadcast(entity, "  AIDE SERVER OS");
	gTerminal:Broadcast(entity, "");
	gTerminal:Broadcast(entity, "    COMMANDES:");

	for k, v in SortedPairs( OS:GetCommands() ) do
		gTerminal:Broadcast(entity, "     "..k.." - "..v.help);
	end;

	gTerminal:Broadcast(entity, "=============================");
end, "Affiche une liste des commandes.");

OS:NewCommand(":cls", function(client, entity)
	for i = 0, 25 do
		timer.Simple(i * 0.05, function()
			if ( IsValid(entity) ) then
				gTerminal:Broadcast(entity, "", MSG_COL_NIL, i);
			end;
		end);
	end;
end, "Nettoyer l'ecran.");

OS:NewCommand(":gid", function(client, entity)
	gTerminal:Broadcast( entity, "TERMINAL ID => "..entity:EntIndex() );
end, "Obtenir l'ID du terminal.");

OS:NewCommand(":setpass", function(client, entity, arguments)
	local password = table.concat(arguments, " ");

	if (password and password != "") then
		entity.password = password;
		gTerminal:Broadcast(entity, "Mot de passe modifie en: '"..entity.password.."'.");
	else
		entity.password = nil;
		gTerminal:Broadcast(entity, "Mot de passe supprime.");
	end;
end, "Mettre un mot de passe au terminal.");

OS:NewCommand(":x", function(client, entity)
	gTerminal:Broadcast( entity, "ARRET EN COURS..." );

	for k, v in pairs( player.GetAll() ) do
		v[ "pass_authed_"..entity:EntIndex() ] = nil;
	end;

	gTerminal.os:Call(entity, "ShutDown");
	
	timer.Simple(math.Rand(2, 5), function()
		if ( IsValid(entity) ) then
			for i = 0, 25 do
				if ( IsValid(entity) ) then
					gTerminal:Broadcast(entity, "");
				end;
			end;

			entity:SetActive(false);
		end;
	end);
end, "Arrêter le terminal.");

OS:NewCommand(":gnet", function(client, entity, arguments)
	if ( !arguments[1] ) then
		gTerminal:Broadcast(entity, "Configuration de reseau");
		gTerminal:Broadcast(entity, "  INFO:");
		gTerminal:Broadcast(entity, "    Creez vos propres reseaux.");
		gTerminal:Broadcast(entity, "  HELP:");
		gTerminal:Broadcast(entity, "    :gnet c <reseau> - Creer un reseau.");
		gTerminal:Broadcast(entity, "    :gnet l - Quitter le reseau.");
		gTerminal:Broadcast(entity, "    :gnet ls - Lister les reseaux actifs.");
		gTerminal:Broadcast(entity, "    :gnet lu - Lister les utilisateurs d'un reseau.");
		gTerminal:Broadcast(entity, "    :gnet m <ID utilisateur> <message> - Envoyer un message a un autre utilisateur.");
	elseif (arguments[1] == "c") then
		if ( !arguments[2] ) then
			gTerminal:Broadcast(entity, "Mauvaise saisie du reseau!", GT_COL_ERR);

			return;
		end;

		if (entity.networkID) then
			gTerminal:Broadcast(entity, "Vous hebergez deja un reseau '"..entity.networkID.."'", GT_COL_WRN);

			return;
		end;

		for k, v in pairs( ents.FindByClass(entity.ClassName) ) do
			if (v.isHost and v.networkID == arguments[2]) then
				gTerminal:Broadcast(entity, "ID de reseau deja utilise!", GT_COL_ERR);

				return;
			end;
		end;

		if ( arguments[3] ) then
			entity.netPassword = arguments[3];
		end;

		entity.isHost = true;
		entity.networkID = arguments[2];

		if (entity.netPassword) then
			gTerminal:Broadcast(entity, "Le reseau '"..entity.networkID.."' a ete cree avec la cle '"..entity.netPassword.."'", GT_COL_SUCC);
		else
			gTerminal:Broadcast(entity, "Creation du reseau '"..entity.networkID.."'", GT_COL_SUCC);
		end;
	elseif (arguments[1] == "l") then
		if (!entity.networkID) then
			gTerminal:Broadcast(entity, "Vous n'etes connecte a aucun reseau!", GT_COL_ERR);

			return;
		end;

		for k, v in pairs( ents.FindByClass(entity.ClassName) ) do
			if (entity.isHost and v != entity and v.networkID and v.networkID == entity.networkID) then
				gTerminal:Broadcast(v, "Connexion au reseau perdue!", GT_COL_WRN);

				v.networkID = nil;
			end;
		end;

		entity.isHost = nil;
		entity.networkID = nil;

		gTerminal:Broadcast(entity, "Vous avez quitte le reseau.", GT_COL_SUCC);
	elseif (arguments[1] == "ls") then
		gTerminal:Broadcast(entity, "RESEAUX ACTIFS:");

		local num = 0;

		for k, v in pairs( ents.FindByClass(entity.ClassName) ) do
			if (v.isHost and v.networkID) then
				num = num + 1;

				if (v.netPassword) then
					gTerminal:Broadcast(entity, "    "..num..". "..v.networkID.." (PRIVE)");
				else
					gTerminal:Broadcast(entity, "    "..num..". "..v.networkID.." (PUBLIC)");
				end;
			end;
		end;

		gTerminal:Broadcast(entity, "");
		gTerminal:Broadcast(entity, "    "..num.." reseaux actif(s) trouve(s).");
	elseif (arguments[1] == "lu") then
		if (!entity.networkID) then
			gTerminal:Broadcast(entity, "Vous n'etes connecte a aucun reseau!", GT_COL_ERR);

			return;
		end;

		gTerminal:Broadcast(entity, "UTILISATEURS ACTIFS:");

		local num = 0;

		for k, v in pairs( ents.FindByClass(entity.ClassName) ) do
			if (v.networkID and v.networkID == entity.networkID) then
				if ( v:EntIndex() != entity:EntIndex() ) then
					num = num + 1;

					if (v.isHost) then
						gTerminal:Broadcast( entity, "    "..num..". (HOST) "..v:EntIndex() );
					else
						gTerminal:Broadcast( entity, "    "..num..". "..v:EntIndex() );
					end;
				end;
			end;
		end;

		gTerminal:Broadcast(entity, "");
		gTerminal:Broadcast(entity, "    "..num.." utilisateur(s) actif(s) trouve(s).");
	elseif (arguments[1] == "m") then
		if (!entity.networkID) then
			gTerminal:Broadcast(entity, "Vous n'etes connecte a aucun reseau!", GT_COL_ERR);

			return;
		end;

		if ( !arguments[2] or (!tonumber( arguments[2] ) and arguments[2] != "@") ) then
			gTerminal:Broadcast(entity, "ID d'utilisatuer introuvable!", GT_COL_ERR);
			gTerminal:Broadcast(entity, "Utilisez l'id d'un autre terminal ou @ pour cibler tous les terminaux du reseau.", GT_COL_ERR);

			return;
		end;

		local arguments2 = table.Copy(arguments);

		table.remove(arguments2, 1);
		table.remove(arguments2, 1);

		local message = table.concat(arguments2, " ");

		if (!message or message == "") then
			gTerminal:Broadcast(entity, "Vous n'avez pas specifie le message!", GT_COL_ERR);

			return;
		end;

		local name = "NIL";

		if (entity.isHost) then
			name = "SERVER";
		else
			name = entity:EntIndex();
		end;

		local index;

		if (arguments[2] != "@") then
			index = tonumber( arguments[2] );

			if (!index) then
				gTerminal:Broadcast(entity, "ID de terminal invalide!", GT_COL_ERR);

				return;
			end;
		end;

		local found = false;

		for k, v in pairs( ents.FindByClass(entity.ClassName) ) do
			if (!v.networkID) then
				continue;
			end;

			if ( v != entity and ( (v.isHost and v.networkID == entity.networkID) or ( v.networkID == entity.networkID and (arguments[2] == "@" or v:EntIndex() == index) ) ) ) then
				found = true;

				gTerminal:Broadcast(v, name.."@"..entity.networkID.." => "..message, GT_COL_INFO);
			end;
		end;

		if (arguments[2] != "@" and !found) then
			gTerminal:Broadcast(entity, "Impossible de trouver l'utilisateur!", GT_COL_ERR);

			return;
		end;

		gTerminal:Broadcast(entity, name.."@"..entity.networkID.." => "..message, GT_COL_INFO);
	end;
end, "Plateforme de reseau globale.");

OS:NewCommand(":f", function(client, entity, arguments)
	local command = arguments[1];

	if (!entity.fileCurrentDir) then
		gTerminal.file:Initialize(entity);
	end;

	if (!command) then
		gTerminal:Broadcast(entity, "Systeme de fichiers");
		gTerminal:Broadcast(entity, "  INFO:");
		gTerminal:Broadcast(entity, "    C'est le systeme de fichier du terminal.");
		gTerminal:Broadcast(entity, "  HELP:");
		gTerminal:Broadcast(entity, "    :f ndir <nom> - Creer un nouveau repertoire.");	
		gTerminal:Broadcast(entity, "    :f r <ancien> <nouveau> - Renommer un fichier/repertoire.");	
		gTerminal:Broadcast(entity, "    :f d <nom> - Supprimer un fichier/repertoire.");
		gTerminal:Broadcast(entity, "    :f w <nom> <valeur> - Ecrire un fichier.");
		gTerminal:Broadcast(entity, "    :f chdir <nom> - Changer le repertoire courant.");
		gTerminal:Broadcast(entity, "    :f l - Lister tous les elements presents dans ce repertoire.");
		gTerminal:Broadcast(entity, "    :f rd <nom> - Lire le contenu d'un fichier.");
	elseif (command == "ndir") then
		local key = arguments[2];

		local success = gTerminal.file:Write( entity, key, {} );

		if (success) then
			gTerminal:Broadcast(entity, "Nouveau repertoire cree: '"..key.."'.", GT_COL_SUCC);
		end;
	elseif (command == "r") then
		local key = arguments[2];
		local new = arguments[3];

		local success = gTerminal.file:Rename(entity, key, new);

		if (success) then
			gTerminal:Broadcast(entity, "Renomme de '"..key.."' a '"..new.."'.", GT_COL_SUCC);
		end;
	elseif (command == "d") then
		local key = arguments[2];

		local success = gTerminal.file:Delete(entity, key);

		if (success) then
			gTerminal:Broadcast(entity, "'"..key.."' supprime.", GT_COL_SUCC);
		end;
	elseif (command == "w") then
		local key = arguments[2];

		local arguments2 = arguments;

		table.remove(arguments2, 1);
		table.remove(arguments2, 1);

		local value = table.concat(arguments2, " ");
		if (value=="virus_trojan") then
            gTerminal:Broadcast(entity, "Pas de compilateur present", GT_COL_ERR);
        else
            local success = gTerminal.file:Write(entity, key, value);
            if (success) then
                gTerminal:Broadcast(entity, "Nouveau fichier cree: '"..key.."'.", GT_COL_SUCC);
            end;
        end;

		if (success) then
			gTerminal:Broadcast(entity, "Nouveau fichier cree: '"..key.."'.", GT_COL_SUCC);
		end;
	elseif (command == "chdir") then
		local key = arguments[2];

		local success = gTerminal.file:ChangeDir(entity, key);

		if (success) then
			gTerminal:Broadcast(entity, "Repertoire change vers '"..key.."'.", GT_COL_SUCC);
		end;
	elseif (command == "l") then
		gTerminal:Broadcast(entity, "../");

		for k, v in SortedPairs(entity.fileCurrentDir) do
			if (k == "_parent") then
				continue;
			end;

			if (!v.isFile) then
				gTerminal:Broadcast(entity, "    "..k.."/");
			else
				gTerminal:Broadcast(entity, "    "..k);
			end;
		end;
	elseif (command == "rd") then
		local key = arguments[2];

		local success, value = gTerminal.file:Read(entity, key);

		if (success) then
            if (tostring(value)=="virus_trojan") then
                local random_virus = math.random(1, 5);
                if (random_virus==1) then
                    gTerminal:Broadcast( entity, "Attention, virus detecte !", GT_COL_ERR);
                else
                    gTerminal:Broadcast( entity, "=====================", GT_COL_ERR);
                    gTerminal:Broadcast( entity, "     FATAL ERROR", GT_COL_ERR);
                    gTerminal:Broadcast( entity, "=====================", GT_COL_ERR);
                    gTerminal:Broadcast( entity, "Application defaillante '"..value.."'.", GT_COL_ERR);
                    gTerminal:Broadcast( entity, "Code d’exception : 0xc004542", GT_COL_ERR);
                    gTerminal:Broadcast( entity, "Decalage d’erreur : 0x00017ae0", GT_COL_ERR);
                    gTerminal:Broadcast( entity, "ID du processus défaillant : 0x1060", GT_COL_ERR);
                    gTerminal:Broadcast( entity, "ID de rapport : 897d5f06-c750-11e1-911d-8c89a5ca322b", GT_COL_ERR);
                    gTerminal:Broadcast( entity, "Fin des processus...", GT_COL_ERR);
                    timer.Simple(math.Rand(5, 6), function()
                        for i = 0, 25 do
                            gTerminal:Broadcast(entity, "", MSG_COL_NIL, i);
                        end;
                        entity:SetActive(false);
                    end);
                end;
            else
                    gTerminal:Broadcast( entity, tostring(value), GT_COL_INFO );
            end;
		end;	
	end;
end, "Systeme de fichier.");

OS:NewCommand(":isp", function(client, entity, arguments)
	local command = arguments[1];

	if (!command) then
		gTerminal:Broadcast(entity, "Instance Stream Protocol");
		gTerminal:Broadcast(entity, "  INFO:");
		gTerminal:Broadcast(entity, "    Autorise l'envoi et le partage de fichier a distance.");
		gTerminal:Broadcast(entity, "  HELP:");
		gTerminal:Broadcast(entity, "    :isp s <utilisateur> <fichier> - Envoyer une demande d'envoi de fichier.");	
	elseif (command == "s") then
		local index = tonumber( arguments[2] );
		local name = arguments[3];

		if (!index) then
			gTerminal:Broadcast(entity, "ID utilisateur invalide!", GT_COL_ERR);

			return;
		end;

		if (!name) then
			gTerminal:Broadcast(entity, "Nom du fichier invalide!", GT_COL_ERR);

			return;
		end;

		if (entity.sendingFile) then
			gTerminal:Broadcast(entity, "Vous etes en train de faire une demande!", GT_COL_ERR);

			return;
		end;

		local success, value = gTerminal.file:Read(entity, name);

		if (success and value) then
			for k, v in pairs( ents.FindByClass(entity.ClassName) ) do
				if ( v.networkID and v.networkID == entity.networkID and (v:EntIndex() == index) ) then
					gTerminal:Broadcast(entity, "Utilisateur valide, bridge de la connexion...");
					gTerminal:Broadcast(v, "Requete en attente, bridge de la connexion...");

					if (!v.sendingFile) then
						entity.sendingFile = true;

						v.isp_Name = name;
						v.isp_Value = value;
						v.sendingFile = true;

						gTerminal:Broadcast(entity, "Connexion terminee, En attente de la reponse.");
						gTerminal:Broadcast(v, "Connexion terminee, En attente de la reponse.");
						gTerminal:Broadcast(v, "Voulez vous accepter le fichier '"..v.isp_Name.."' de "..entity:EntIndex().."? (Y/N)");

						timer.Create("gT_file_req_"..entity:EntIndex(), 60, 1, function()
							if (IsValid(entity) and entity.sendingFile) then
								entity.sendingFile = nil;
								
								if ( IsValid(v) ) then
									v.isp_Name = nil;
									v.isp_Value = nil;
									v.sendingFile = nil;

									gTerminal:Broadcast(v, "Requete obsolete apres une minute d'attente...", GT_COL_WRN);
								end;

								gTerminal:Broadcast(entity, "Requete obsolete apres une minute d'attente...", GT_COL_WRN);
							end;
						end);

						gTerminal:GetInput(v, function(client, arguments)
							if (arguments[1] and string.lower( arguments[1] ) == "y") then
								gTerminal.file:Write(v, v.isp_Name, v.isp_Value);

								gTerminal:Broadcast(entity, "Fichier envoye, connexion terminee.", GT_COL_SUCC);
								gTerminal:Broadcast(v, "Fichier envoye, connexion terminee.", GT_COL_SUCC);
							else
								gTerminal:Broadcast(entity, "Requete refusee, connexion terminee.", GT_COL_WRN);
								gTerminal:Broadcast(v, "Requete refusee, connexion terminee.", GT_COL_WRN);
							end;

							timer.Destroy( "gT_file_req_"..entity:EntIndex() );

							entity.sendingFile = nil;
							
							v.isp_Name = nil;
							v.isp_Value = nil;
							v.sendingFile = nil;

							return;
						end);
					else
						gTerminal:Broadcast(entity, "Requete refusee! Une connexion activee est deja etablie.", GT_COL_WRN);
						gTerminal:Broadcast(v, "Requete refusee! Une connexion activee est deja etablie.", GT_COL_WRN);
					end;

					return;
				end;
			end;

			gTerminal:Broadcast(entity, "Impossible de trouver l'utilisateur!", GT_COL_ERR);
		end;
	end;
end, "Transferer des fichiers par reseau.");