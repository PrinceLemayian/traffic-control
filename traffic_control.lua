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
