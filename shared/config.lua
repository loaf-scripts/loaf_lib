Config = {
    HelpTextStyle = "gta", --[[
        valid options: 
            * luke - https://forum.cfx.re/t/standalone-free-text-ui/3987367
            * cd - https://forum.cfx.re/t/free-release-draw-text-ui/1885313
            * gta - https://i.gyazo.com/efe67de676ce26bf3d90972d6af7534a.png
            * 3d-gta - https://i.gyazo.com/cfa770414d21aced89e1f3d2003813a0.png
            * 3d - https://gyazo.com/0ad2bd85b8985bc3859d4c04a6712027
            * esx - https://github.com/esx-framework/esx-legacy/tree/main/%5Besx%5D/esx_textui
            * qbcore - https://github.com/qbcore-framework/qb-core
    ]]

    Distancescale3DText = false, -- true: 3d text will be distance based (draws a bit more cpu), false: 3d text will be the same size, no matter the distance
    DrawDistance = 100.0, -- marker draw distance
    DefaultColour = {125, 75, 195, 100}, -- default marker colour, r, g, b, a

    Keybindings = {
        ["primary"] = {
            defaultKey = "E",
            description = "Primary actions, default E"
        },
        ["secondary"] = {
            defaultKey = "G",
            description = "Secondary actions, default G"
        },
    },
}