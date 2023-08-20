local lfs = require "lfs"
local DEST_FOLDER = "media"
local MOD_FOLDER = "/mnt/c/Users/Enrico/Zomboid/mods/todoz/"
function table.contains(tbl, x)
    local found = false
    for _, v in pairs(tbl) do if v == x then found = true end end
    return found
end

-- http://lua-users.org/wiki/FileInputOutput

-- see if the file exists
function file_exists(file)
    local f = io.open(file, "rb")
    if f then f:close() end
    return f ~= nil
end

-- get all lines from a file, returns an empty
-- list/table if the file does not exist
function lines_from(file)
    if not file_exists(file) then return {} end
    local lines = {}
    for line in io.lines(file) do lines[#lines + 1] = line end
    return lines
end

function build(path)
    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." then
            local f = path .. '/' .. file
            local attr = lfs.attributes(f)
            assert(type(attr) == "table")
            if attr.mode == "directory" then
                if not (string.find(f, "^%./%.git") or string.find(f, "^%./media") or
                        string.find(f, "^%./src/lua/test")) then
                    lfs.mkdir(MOD_FOLDER .. f:gsub("src", DEST_FOLDER))
                    build(f)
                end
            elseif (path ~= ".") then
                local ls = lines_from(f)
                local destFilePath = MOD_FOLDER .. path:gsub("src", DEST_FOLDER) .. "/" ..
                    file
               --  print(destFilePath)
                local destFile = io.open(destFilePath, "w")
                if destFile ~= nil then
                    for k, v in pairs(ls) do
                        if string.find(v, "[\"\']src%.lua%.client.-[\"\']") then
                            v = string.gsub(v, "[\"\']src%.lua%.client.-[\"\']",
                                function(t1)
                                    return t1:gsub("%.", "/"):gsub("src/lua/client/", "")
                                end)
                        end
                        destFile:write(v .. "\n")
                    end
                    destFile:close()
                end
            end
        end
    end
end

lfs.rmdir(MOD_FOLDER .. DEST_FOLDER)
lfs.mkdir(MOD_FOLDER .. DEST_FOLDER)
build("./src")
print("Build in dest folder [" .. MOD_FOLDER .. DEST_FOLDER .. "]\nOK")
