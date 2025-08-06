SetEnvProxy = function(value, proxy_closure)
    assert(type(value) == "function", "value must be a function")
    assert(type(proxy_closure) == "function", "proxy_closure must be a function")
    assert(type(debug.getupvalue(proxy_closure, 1)) == "table", "proxy_closure's first upvalue must be a table")
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
    assert(type(instance) == "table", "instance must be a table")
    assert(parent == nil or type(parent) == "table", "parent must be a table or nil")
    local proxy_env = setmetatable({}, {
        __index = function(_, k)
            if k == "this" then
                return instance -- 如果访问this，则返回instance
            end
            if k == "super" then
                return parent -- 如果访问super，则返回parent
            end
            return _ENV[k] -- 否则返回_ENV中的对应值
        end;
        __newindex = function(_, k, v)
            _ENV[k] = v
        end;
    })
    -- 创建一个闭包，使其第一个上值为proxy_env
    local proxy_closure = function()
        local _ = proxy_env
    end

    for _, v in pairs(instance) do
        if (type(v) == "function") then
            SetEnvProxy(v, proxy_closure)
        end
    end
    -- 处理外部访问模块的情况，将访问和修改代理到instance中
    return setmetatable({}, {
        __index = function(_, key)
            if key == "this" then
                return instance -- 如果访问this，则返回instance
            end
            if key == "super" then
                return parent
            end
            return instance[key] -- 否则返回instance中的对应值
        end;
        __newindex = function(_, key, value)
            if (type(value) == "function") then
                value = SetEnvProxy(value, proxy_closure) -- 如果value是函数，则修改其_ENV
            end
            instance[key] = value -- 将设置全局变量的操作代理到instance中
        end;
    })
end

SpaceExtend = function(parent)
    return function(instance)
        return Space(instance, parent)
    end
end