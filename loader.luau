local BASE = "https://raw.githubusercontent.com/vrcdev/AllWaffle/main/"
local REPO_BASE = "https://raw.githubusercontent.com/vrcdev/"

do
	local q = queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport)
	if q then
		pcall(q, 'loadstring(game:HttpGet("https://raw.githubusercontent.com/vrcdev/AllWaffle/main/loader.luau"))()')
	end
end

local function fetch(url)
	local ok, r = pcall(game.HttpGet, game, url)
	if ok and type(r) == "string" and #r > 0 then return r end
	if httpget then
		ok, r = pcall(httpget, url)
		if ok and type(r) == "string" and #r > 0 then return r end
	end
	local req = request or http_request or (http and http.request) or (syn and syn.request)
	if req then
		ok, r = pcall(req, {Url = url, Method = "GET"})
		if ok and type(r) == "table" and type(r.Body) == "string" and #r.Body > 0 then return r.Body end
	end
	return nil
end

local manifestSrc = fetch(BASE .. "manifest.json")
local manifest
if manifestSrc then
	manifest = pcall(function()
		return game:GetService("HttpService"):JSONDecode(manifestSrc)
	end) and game:GetService("HttpService"):JSONDecode(manifestSrc) or nil
end

local repo = nil
local placeId = tostring(game.PlaceId)
if manifest and manifest.places then
	repo = manifest.places[placeId]
end

if not repo then
	local name = ""
	pcall(function()
		name = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or ""
	end)
	name = name:lower()
	local names = manifest and manifest.names or {}
	if not next(names) then
		names = {
			frontlines = "FrontlinesWaffle", rivals = "RivalsWaffle",
			siege = "OppoWaffle", hood = "HoodWaffle", criminality = "HoodWaffle",
			reloaded = "ReloadedWaffle", phantom = "PhantomWaffle", valoblox = "ValobloxWaffle",
		}
	end
	for needle, r in pairs(names) do
		if name:find(needle, 1, true) then repo = r break end
	end
end

if not repo then
	warn("[waffle] no waffle for this game (place " .. placeId .. ")")
	return
end

print("[waffle] " .. placeId .. " -> " .. repo)
local src = fetch(REPO_BASE .. repo .. "/main/loader.luau")
if not src then
	warn("[waffle] loader fetch failed: " .. repo)
	return
end
local f, e = loadstring(src)
if not f then
	warn("[waffle] loader compile:", e)
	return
end
local ok, err = pcall(f)
print("[waffle] booted " .. repo .. ":", ok, err)
