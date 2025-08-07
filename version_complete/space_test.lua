require("./space")

local test = function()
    print(this.key)
    super.new_test = function()
        print(this.key)
    end
end;
local module = Space {
    key = "value";
    main = function()
        this.inner_module = SpaceExtend(this) {
            key = "inner_value";
            main = test
        }

    end;
}

module.main()

module.inner_module.main()

module.new_test()
