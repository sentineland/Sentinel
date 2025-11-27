local typeface = { };

do
    typeface.Incompatible = function() typeface.Denied = true end;
    isfile                = isfile or typeface.Incompatible();
    isfolder              = isfolder or typeface.Incompatible();
    writefile             = writefile or typeface.Incompatible();
    makefolder            = makefolder or typeface.Incompatible();
    getcustomasset        = getcustomasset or typeface.Incompatible();
end;

local Http = cloneref and cloneref(game:GetService('HttpService')) or game:GetService('HttpService');

typeface.typefaces = { };

function typeface:register(Path, Asset)
    if typeface.Denied then return end;
    if not Asset or not Asset.name or not Asset.link then return end;

    local Directory = `{Path}/{Asset.name}`;
    local FontPath = `{Directory}/{Asset.name}.font`;
    local JSONPath = `{Directory}/{Asset.name}Families.json`;

    if not isfolder(Directory) then makefolder(Directory) end;
    if not isfile(FontPath) then writefile(FontPath, game:HttpGet(Asset.link)) end;

    if not isfile(JSONPath) then
        writefile(JSONPath, Http:JSONEncode({name=Asset.name, faces={{name="Regular", weight=400, style="normal", assetId=getcustomasset(FontPath)}}}));
    end;

    if not typeface.typefaces[Asset.name] then
        typeface.typefaces[Asset.name] = Font.new(getcustomasset(JSONPath));
    end;

    return typeface.typefaces[Asset.name];
end;

return typeface;
