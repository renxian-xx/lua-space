require("space_global")

local module = Space {
    key = "value";
    main = function()
        local inner_module = Space {
            main = function()
                print(key) -- 可以访问到外层作用域的key
            end;
        }
        inner_module.main() -- 调用内层模块的main函数
    end;
}

module.main()

