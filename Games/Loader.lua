if (not game:IsLoaded()) then
    repeat game.Loaded:Wait() until game:IsLoaded();
end;

local PlayersService     = game:GetService("Players")
local MarketplaceService = game.GetService(game, "MarketplaceService");
local game_name          = MarketplaceService:GetProductInfo(game['PlaceId'])["Name"];
local executor_name      = identifyexecutor and identifyexecutor() or "Unknown";
local http               = game.HttpGet;
local load_string        = loadstring;
local msgbox             = messageboxasync or messagebox;
local base_url           = "https://raw.githubusercontent.com/sentineland/Sentinel/refs/heads/main/Games/";

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

    loader.message = function(text, title)
        local ok, res = pcall(msgbox, text, title, 4);
        if (not ok) then
            loader.kick("[" .. executor_name .. "] Message execution failed - " .. tostring(text));
        end;
        return res;
    end;

    loader.fetch = function(script_url)
        local ok, res = pcall(http, game, script_url);
        if (not ok or type(res) ~= "string") then
            loader.message(
                "Failed to fetch script\nURL: " .. script_url,
                "[" .. executor_name .. "]"
            );
            task.wait(9e9);
        end;

        local chunk, err = load_string(res);
        if (not chunk) then
            loader.message(
                "Script parse failed\n" .. tostring(err),
                "[" .. executor_name .. "]"
            );
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
                end;

                for _, exec in ipairs(data.executors) do
                    if (executor_name:match(exec)) then
                        return gname;
                    end;
                end;

                local choice = loader.message(
                    "Executor (" .. executor_name .. ") is not officially supported for: " .. gname .. "\nContinue anyway?",
                    "[" .. executor_name .. "] Unsupported executor"
                );

                if (choice == 6) then
                    return gname;
                end;

                return nil;
            end;
        end;

        local clean_game = loader.clean(game_name);
        local choice = loader.message(
            "No script is officially supported for this game: " .. clean_game .. "\nAre you sure you want to load the universal loader?",
            "[" .. executor_name .. "] Universal Loader"
        );

        if (choice == 6) then
            return "universal";
        else
            return nil;
        end;
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
