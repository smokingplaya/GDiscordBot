# GDiscordBot v0.1
*Idea created by [Jaffies](https://github.com/Jaffies)*

It's convenient and easy. You can create your own discordbot right in the game!

So far, there's not much you can do.

# Dependencies
* [GWSockets](https://github.com/FredyH/GWSockets)

**Example**

```lua
local bot = GDiscordBot.Client()

bot:on("READY", function(json)
    print(Format("Logged in as \"%s\" (%s)", bot.user.username, bot.user.id))
end)

bot:on("MESSAGE_CREATE", function(msg)
	PrintTable(msg)
end)

bot:login("token")
```
