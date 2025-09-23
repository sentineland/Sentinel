if (not game:IsLoaded()) then
    repeat game.Loaded:Wait() until game:IsLoaded();
end;

local PlayersService     = game:GetService(game, "Players");
local MarketplaceService = game:GetService(game, "MarketplaceService");
local game_name          = MarketplaceService:GetProductInfo(game.PlaceId).Name;
local executor_name      = identifyexecutor and identifyexecutor() or "Unknown";
local msgbox             = messageboxasync or messagebox;
local base_url           = "https://raw.githubusercontent.com/sentineland/Sentinel/refs/heads/main/Games/";

local games = {};
do
    games["fallen survival"] = {
        status = "undetected";
        executors = { "Wave", "MacSploit", "Potassium", "Zenith" };
    };
end

local loader = {};
do
    loader.fatal = function(msg)
        PlayersService.LocalPlayer:Kick(msg);
        task.wait(9e9);
    end;

    loader.verify = function(fn, name)
        if (type(fn) ~= "function") then
            loader.fatal("[" .. executor_name .. "] Missing functionality (" .. name .. ") - unsupported executor");
        end;
        return fn;
    end;

    loader.message = function(text, title, id)
        local fn = loader.verify(msgbox, "messagebox");
        local ok, res = pcall(fn, text, title, id);
        if (not ok) then
            loader.fatal("[" .. executor_name .. "] Message execution error - " .. tostring(text));
        end;
        return res;
    end;

    loader.fetch = function(url)
        local req_fn  = loader.verify(request, "request");
        local load_fn = loader.verify(loadstring, "loadstring");

        local ok, res = pcall(req_fn, { Url = url; Method = "GET" });
        if (not ok or not res or type(res.Body) ~= "string" or res.StatusCode ~= 200) then
            loader.message("Failed to retrieve script\n\nURL: " .. url, "[" .. executor_name .. "]", 48);
            task.wait(9e9);
        end;

        local chunk, err = load_fn(res.Body);
        if (not chunk) then
            loader.message("Script parse failed\n\n" .. tostring(err), "[" .. executor_name .. "]", 48);
            task.wait(9e9);
        end;

        return chunk();
    end;

    loader.select = function(name)
        local clean_name = name:gsub("[^a-zA-Z0-9%s]", ""):lower():match("^%s*(.-)%s*$");

        for gname, data in pairs(games) do
            if (clean_name:find(gname:lower(), 1, true)) then
                if (data.status == "updating") then
                    loader.fatal("[" .. executor_name .. "] " .. gname .. " script is updating.");
                end;

                for _, exec in ipairs(data.executors) do
                    if (executor_name:match(exec)) then
                        return gname;
                    end;
                end;

                local choice = loader.message(
                    "Executor (" .. executor_name .. ") is not officially supported for: " .. gname .. "\n\nContinue anyway?";
                    "[" .. executor_name .. "] Unsupported executor";
                    4
                );

                if (choice == 6) then
                    return gname;
                end;

                return nil;
            end;
        end;

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
