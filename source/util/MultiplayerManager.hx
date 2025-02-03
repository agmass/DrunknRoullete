package util;

import entity.PlayerEntity;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import input.InputSource;
import input.ModifiableInputSource;
import input.OnlinePlayerSource;
import io.colyseus.Client;
import io.colyseus.Room;
import io.colyseus.error.HttpException;
import schema.MyRoomState;
import state.MidState;
import substate.PauseSubState;
import substate.SlotsSubState;
import substate.WheelSubState;

class MultiplayerManager
{
	public var client:Client;
	public var room:Room<MyRoomState>;

	public function new()
	{
		client = new Client("ws://localhost:2567");
		Main.randomProvider = new ServerDecidedRandom();
	}

	public function joinNewGame(id:String)
	{
		client.joinById(id, [], MyRoomState, multiplayerCode);
	}

	public var ourConnectedInputs:Map<Int, InputSource> = new Map<Int, InputSource>();
	public var doNotReconnect:Array<InputSource> = [];

	var isHost = false;
	var serverSubstate = "";
	var serverState = "";

	public function hostNewGame()
	{
		client.create("my_room", [], MyRoomState, multiplayerCode);
	}

	static var ociSize = 0;

	public function update()
	{
		if (!isHost)
		{
			for (source in doNotReconnect)
			{
				source.allowedToOpenMenus = false;
			}
		}
		if (isHost)
		{
			for (source in doNotReconnect)
			{
				source.allowedToOpenMenus = true;
			}
			if (FlxG.state.subState == null && serverSubstate != "close")
			{
				serverSubstate = "close";
				room.send("openSubState", {state: "close"});
			}

			if (FlxG.state.subState != null && FlxG.state is PlayState)
			{
				if (FlxG.state.subState is SlotsSubState && serverSubstate != "slots")
				{
					var s:SlotsSubState = cast(FlxG.state.subState);
					serverSubstate = "slots";
					room.send("openSubState", {state: "slots", playerId: idMap.get(s.p.input)});
				}

				if (FlxG.state.subState is WheelSubState && serverSubstate != "wheel")
				{
					var s:WheelSubState = cast(FlxG.state.subState);
					serverSubstate = "wheel";
					room.send("openSubState", {state: "wheel", playerId: idMap.get(s.p.input)});
				}
			}
		}
		for (source in Main.activeInputs)
		{
			if (!(source is OnlinePlayerSource))
			{
				if (!doNotReconnect.contains(source))
				{
					doNotReconnect.push(source);
					ourConnectedInputs.set(ociSize, source);
					idMap.set(source, room.sessionId + "___" + ociSize);
					room.send("addInput", ociSize);
					ociSize++;
				}
			}
		}
		sendInputPacket();
	}

	public function sendInputPacket()
	{
		for (index => value in Main.multiplayerManager.ourConnectedInputs)
		{
			var px = 0.0;
			var py = 0.0;
			if (FlxG.state is PlayState)
			{
				var ps:PlayState = cast(FlxG.state);
				ps.playerLayer.forEachOfType(PlayerEntity, (p) ->
				{
					if (p.input == value)
					{
						px = p.x;
						py = p.y;
					}
				});
			}
			if (!(FlxG.state.subState is PauseSubState))
			{
				Main.multiplayerManager.room.send("inputUpdate", {
					inputID: index,
					jumpPressed: value.jumpPressed,
					dashPressed: value.dashPressed,
					backslotPressed: value.backslotPressed,
					attackPressed: value.attackPressed,
					ui_denyPressed: value.ui_hold_deny,
					ui_menuPressed: value.ui_hold_menu,
					ui_acceptPressed: value.ui_hold_accept,
					interactPressed: value.interactFirePressed,
					altFirePressed: value.altFirePressed,
					movement_x: value.getMovementVector().x,
					movement_y: value.getMovementVector().y,
					x: px,
					y: py,
					angle: value.getLookAngle(new FlxPoint(px, py))
				});
			}
		}
	}

	public var initseed = 0;
	public var curseed = 0;

	public var idMap:Map<InputSource, String> = new Map();

