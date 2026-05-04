--- @since 26.1.22
--- Paste selected/yanked files using rsync for incremental sync.

local get_data = ya.sync(function()
	local tab = cx.active
	local urls = {}

	for _, u in pairs(tab.selected) do
		urls[#urls + 1] = tostring(u)
	end

	if #urls == 0 then
		for i, url in pairs(cx.yanked) do
			urls[i] = tostring(url)
		end
	end

	if #urls == 0 and tab.current.hovered then
		urls[1] = tostring(tab.current.hovered.url)
	end

	return { urls = urls, cwd = tostring(tab.current.cwd) }
end)

local function notify(title, content, level, timeout)
	ya.notify {
		title = title,
		content = content,
		level = level or "info",
		timeout = timeout or 3,
	}
end

local function mode_label(overwrite, move)
	if move then return "Move" end
	if overwrite then return "Overwrite" end
	return "Incremental"
end

return {
	entry = function(self, job)
		local data = get_data()
		if #data.urls == 0 then
			notify("Rsync Paste", "No files to sync", "warn", 3)
			return
		end

		ya.emit("escape", { visual = true })

		local overwrite, move = false, false
		if job.args then
			for _, arg in ipairs(job.args) do
				if arg == "-o" then overwrite = true end
				if arg == "-m" then move = true end
			end
		end

		local mode = mode_label(overwrite, move)

		local cmd = Command("rsync")
		cmd = cmd:arg("-a"):arg("-hh")
		if not overwrite then
			cmd = cmd:arg("--update")
		end
		if move then
			cmd = cmd:arg("--remove-source-files")
		end
		for _, url in ipairs(data.urls) do
			cmd = cmd:arg(url)
		end
		cmd = cmd:arg(data.cwd .. "/")

		local result, err = cmd:output()
		if not result then
			notify("Rsync Paste (" .. mode .. ")", "Failed to run rsync: " .. (err or "is rsync installed?"), "error", 5)
			return
		end
		if not result.status.success then
			local msg = (result.stderr or ""):gmatch("[^\r\n]+")()
			notify("Rsync Paste (" .. mode .. ")", "rsync error: " .. (msg or "unknown"), "warn", 5)
			return
		end

		local count = 0
		for line in result.stdout:gmatch("[^\r\n]+") do
			if line ~= "" and not line:match("^sending") and not line:match("^sent") and not line:match("^total") then
				count = count + 1
			end
		end

		notify("Rsync Paste (" .. mode .. ")", ("Synced %d file(s)"):format(count > 0 and count or #data.urls), "info", 3)
		ya.emit("cd", {})
	end,
}
