local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FastSignal = require(ReplicatedStorage.Shared.FastSignal)
local LemonSignal = require(ReplicatedStorage.Shared.LemonSignal)
local Signal = require(ReplicatedStorage.Shared.Signal)

return {
	ParameterGenerator = function() end,

	Functions = {
		["LemonSignal"] = function(Profiler, fn)
			Profiler.Begin("New")
			local sig = LemonSignal.new()
			Profiler.End()

			Profiler.Begin("Connect")
			local cn = sig:Connect(fn)
			Profiler.End()

			Profiler.Begin("Disconnect")
			cn:Disconnect()
			Profiler.End()

			Profiler.Begin("Reconnect")
			cn:Reconnect()
			Profiler.End()

			Profiler.Begin("Once")
			sig:Once(fn)
			Profiler.End()

			Profiler.Begin("5 Connects")
			for _ = 1, 5 do
				sig:Connect(fn)
			end
			Profiler.End()

			Profiler.Begin("Fire")
			sig:Fire("TestString", 123.456, true)
			Profiler.End()

			Profiler.Begin("DisconnectAll")
			sig:DisconnectAll()
			Profiler.End()

			Profiler.Begin("Destroy")
			sig:Destroy()
			Profiler.End()
		end,

		["FastSignal"] = function(Profiler, fn)
			Profiler.Begin("New")
			local sig = FastSignal.new()
			Profiler.End()

			Profiler.Begin("Connect")
			local cn = sig:Connect(fn)
			Profiler.End()

			Profiler.Begin("Disconnect")
			cn:Disconnect()
			Profiler.End()

			Profiler.Begin("Once")
			sig:Once(fn)
			Profiler.End()

			Profiler.Begin("5 Connects")
			for _ = 1, 5 do
				sig:Connect(fn)
			end
			Profiler.End()

			Profiler.Begin("Fire")
			sig:Fire("TestString", 123.456, true)
			Profiler.End()

			Profiler.Begin("DisconnectAll")
			sig:DisconnectAll()
			Profiler.End()

			Profiler.Begin("Destroy")
			sig:Destroy()
			Profiler.End()
		end,

		["Signal"] = function(Profiler, fn)
			Profiler.Begin("New")
			local sig = Signal.new()
			Profiler.End()

			Profiler.Begin("Connect")
			local cn = sig:Connect(fn)
			Profiler.End()

			Profiler.Begin("Disconnect")
			cn:Disconnect()
			Profiler.End()

			Profiler.Begin("Reconnect")
			cn:Reconnect()
			Profiler.End()

			Profiler.Begin("Once")
			sig:Once(fn)
			Profiler.End()

			Profiler.Begin("5 Connects")
			for _ = 1, 5 do
				sig:Connect(fn)
			end
			Profiler.End()

			Profiler.Begin("Fire")
			sig:Fire("TestString", 123.456, true)
			Profiler.End()

			Profiler.Begin("DisconnectAll")
			sig:DisconnectAll()
			Profiler.End()

			Profiler.Begin("Destroy")
			sig:Destroy()
			Profiler.End()
		end,

		["Signal Priority"] = function(Profiler, fn)
			Profiler.Begin("New")
			local sig = Signal.newPriority()
			Profiler.End()

			Profiler.Begin("ConnectPriority")
			local cn = sig:ConnectPriority(1, fn)
			Profiler.End()

			Profiler.Begin("Disconnect")
			cn:Disconnect()
			Profiler.End()

			Profiler.Begin("Reconnect")
			cn:Reconnect()
			Profiler.End()

			Profiler.Begin("OncePriority")
			sig:OncePriority(1, fn)
			Profiler.End()

			Profiler.Begin("5 Connects")
			for _ = 1, 5 do
				sig:Connect(fn)
			end
			Profiler.End()

			Profiler.Begin("Fire")
			sig:Fire("TestString", 123.456, true)
			Profiler.End()

			Profiler.Begin("DisconnectAll")
			sig:DisconnectAll()
			Profiler.End()

			Profiler.Begin("Destroy")
			sig:Destroy()
			Profiler.End()
		end,
	},
}
