include("sh_init.lua");
include("sv_filesystem.lua");

AddCSLuaFile("sh_init.lua");

util.AddNetworkString("gT_ActiveConsole");
util.AddNetworkString("gT_EndConsole");
util.AddNetworkString("gT_AddLine");
util.AddNetworkString("gT_EndTyping");

gTerminal = gTerminal or {};
gTerminal.os = gTerminal.os or {};

local gTerminal = gTerminal;
local net = net;

function gTerminal.os:Call(entity, name, ...)
	if ( IsValid(entity) ) then
		local key = entity:GetOS();
		local system = gTerminal.os[key];

		if (IsValid(entity) and system and system[name] and type( system[name] ) == "function") then
			local success, value = pcall(system[name], system, entity, ...);

			if (success) then
				return value;
			end;
		end;
	end;
end;

function gTerminal:Broadcast(entity, text, colorType, position)
	if ( !IsValid(entity) ) then
		return;
	end;

	local index = entity:EntIndex();
	local output;

	if (string.len(text) > 50) then
		output = {};

		local expected = math.floor(string.len(text) / 50);

		for i = 0, expected do
			output[i + 1] = string.sub(text, i * 50, (i * 50) + 49);
		end;
	end;

	if (output) then
		for k, v in ipairs(output) do
			net.Start("gT_AddLine");
				net.WriteUInt(index, 16);
				net.WriteString(v);
				net.WriteUInt(colorType or GT_COL_MSG, 8);

				if (position) then
					net.WriteInt(position + (k - 1), 16);
				else
					net.WriteInt(-1, 16);
				end;
			net.Broadcast();
		end;
	else
		net.Start("gT_AddLine");
			net.WriteUInt(index, 16);
			net.WriteString(text);
			net.WriteUInt(colorType or GT_COL_MSG, 8);
			net.WriteInt(position or -1, 16);
		net.Broadcast();
	end;
end;

function gTerminal:GetInput(entity, Callback)
	entity.acceptingInput = true;
	entity.inputCallback = Callback;
end;

net.Receive("gT_EndConsole", function(length, client)
	local index = net.ReadUInt(16);
	local entity = Entity(index);
	local text = net.ReadString();

	if (IsValid(entity) and entity.GetUser and IsValid( entity:GetUser() ) and entity:GetUser() == client) then
		if (text == "" or text == " ") then
			entity:SetUser(nil);

			net.Start("gT_EndTyping");
			net.Send(client);

			return;
		end;
		
		if ( entity.password and !client["pass_authed_"..index] ) then
			local fail = math.Rand(1,3)
			if (text == entity.password) then
				client["pass_authed_"..index] = true;

				gTerminal:Broadcast(entity, "Mot de passe accepte.");

				return;
			elseif (text == ":hackpass") and (fail != 3) then	--Ici la commande :hackpass n'est pas soumise au code
			entity.password = nil;
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
				"Recherche des fichiers",
				"Decryptage des donnes",
				"Probelmes rencontres",
				"Destruction de l'anti-virus",
				"Detournement des pare-feu",
				"Code retrouvé",
				"Destruction du code ...",
			};

			 local time = math.Rand(10, 15);

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
		gTerminal:Broadcast(entity, "Mot de passe detruit, ordinateur libre :) .");
								end;
							end;
						end;
					end;
				end);
			end;
		end);
			else
				gTerminal:Broadcast(entity, "Entrez votre mot de passe:");

				return;
			end;
		end;

		if (string.sub(text, 1, 1) == ":") then
			local system = gTerminal.os[ entity:GetOS() ];

			if (system) then
				for k, v in pairs( system:GetCommands() ) do
					local command = string.sub( string.lower(text), 1, string.len(k) );
					
					if (k == command) then
						local text2 = string.sub(text, string.len(command) + 2);
						local quote = (string.sub(text2, 1, 1) != "\"");
						local arguments = {};

						for chunk in string.gmatch(text2, "[^\"]+") do
							quote = !quote;

							if (quote) then
								table.insert(arguments, chunk);
							else
								for chunk in string.gmatch(chunk, "[^ ]+") do
									table.insert(arguments, chunk);
								end;
							end;
						end;

						local success, value = pcall(v.Callback, client, entity, arguments);

						if (success) then
							gTerminal:Broadcast(entity, text, GT_COL_CMD);
						else
							gTerminal:Broadcast(entity, value, GT_COL_ERR);
						end;

						return;
					end;
				end;

				text = "Invalid command! ("..string.sub(text, 2)..")";
			else
				gTerminal:Broadcast(entity, "Erreur systeme provoque par entree utilisateur!", GT_COL_INTL);

				return;
			end;
		end;

		if (entity.acceptingInput) then
			local quote = (string.sub(text, 1, 1) != "\"");
			local arguments = {};

			for chunk in string.gmatch(text, "[^\"]+") do
				quote = !quote;

				if (quote) then
					table.insert(arguments, chunk);
				else
					for chunk in string.gmatch(chunk, "[^ ]+") do
						table.insert(arguments, chunk);
					end;
				end;
			end;

			local Callback = entity.inputCallback;

			if (Callback and arguments) then
				Callback(client, arguments);
			end;

			entity.acceptingInput = nil;
			entity.inputCallback = nil;

			return;
		end;

		local finalized = string.lower( entity:GetUser():Name() ).."@"..entity:EntIndex().." => "..tostring(text);

		gTerminal:Broadcast(entity, finalized, GT_COL_NIL);
	end;
end);

local files, folders = file.Find("gterminal/os/*", "LUA");

for k, v in pairs(folders) do
	OS = {};
		OS.commands = {};

		function OS:NewCommand(name, Callback, help)
			self.commands[name] = {Callback = Callback, help = help};
		end;

		function OS:GetCommands()
			return self.commands;
		end;
		
		include("os/"..v.."/sv_init.lua");

		gTerminal.os[ OS:GetUniqueID() ] = OS;
	OS = nil;
end;

MsgC(Color(0, 255, 0), "gTerminal initialise!\n");
