SetEnvProxy = function(value, proxy_closure)
    for i = 1, 65536 do
        local name, upvalue = debug.getupvalue(value, i)
        if name == "_ENV" then
            debug.upvaluejoin(value, i, proxy_closure, 1) -- 使用proxy_closure的第一个上值替换_ENV
        end
        if name == nil or name == "_ENV" then
            break
        end
    end
    return value
end

Space = function(instance, parent)
    local proxy_instance
    local handle_keyword_index = function(key)
        if key == "this" then
            return proxy_instance
        end
        if key == "super" then
            return parent
        end
    end
    local handle_keyword_newindex = function(key)
        if key == "this" then
            error("Cannot rewrite 'this'") -- 禁止重写this
        end
        if key == "super" then
            error("Cannot rewrite 'super'") -- 禁止重写super
        end
    end
    local proxy_env = setmetatable({}, {
        __index = function(_, key)
            return handle_keyword_index(key) or _ENV[key] -- 否则返回_ENV中的对应值
        end;
        __newindex = function(_, key, value)
            handle_keyword_newindex(key)
            _ENV[key] = value
        end;
    })
    -- 创建一个闭包，使其第一个上值为proxy_env
    local proxy_closure = function()
        local _ = proxy_env
    end

    -- 对instance的操作代理
    proxy_instance = setmetatable({}, {
        __index = function(_, key)
            return handle_keyword_index(key) or instance[key]
        end;
        __newindex = function(_, key, value)
            handle_keyword_newindex(key)
            if (type(value) == "function") then
                value = SetEnvProxy(value, proxy_closure) -- 如果value是函数，则设置_ENV
            end
            instance[key] = value -- 将设置全局变量的操作代理到instance中
        end;
    })

    for _, value in pairs(instance) do
        if (type(value) == "function") then
            SetEnvProxy(value, proxy_closure)
        end
    end
    return proxy_instance
end

SpaceExtend = function(parent)
    return function(instance)
        return Space(instance, parent)
    end
end