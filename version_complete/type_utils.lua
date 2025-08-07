IsFunction = function(value)
    return type(value) == "function"
end

IsString = function(value)
    return type(value) == "string"
end

IsNumber = function(value)
    return type(value) == "number"
end

IsTable = function(value)
    return type(value) == "table"
end

IsBoolean = function(value)
    return type(value) == "boolean"
end

IsNil = function(value)
    return value == nil
end

AssertType = function(value, expected_type, name, level)
    if not IsString(expected_type) then
        error("expected_type must be a string, got " .. type(expected_type))
    end
    if name ~= nil and not IsString(name) then
        error("name must be a string or nil, got " .. type(name))
    end
    if name ~= nil then
        if type(value) ~= expected_type then
            error(name .. " must be a " .. expected_type .. ", got " .. type(value), 2 + (level or 0))
        end
    else
        if type(value) ~= expected_type then
            error("expected " .. expected_type .. ", got " .. type(value), 2 + (level or 0))
        end
    end
end

AssertTypes = function(value, expected_types, name, level)
    AssertType(expected_types, "table", "expected_types", 1 + (level or 0))
    if name ~= nil and not IsString(name) then
        error("name must be a string or nil, got " .. type(name))
    end
    local value_type = type(value)
    for _, expected_type in ipairs(expected_types) do
        if value_type == expected_type then
            return true
        end
    end
    local expected_str = table.concat(expected_types, ", ")
    if name ~= nil then
        error(name .. " must be one of: " .. expected_str .. ", got " .. value_type, 2 + (level or 0))
    else
        error("expected one of: " .. expected_str .. ", got " .. value_type, 2 + (level or 0))
    end
end

AssertFunction = function(value, name, level)
    AssertType(value, "function", name, 1 + (level or 0))
end

AssertString = function(value, name, level)
    AssertType(value, "string", name, 1 + (level or 0))
end

AssertTable = function(value, name, level)
    AssertType(value, "table", name, 1 + (level or 0))
end

AssertBoolean = function(value, name, level)
    AssertType(value, "boolean", name, 1 + (level or 0))
end

AssertNumber = function(value, name, level)
    AssertType(value, "number", name, 1 + (level or 0))
end

AssertNil = function(value, name, level)
    AssertType(value, "nil", name, 1 + (level or 0))
end