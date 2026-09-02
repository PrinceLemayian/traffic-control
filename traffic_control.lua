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
