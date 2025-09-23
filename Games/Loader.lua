if (not game:IsLoaded()) then
    repeat game.Loaded:Wait() until game:IsLoaded();
end;

local PlayersService     = game:GetService(game, "Players");
local MarketplaceService = game:GetService(game, "MarketplaceService");
local game_name          = MarketplaceService:GetProductInfo(game.PlaceId).Name;
local executor_name      = identifyexecutor and identifyexecutor() or "Unknown";
local fetch_fn           = game.HttpGet;
local load_fn            = loadstring;
local msgbox_fn          = messageboxasync or messagebox;
local base_url           = "https://raw.githubusercontent.com/sentineland/Sentinel/refs/heads/main/Games/";

if (not fetch_fn) then
    PlayersService.LocalPlayer:Kick("[" .. executor_name .. "] Missing HttpGet function - unsupported executor");
end;
if (not load_fn) then
    PlayersService.LocalPlayer:Kick("[" .. executor_name .. "] Missing loadstring function - unsupported executor");
end;
if (not msgbox_fn) then
    PlayersService.LocalPlayer:Kick("[" .. executor_name .. "] Missing messagebox function - unsupported executor");
end;

local games = {};
do
    games["fallen survival"] = {
        status    = "undetected";
        executors = { "Wave", "MacSploit", "Potassium", "Zenith" };
    };
end

local loader = {};
do
    loader.kick = function(msg)
        PlayersService.LocalPlayer:Kick(msg);
        task.wait(9e9);
    end;

    loader.message = function(text, title, id)
        local ok, res = pcall(msgbox_fn, text, title, id);
        if (not ok) then
            loader.kick("[" .. executor_name .. "] Message execution failed - " .. tostring(text));
        end;
        return res;
    end;

    loader.fetch = function(url)
        local ok, res = pcall(fetch_fn, game, url);
        if (not ok or type(res) ~= "string") then
            loader.message("Failed to fetch script\nURL: " .. url, "[" .. executor_name .. "]", 48);
            task.wait(9e9);
        end;
        local chunk, err = load_fn(res);
        if (not chunk) then
            loader.message("Script parse failed\n" .. tostring(err), "[" .. executor_name .. "]", 48);
            task.wait(9e9);
        end;
        return chunk();
    end;

    loader.clean = function(name)
        return name:gsub("[^%w%s]", ""):lower():match("^%s*(.-)%s*$");
    end;

    loader.select = function(name)
        local clean_name = loader.clean(name);
        for gname, data in pairs(games) do
            if (clean_name:find(gname:lower(), 1, true)) then
                if (data.status == "updating") then
                    loader.kick("[" .. executor_name .. "] " .. gname .. " script is updating.");
                end
                for _, exec in ipairs(data.executors) do
                    if (executor_name:match(exec)) then
                        return gname;
                    end
                end
                local choice = loader.message(
                    "Executor (" .. executor_name .. ") is not officially supported for: " .. gname .. "\nContinue anyway?";
                    "[" .. executor_name .. "] Unsupported executor";
                    4
                );
                if (choice == 6) then return gname; end
                return nil;
            end
        end
        loader.message("No specific loader found for this game. Using universal loader.", "[" .. executor_name .. "] Universal Loader", 48);
        return "universal";
    end;
end

do
    local selected_game = loader.select(game_name);
    if (selected_game == "fallen survival") then
        loader.fetch(base_url .. "Fallen.lua");
    elseif (selected_game == "universal") then
        loader.fetch(base_url .. "Universal.lua");
    end;
end
