local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FastSignal = require(ReplicatedStorage.Shared.FastSignal)
local LemonSignal = require(ReplicatedStorage.Shared.LemonSignal)
local Signal = require(ReplicatedStorage.Shared.Signal)

local ITERATIONS = 10_000

local function formatMemory(kb: number): string
	if kb == 0 then return "0 KB" end

	local value = kb
	local suffix = "KB"

	if kb >= 1024 * 1024 then
		value = kb / (1024 * 1024)
		suffix = "GB"
	elseif kb >= 1024 then
		value = kb / 1024
		suffix = "MB"
	end

	-- Format to 2 decimal places first
	local str = string.format("%.2f", value)

	-- If there is a dot, clean up trailing zeros
	if string.find(str, "%.") then
		-- Remove trailing zeros (e.g., "10.50" -> "10.5")
		str = string.gsub(str, "0+$", "")
		-- Remove trailing dot if it's now empty (e.g., "10." -> "10")
		str = string.gsub(str, "%.$", "")
	end

	return `{str} {suffix}`
end

-- This would been easier with collectgarbage("collect") :(
-- Run it multiple times and pick the run where the GC *didn't* interrupt.
local function getEstimatedAllocation(callback: () -> ())
	local maxAlloc = 0

	for _ = 1, 10 do
		local before = gcinfo()

		callback()

		local after = gcinfo()
		local diff = after - before

		-- If diff is negative, GC ran mid-test. Ignore it.
		-- We want the LARGEST positive difference (worst case = true allocation (maybe))
		if diff > maxAlloc then maxAlloc = diff end

		-- Yield to let Roblox's GC run if it needs to
		task.wait()
	end

	return maxAlloc
end

local function measure(name: string, newFunction: () -> Signal.Signal<...any>)
	print(`--- {name} ---`)

	local newAllow = getEstimatedAllocation(function()
		for _ = 1, ITERATIONS do
			newFunction()
		end
	end)
	print(`new: {formatMemory(newAllow)}`)

	local connectAlloc = getEstimatedAllocation(function()
		local sig = newFunction()

		for _ = 1, ITERATIONS do
			sig:Connect(function() end)
		end

		sig:Destroy()
	end)
	print(`Connect: {formatMemory(connectAlloc)}`)

	local fireSig = newFunction()
	fireSig:Connect(function() end)

	local fireAlloc = getEstimatedAllocation(function()
		for _ = 1, ITERATIONS do
			fireSig:Fire("Test", 123, true)
		end
	end)

	fireSig:Destroy()
	print(`Fire: {formatMemory(fireAlloc)}`)

	local fireSigVar = newFunction()
	fireSigVar:Connect(function() end, "VAR ARGS", 1000, true, false)

	local fireAllocVar = getEstimatedAllocation(function()
		for _ = 1, ITERATIONS do
			fireSigVar:Fire("Test", 123, true)
		end
	end)

	fireSigVar:Destroy()
	print(`Fire var args: {formatMemory(fireAllocVar)}`)
end

local function measureFireSync(newFunction: () -> Signal.Signal<...any>)
	local fireSig = newFunction()
	fireSig:Connect(function() end)

	local fireAlloc = getEstimatedAllocation(function()
		for _ = 1, ITERATIONS do
			fireSig:FireSync("Test", 123, true)
		end
	end)

	fireSig:Destroy()
	print(`FireSync: {formatMemory(fireAlloc)}`)

	local fireSigVar = newFunction()
	fireSigVar:Connect(function() end, "VAR ARGS", 1000, true, false)

	local fireAllocVar = getEstimatedAllocation(function()
		for _ = 1, ITERATIONS do
			fireSigVar:FireSync("Test", 123, true)
		end
	end)

	fireSigVar:Destroy()
	print(`FireSync var args: {formatMemory(fireAllocVar)}`)
end

-- The order of the benchmarks does not matter, the results are consistent.
print(`--------- Starting Benchmark - Iterations: {ITERATIONS} ---------`)
for i = 1, 3 do
	if i == 1 then
		measure("LemonSignal", LemonSignal.new :: any)
		measure("Signal", Signal.new)
		measureFireSync(Signal.new)
		measure("Signal Priority", Signal.newPriority)
		measureFireSync(Signal.newPriority)
		measure("FastSignal", FastSignal.new :: any)

		task.wait(0.2)
		print(`---------------------------------------------------------------`)
	elseif i == 2 then
		measure("Signal", Signal.new)
		measureFireSync(Signal.new)
		measure("Signal Priority", Signal.newPriority)
		measureFireSync(Signal.newPriority)
		measure("LemonSignal", LemonSignal.new :: any)
		measure("FastSignal", FastSignal.new :: any)

		task.wait(0.2)
		print(`---------------------------------------------------------------`)
	elseif i == 3 then
		measure("FastSignal", FastSignal.new :: any)
		measure("LemonSignal", LemonSignal.new :: any)
		measure("Signal", Signal.new)
		measureFireSync(Signal.new)
		measure("Signal Priority", Signal.newPriority)
		measureFireSync(Signal.newPriority)

		task.wait(0.2)
		print(`---------------------------------------------------------------`)
	end
end

--[[
3 Consecutive outputs with diferent order
There can be memory variations from 1-3KB but overall it's pretty accurate.

--------- Starting Benchmark - Iterations: 10000 ---------  
--- LemonSignal ---  
new: 782 KB  
Connect: 3.36 MB  
Fire: 0 KB  
Fire var args: 938 KB  
--- Signal ---  
new: 782 KB  
Connect: 2.9 MB  
Fire: 0 KB  
Fire var args: 0 KB  
FireSync: 0 KB  
FireSync var args: 1 KB  
--- Signal Priority ---  
new: 782 KB  
Connect: 2.9 MB  
Fire: 0 KB  
Fire var args: 0 KB  
FireSync: 0 KB  
FireSync var args: 1 KB  
--- FastSignal ---  
new: 1.07 MB  
Connect: 3.97 MB  
Fire: 11.14 MB  
Fire var args: 11.14 MB  
---------------------------------------------------------------  
--- Signal ---  
new: 782 KB  
Connect: 2.9 MB  
Fire: 0 KB  
Fire var args: 0 KB  
FireSync: 0 KB  
FireSync var args: 0 KB  
--- Signal Priority ---  
new: 782 KB  
Connect: 2.9 MB  
Fire: 0 KB  
Fire var args: 0 KB  
FireSync: 0 KB  
FireSync var args: 0 KB  
--- LemonSignal ---  
new: 782 KB  
Connect: 3.36 MB  
Fire: 0 KB  
Fire var args: 938 KB  
--- FastSignal ---  
new: 1.07 MB  
Connect: 3.97 MB  
Fire: 11.14 MB  
Fire var args: 11.14 MB  
---------------------------------------------------------------  
--- FastSignal ---  
new: 1.07 MB  
Connect: 3.97 MB  
Fire: 11.14 MB  
Fire var args: 11.14 MB  
--- LemonSignal ---  
new: 782 KB  
Connect: 3.36 MB  
Fire: 0 KB  
Fire var args: 938 KB  
--- Signal ---  
new: 782 KB  
Connect: 2.9 MB  
Fire: 0 KB  
Fire var args: 0 KB  
FireSync: 0 KB  
FireSync var args: 0 KB  
--- Signal Priority ---  
new: 782 KB  
Connect: 2.9 MB  
Fire: 0 KB  
Fire var args: 0 KB  
FireSync: 0 KB  
FireSync var args: 0 KB  
---------------------------------------------------------------  
]]
--
