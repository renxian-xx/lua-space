require("space")

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