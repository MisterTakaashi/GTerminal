local gTerminal = gTerminal;

gTerminal.file = gTerminal.file or {};

function gTerminal.file:Initialize(entity)
	entity.fileCurrentDir = {};
end;

function gTerminal.file:ChangeDir(entity, key)
	local directory = entity.fileCurrentDir[key];

	if (key == "../") then
		if (entity.fileCurrentDir._parent) then
			directory = entity.fileCurrentDir._parent;
		end;
	end;

	if (directory and !directory.isFile) then
		entity.fileCurrentDir = directory;

		return true;
	end;

	gTerminal:Broadcast(entity, "Impossible de trouver le repertoire!");

	return false;
end;

function gTerminal.file:Write(entity, key, value)
	if (!entity.fileCurrentDir) then
		entity.fileCurrentDir = {};
	end;
	
	if (!key or key == "_parent") then
		gTerminal:Broadcast(entity, "Nom invalide!");

		return false;
	end;

	if ( entity.fileCurrentDir[key] ) then
		gTerminal:Broadcast(entity, "L'item existe deja!");

		return false;
	end;		

	if (!value) then
		gTerminal:Broadcast(entity, "Contenu invalide!");

		return false;
	end;

	if (type(value) != "table") then
		value2 = {
			isFile = true,
			value = value,
			_parent = entity.fileCurrentDir;
		};
	end;

	if (value2) then
		entity.fileCurrentDir[key] = value2;
	else
		value._parent = entity.fileCurrentDir;

		entity.fileCurrentDir[key] = value;
	end;

	return true;
end;

function gTerminal.file:Rename(entity, previous, new)
	if ( !previous or !entity.fileCurrentDir[previous] ) then
		gTerminal:Broadcast(entity, "Impossible de trouver le fichier/dossier!");

		return false;
	end;

	if (!new or new  == "_parent") then
		gTerminal:Broadcast(entity, "Nom de fichier/dossier non valide!");

		return false;
	end;

	entity.fileCurrentDir[new] = entity.fileCurrentDir[previous];
	entity.fileCurrentDir[previous] = nil;

	return true;
end;

function gTerminal.file:Delete(entity, key)
	if ( !key or key == "_parent" or !entity.fileCurrentDir[key] ) then
		gTerminal:Broadcast(entity, "Fichier/dossier invalide!");

		return false;
	end;

	entity.fileCurrentDir[key] = nil;

	return true;
end;

function gTerminal.file:Read(entity, key)
	if (!key or key == "_parent") then
		gTerminal:Broadcast(entity, "Nom invalide!");

		return false;
	end;

	if ( !entity.fileCurrentDir[key] ) then
		gTerminal:Broadcast(entity, "Fichier introuvable!");

		return false;
	end;

	if (!entity.fileCurrentDir[key].isFile or !entity.fileCurrentDir[key].value) then
		gTerminal:Broadcast(entity, "Type de lecture invalide!");

		return false;
	end;

	return true, entity.fileCurrentDir[key].value;
end;