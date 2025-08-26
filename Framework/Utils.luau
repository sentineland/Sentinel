local utils = {
    modules = {},
    instances = {}
};

do -- functions
    local modules = utils.modules;
    
    modules.getservice = function(...)
        local services = {};
        for i, name in ipairs({...}) do
            services[i] = cloneref(game.GetService(game, name));
        end;
        return unpack(services);
    end;
    getservice = modules.getservice; 
    -- 
    modules.instance_new = function(class, properties)
        local _instance = Instance.new(class);
        for _property, _value in next, properties do
            _instance[_property] = _value;
        end;
        table.insert(utils.instances, _instance);
        return _instance;
    end;
    instance_new = modules.instance_new;
    --
    modules.unload = function()
        for _, instance in pairs(utils.instances) do
            instance:Destroy();
        end;
        utils.instances = {}; 
    end;
    unload = modules.unload;
    --
    modules.tween = function(obj, props, dur, style, dir)
        local tween = game.GetService(game, "TweenService"):Create(obj, TweenInfo.new(
            dur or 0.5,
            style or Enum.EasingStyle.Linear,
            dir or Enum.EasingDirection.InOut
        ), props);
        tween:Play();
        return tween;
    end;
    tween = modules.tween;
end;
--
return utils;
