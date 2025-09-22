if (not game:IsLoaded()) then
    repeat game.Loaded:Wait() until game:IsLoaded();
end;

local players       = game.GetService(game, "Players");
local market        = game.GetService(game, "MarketplaceService");
local game_name     = market:GetProductInfo(game['PlaceId'])["Name"];
local executor 		= identifyexecutor and identifyexecutor() or 'Unknown';
local path          = "https://raw.githubusercontent.com/sentineland/Sentinel/refs/heads/main/Games/";

local game_list = {};
game_list['fallen survival'] = {
    status    = 'undetected',
    executors = { 'Wave', 'MacSploit', 'Potassium', 'Zenith' }
};

local load_game = function(game_name, game_list, status, executor)
    game_name = game_name:gsub("[^a-zA-Z0-9%s]", ""):lower():match("^%s*(.-)%s*$");

    for v, data in pairs(game_list) do
        if game_name:find(v:lower(), 1, true) then
            if (data.status == 'updating') then
                status["LocalPlayer"]:Kick('[Radiance] ' .. v .. " script is updating.");
                return;
            end;
            for _, exec in ipairs(data.executors) do
                if executor:match(exec) then
                    return v;
                end;
            end;
            status["LocalPlayer"]:Kick('[Radiance] Executor not supported.');
            return;
        end;
    end;
    return "universal";
end;

local found = load_game(game_name, game_list, players, executor);
do
    if (found == "fallen survival") then
        local dir = game:HttpGetAsync(path.."Fallen.lua");
        loadstring(dir)();
    --[[elseif (found == "trident survival") then
        local dir = game:HttpGetAsync(path.."trident.lua");
        loadstring(dir)();
    elseif (found == "rivals") then
        local dir = game:HttpGetAsync(path.."rivals.lua");
        loadstring(dir)();]]
    elseif (found == "universal") then
        local dir = game:HttpGetAsync(path.."Universal.lua");
        loadstring(dir)();
    end;
end;
