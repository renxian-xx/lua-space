为解决在GG（Game Guardian）脚本合并时出现的模块划分、变量污染等问题，开发的一个小框架。

incomplete为不完整版本，共有有两个版本：

关键字版本，space_keyword.lua:

- 支持在表中定义的函数能够通过`this`访问和修改表中的属性。
- 支持表的继承，让子表能够通过`super`访问和修改父表中的属性。

案例：

```lua
key = "global_value"
local module = Space {
    key = "value";
    main = function()
        -- 访问全局变量
        print(key) -- global_value
        -- 修改全局变量
        key = "new_global_value"
        print(key) -- new_global_value

        -- 访问模块属性
        print(this.key) -- value
        -- 修改模块属性
        this.key = "new_value"
        print(this.key) -- new_value

        -- 内部新增函数
        this.inner_test = function()
            print(this.key)
        end

        this.inner_module = SpaceExtend(this) {
            main = function()
                print(super.key) -- 访问父模块属性
            end;
        }

    end;
}

module.main()
module.inner_test() -- new_value

-- 外部新增函数
module.outer_test = function()
    print(this.key)
end

module.outer_test() -- new_value

print(module.key) -- new_value

module.inner_module.main() -- new_value
```

全局变量版本，space_global.lua:

- 让表中的函数直接访问和修改表中的属性，无需显示引用。

案例：

```lua
local module = Space {
    key = "value";
    main = function()
        -- 访问模块属性
        print(key) -- value
        -- 修改模块属性
        key = "new_value"
        print(key) -- new_value
    end
}

module.main()
-- 判断是否有全局变量key
print(key) -- nil
-- 访问模块属性
print(module.key) -- new_value
```

complete为完整版本（space.lua），在关键字版本（space_keyword.lua）的基础上进行完善，主要更新版本。