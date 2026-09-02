math.randomseed(42)

local ROADS = {
	{ name = "Thika Road", queue = 12, flow = 5, arrival = 3 },
	{ name = "Mombasa Road", queue = 7, flow = 4, arrival = 4 },
	{ name = "Ngong Road", queue = 2, flow = 2, arrival = 1 },
	{ name = "Waiyaki Way", queue = 9, flow = 4, arrival = 2 },
}

-- ── Scheduling constants ──────────────────────────────────────
local CONGESTION_W = 1.0
local FAIRNESS_W = 2.5
local STARVATION_LIMIT = 3
local SIM_CYCLES = 20

local function make_road(def)
	return coroutine.create(function(got_green)
		local queue = def.queue
		local waiting = 0

		while true do
			if got_green then
				queue = math.max(0, queue - def.flow)
				waiting = 0
			else
				waiting = waiting + 1
			end

			queue = queue + math.random(0, def.arrival * 2)

			got_green = coroutine.yield({
				name = def.name,
				queue = queue,
				waiting = waiting,
			})
		end
	end)
end

-- ── Scheduling logic ─────────────────────────────────────────

local function compute_score(s)
	return s.queue * CONGESTION_W + s.waiting * FAIRNESS_W
end

local function choose_green(states)
	local fi, fw = nil, -1
	for i, s in ipairs(states) do
		if s.waiting >= STARVATION_LIMIT and s.waiting > fw then
			fw, fi = s.waiting, i
		end
	end
	if fi then
		return fi, true
	end

	local bi, bs = 1, -math.huge
	for i, s in ipairs(states) do
		local sc = compute_score(s)
		if sc > bs then
			bs, bi = sc, i
		end
	end
	return bi, false
end

-- ── Display helpers ───────────────────────────────────────────

local W = 66

local function hr(c)
	return string.rep(c or "─", W)
end

local function log_cycle(cycle, states, win, forced)
	print(string.format("\n  ┌─ Cycle %02d", cycle))
	for i, s in ipairs(states) do
		local tag = ""
		if i == win then
			tag = forced and "  ◄ GREEN  ★ [starvation guard]" or "  ◄ GREEN"
		end
		local bar = string.rep("▪", math.min(s.queue, 24))
		print(string.format("  │  %-14s  q=%-3d  w=%d  %s%s", s.name, s.queue, s.waiting, bar, tag))
	end
end

local function log_summary(counts)
	print("\n" .. hr("═"))
	print("  FINAL ALLOCATION  —  green lights over " .. SIM_CYCLES .. " cycles")
	print(hr())
	local total = 0
	for _, r in ipairs(ROADS) do
		total = total + (counts[r.name] or 0)
	end
	for _, r in ipairs(ROADS) do
		local n = counts[r.name] or 0
		local pct = (total > 0) and math.floor(n / total * 100 + 0.5) or 0
		local bar = string.rep("▪", n)
		print(string.format("  %-14s  %2d  (%2d%%)  %s", r.name, n, pct, bar))
	end
	print(hr("═"))
end
