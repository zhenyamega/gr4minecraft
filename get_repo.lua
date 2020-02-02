local args = {...}
local debug = false

local json = loadfile("lib/json.lua")()
local split = loadfile("lib/split.lua")()

--[[ for debug
local print_table = loadfile("lib/print_table.lua")()
--]]

function get_url_files_repo(repo)
    return "https://api.github.com/repos/" .. repo .. "/contents/"
end

function get_data(repo)
    local handles, message, handles_error = http.get(repo)
    if handles == nil then
        handles = handles_error
    end

    local result = handles.readAll()
    handles.close()

    return result
end

function save_to_file(data, name_data)
    local handles = fs.open(name_data, "w")
    handles.write(data)
    handles.close()
end

function clearing_json(data)
    local result = {}

    -- lightweight processing
    for index, item in ipairs(data) do
        temp = {}

        temp["name"] = item["name"]
        temp["size"] = item["size"]
        temp["type"] = item["type"]
        temp["url"] = item["url"]
        temp["download_url"] = item["download_url"]

        result[index] = temp
    end

    -- processing dir
    for index, item in ipairs(result) do
        if item["type"] == "dir" then
            local temp = initialization(item["url"])

            result[index]["dir"] = clearing_json(temp)
        end
    end

    return result
end

function get_dir(data, main_dir)
    local temp = ""

    for index, item in ipairs(data) do
        if item["type"] == "file" then
            temp = get_data(item["download_url"])
            save_to_file(temp, main_dir .. "/" .. item["name"])
        elseif item["type"] == "dir" then
            get_dir(item["dir"], main_dir .. "/" .. item["name"])
        end
    end
end

function get_size_repo(data)
    result = 0

    for index, item in ipairs(data) do
        if item["type"] == "dir" then
            result = result + get_size_repo(item["dir"])
        else
            result = result + item["size"]
        end
    end

    return result
end

function get_repo(repo, data)
    -- interactive
    total_bytes = get_size_repo(data)
    print("In repository " .. total_bytes .. " bytes.")

    local main_dir = split.split(repo, "/")[2]

    if not fs.isDir(main_dir) then
        fs.makeDir(main_dir)
    end

    get_dir(data, main_dir)

    print("Done")
end

function initialization(url)
    local txt = get_data(url)
    local data = json.decode(txt)

    return data
end

local repo = ""
if debug then
    repo = "zhenyamega/gr4minecraft"
else
    repo = args[1]
end

local url_repo = get_url_files_repo(repo)

local data = initialization(url_repo)
if data["message"] ~= nil then
    print(data["message"])
    return
end

local list_file = clearing_json(data)

--save_to_file(json.encode(list_file), "result.json")
get_repo(repo, list_file)
