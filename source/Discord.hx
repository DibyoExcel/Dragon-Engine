package;

//thank M.A jigsaw for hxdiscord_rpc
#if desktop
import hxdiscord_rpc.Discord;
import hxdiscord_rpc.Types;
import sys.thread.Thread;
import lime.app.Application;
#end

#if LUA_ALLOWED
import llua.Lua;
import llua.State;
#end


class DiscordClient
{
	#if desktop
    public static var isInitialized:Bool = false;

    public static function initialize():Void
    {
        Sys.println("Discord Client starting...");

        final handlers:DiscordEventHandlers = new DiscordEventHandlers();
        handlers.ready = cpp.Function.fromStaticFunction(onReady);
        handlers.disconnected = cpp.Function.fromStaticFunction(onDisconnected);
        handlers.errored = cpp.Function.fromStaticFunction(onError);

        Discord.Initialize("1301540053843050556", cpp.RawPointer.addressOf(handlers), false, null);

        Thread.create(function():Void
        {
            while (true)
            {
                #if DISCORD_DISABLE_IO_THREAD
                Discord.UpdateConnection();
                #end

                Discord.RunCallbacks();
                Sys.sleep(2);
            }
        });

        isInitialized = true;
        Sys.println("Discord Client initialized");
    }

    public static function shutdown():Void
    {
        Discord.Shutdown();
        Sys.println("Discord Client shutdown");
    }

    private static function onReady(request:cpp.RawConstPointer<DiscordUser>):Void
    {
        final username:String = request[0].username;
        final discriminator:Int = Std.parseInt(request[0].discriminator);

        if (discriminator != 0)
            Sys.println('Discord: Connected to user ${username}#${discriminator}');
        else
            Sys.println('Discord: Connected to user ${username}');

        // Set initial presence
        final presence:DiscordRichPresence = new DiscordRichPresence();
        presence.details = "In the Menus";
        presence.state = null;
        presence.largeImageKey = "draconicmods";
        presence.largeImageText = "Dragon Engine v" + Application.current.meta.get("version");
		final button:DiscordButton = new DiscordButton();
		button.label = "Download";
		button.url = "https://github.com/DibyoExcel/Dragon-Engine/";
		presence.buttons[0] = button;

		final button:DiscordButton = new DiscordButton();
		button.label = "Documentation";
		button.url = "https://dibyoexcel.github.io/Dragon-Engine/";
		presence.buttons[1] = button;

        Discord.UpdatePresence(cpp.RawPointer.addressOf(presence));
    }

    private static function onError(errorCode:Int, message:cpp.ConstCharStar):Void
    {
        Sys.println('Error! $errorCode : ${message.toString()}');
    }

    private static function onDisconnected(errorCode:Int, message:cpp.ConstCharStar):Void
    {
        Sys.println('Disconnected! $errorCode : ${message.toString()}');
    }

    public static function changePresence(details:String, state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float):Void
    {
        var startTimestamp:Float = if (hasStartTimestamp) Date.now().getTime() else 0;

        if (endTimestamp > 0)
        {
            endTimestamp = startTimestamp + endTimestamp;
        }

        final presence:DiscordRichPresence = new DiscordRichPresence();
        presence.details = details;
        presence.state = state;
        presence.largeImageKey = "draconicmods";
        presence.largeImageText = "Dragon Engine v" + Application.current.meta.get("version");
        presence.smallImageKey = smallImageKey;
        presence.startTimestamp = Std.int(startTimestamp / 1000);
        presence.endTimestamp = Std.int(endTimestamp / 1000);
		
		final button:DiscordButton = new DiscordButton();
		button.label = "Download";
		button.url = "https://github.com/DibyoExcel/Dragon-Engine/";
		presence.buttons[0] = button;

		final button:DiscordButton = new DiscordButton();
		button.label = "Documentation";
		button.url = "https://dibyoexcel.github.io/Dragon-Engine/";
		presence.buttons[1] = button;

        Discord.UpdatePresence(cpp.RawPointer.addressOf(presence));

        Sys.println('Discord RPC Updated. Arguments: $details, $state, $smallImageKey, $hasStartTimestamp, $endTimestamp');
    }
	#end
	public static function addLuaCallbacks(lua:State):Void {
        #if LUA_ALLOWED
		Lua_helper.add_callback(lua, "changePresence", 
			function(details:String, state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float) {
				#if desktop
				changePresence(details, state, smallImageKey, hasStartTimestamp, endTimestamp);
				#end
			}
		);
        #end
	}
	
}
