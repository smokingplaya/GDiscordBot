require("gwsockets")

GDiscordBot = {}
GDiscordBot.Bots = {}

local bot_metatable = {}
bot_metatable.__index = bot_metatable

function GDiscordBot.Client()
	local client = {
		_number = #GDiscordBot.Bots+1,
		_token = "",
		_events = {}
	}

	setmetatable(client, bot_metatable)

	GDiscordBot.Bots[client._number] = client

	return client
end

function bot_metatable:on(event, fn)
	self._events[event] = fn
end

local payloads = {
    heartbeat = [[
        {
            "op":1,
            "d":"null"
        }
    ]],
    auth = [[
    {
        "op": 2,
        "d": {
            "token": %q,
            "properties":
            {
                "os": "linux",
                "browser": "disco",
                "device": "disco"
            },
            "presence": {
                "activities": [{
                    "name": "%s",
                    "type": 0
                }],
                "status": "online",
                "since": %u,
                "afk": false
            }
        }
    }
    ]]
}

local responses = {
	[0] = function(socket, msg, json)
		if not json.t then end

		local events = socket._bot._events
		local event = events[json.t]

        if json.t == "READY" then
            table.Merge(socket._bot, json.d)
        end

		if isfunction(event) then
			event(json)
		end
	end,

	[10] = function(socket, msg, json)
        socket:write(Format(payloads.auth, socket._bot._token, "Garry's Mod", os.time()))
        socket:write(payloads.heartbeat)
        timer.Create("DiscordWebSocket", json["d"]["heartbeat_interval"]/1000, 0, function()
            if not socket:isConnected() then timer.Remove("DiscordWebSocket") return end

            socket:write(payloads.heartbeat)
        end)
    end,
}

function bot_metatable:login(token)
	self._token = token
	self._socket = GWSockets.createWebSocket("wss://gateway.discord.gg/?v=9&encording=json")
	self._socket._bot = self
	self._socket.onMessage = function(self, msg)
		local json = util.JSONToTable(msg)

		if json.op and responses[json.op]  then
            responses[json.op](self, msg, json)
        end
	end

	self._socket:open()
end