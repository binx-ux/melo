local FILES = {
    "src/core.lua",
    "src/functions.lua",
    "src/screens.lua",
    "src/games.lua",
    "src/ui.lua",
    "src/boot.lua",
}
local BASE = "https://raw.githubusercontent.com/binx-ux/melo/main/"
local function readPart(path)
    if type(isfile) == "function" and type(readfile) == "function" and isfile(path) then
        return readfile(path)
    end
    local ok, src = pcall(function()
        return game:HttpGet(BASE .. path)
    end)
    if ok and type(src) == "string" and #src > 0 then
        return src
    end
    error("Melo could not read " .. path)
end
local chunks = {}
for i = 1, #FILES do
    chunks[i] = readPart(FILES[i])
end
local loader, err = loadstring(table.concat(chunks, "\n"))
if not loader then
    error(tostring(err))
end
loader()
