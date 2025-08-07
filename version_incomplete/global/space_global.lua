SetEnvHandler = function(value, handler)
    for i = 1, 65536 do
        local name, upvalue = debug.getupvalue(value, i)
        if name == "_ENV" then
            -- 对_ENV进行代理
            local proxy_env = setmetatable({}, {
                __index = function(_, k)
                    return handler.get(upvalue, k)
                end;
                __newindex = function(_, k, v)
                    handler.set(upvalue, k, v)
                end;
            })
            -- 创建一个闭包，使其第一个上值为proxy_env
            local proxy_closure = function()
                local _ = proxy_env
            end
            debug.upvaluejoin(value, i, proxy_closure, 1) -- 使用proxy_closure的第一个上值替换_ENV
        end
        if name == nil or name == "_ENV" then
            break
        end
    end
    return value
end

Space = function(instance)
    local handler = {
        get = function(env, key)
            return instance[key] or env[key] -- 如果在instance中找不到，则从_ENV中查找
        end;
        set = function(env, key, value)
            instance[key] = value -- 将设置全局变量的操作代理到instance中
        end;
    }

    for _, v in pairs(instance) do
        if (type(v) == "function") then
            SetEnvHandler(v, handler)
        end
    end
    return setmetatable({}, {
        __index = function(_, key)
            return instance[key]
        end;
        __newindex = function(_, key, value)
            if(type(value) == "function") then
                value = SetEnvHandler(value, instance) -- 如果value是函数，则设置_ENV
            end
            instance[key] = value
        end;
    })
end