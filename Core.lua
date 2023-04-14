local Addon, Core = ...

-- Vars

local colorTable = {
    ['yellow'] = '|c00ffff00',
    ['green'] = '|c0000ff00',
    ['orange'] = '|c00ffc400',
    ['red'] = '|c00ff0000'
}

local InterfaceVersion = select(4, GetBuildInfo())
Core.Wrath = InterfaceVersion >= 30400
Core.Era = InterfaceVersion <= 20000

Core.Modules = {}
Core.Sub = {}
Core.RegisterModule = function(name, meta, options, default, func)
    table.insert(
        Core.Modules,
        {
            ['name'] = name,
            ['meta'] = meta,
            ['options'] = options,
            ['default'] = default,
            ['func'] = func
        }
    )
end