	public function multiplayerCode(err:HttpException, room:Room<MyRoomState>)
	{
		if (err != null)
		{
			trace("JOIN ERROR: " + err);
			return;
		}

		this.room = room;

		room.state.listen("seed", (c, p) ->
		{
			cast(Main.randomProvider, ServerDecidedRandom).cappedSeed = c;
		});
		room.state.listen("inseed", (c, p) ->
		{
			Main.randomProvider.initialSeed = c;
		});
		room.state.listen("hostId", (c, p) ->
		{
			isHost = c == room.sessionId;
		});
		room.state.listen("currentState", (c, p) ->
		{
			if (c == "")
			{
				FlxG.switchState(new PlayState());
			}
			if (c == "mid")
			{
				FlxG.switchState(new MidState());
			}
			serverState = c;
		});

		room.onMessage("refreshFile", (message) ->
		{
			if (!isHost)
			{
				MidState.readArbitrarySaveFile(true, message);
			}
		});
		room.onMessage("openSubState", (message) ->
		{
			if (isHost)
				return;
			if (message.state == "close")
			{
				FlxG.state.closeSubState();
				serverSubstate = message.state;
			}
			if (message.state == "paused")
			{
				FlxG.state.openSubState(new PauseSubState());
				serverSubstate = message.state;
			}
			if (message.playerId != null)
			{
				if (FlxG.state is PlayState)
				{
					trace("playerid not null, playstate");
					var ps:PlayState = cast(FlxG.state);
					var target:PlayerEntity = null;
					var targetSource:InputSource = null;
					for (key => value in idMap)
					{
						if (value == message.playerId)
							targetSource = key;
					}
					ps.playerLayer.forEachOfType(PlayerEntity, (p) ->
					{
						if (p.input == targetSource)
						{
							target = p;
						}
					});
					if (target != null)
					{
						trace("target not null");
						if (message.state == "wheel")
						{
							FlxG.state.openSubState(new WheelSubState(target));
							serverSubstate = message.state;
						}
						if (message.state == "slots")
						{
							FlxG.state.openSubState(new SlotsSubState(target));
							serverSubstate = message.state;
						}
					}
				}
			}
		});

		room.state.players.onAdd(function(entity, key)
		{
			if (!StringTools.startsWith(key, room.sessionId))
			{
				var source = new OnlinePlayerSource();
				Main.activeInputs.push(source);
				idMap.set(source, key);

				var player:PlayerEntity = null;

				entity.listen("x", (c, p) ->
				{
					if (player == null || !player.exists)
					{
						if (FlxG.state is PlayState)
						{
							var ps:PlayState = cast(FlxG.state);
							ps.playerLayer.forEachOfType(PlayerEntity, (p) ->
							{
								if (p.input == source)
								{
									player = p;
								}
							});
						}
					}
					if (player != null)
					{
						player.x = c;
					}
				});

				entity.listen("y", (c, p) ->
				{
					if (player == null || !player.exists)
					{
						if (FlxG.state is PlayState)
						{
							var ps:PlayState = cast(FlxG.state);
							ps.playerLayer.forEachOfType(PlayerEntity, (p) ->
							{
								if (p.input == source)
								{
									player = p;
								}
							});
						}
					}
					if (player != null)
					{
						player.y = c;
					}
				});

				entity.listen("jumpPressed", (c, p) ->
				{
					source.jumpPressed = c;
					source.jumpJustPressedTwo = c;
				});
				entity.listen("backslotPressed", (c, p) ->
				{
					source.backslotJustPressedTwo = c;
					source.backslotPressed = c;
				});
				entity.listen("ui_acceptPressed", (c, p) ->
				{
					source.ui_acceptTwo = c;
					source.ui_hold_accept = c;
				});
				entity.listen("interactPressed", (c, p) ->
				{
					source.interactFirePressed = c;
					source.interactJustPressedTwo = c;
				});
				entity.listen("ui_menuPressed", (c, p) ->
				{
					source.ui_menuTwo = c;
				});
				entity.listen("movement_x", (c, p) ->
				{
					source.movement = source.movement.set(c, source.movement.y);
				});
				entity.listen("angle", (c, p) ->
				{
					source.look = c;
				});
				entity.listen("movement_y", (c, p) ->
				{
					source.movement = source.movement.set(source.movement.x, c);
				});
				entity.listen("ui_denyPressed", (c, p) ->
				{
					source.ui_denyTwo = c;
				});
				entity.listen("attackPressed", (c, p) ->
				{
					source.attackJustPressedTwo = c;
					source.attackPressed = c;
				});
				entity.listen("dashPressed", (c, p) ->
				{
					source.dashJustPressedTwo = c;
					source.dashPressed = c;
				});
			}
		});
	}
}