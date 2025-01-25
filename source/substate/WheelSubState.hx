package substate;

import abilities.equipment.Equipment;
import abilities.equipment.items.BasicProjectileShootingItem;
import abilities.equipment.items.SwordItem;
import entity.PlayerEntity;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import sound.FootstepManager.MultiSoundManager;
import util.Language;

class WheelSubState extends FlxSubState {

    var wheel:FlxSprite = new FlxSprite(0,0,AssetPaths.wheel_of_fortune__png);
    var screen:FlxSprite = new FlxSprite(0,0,AssetPaths.wheelscreen__png);
    var point:FlxSprite = new FlxSprite(0,0,AssetPaths.pointer__png);
	public var playerReminder:FlxText = new FlxText(0, 0, 0, "Player: Player 0\nPress [A] to use!", 32);
	public var token:FlxSprite = new FlxSprite(0, 0, AssetPaths.token__png);
	public var amountText:FlxText = new FlxText(0, 0, 0, "0", 24 * 3);

	var weaponMap:Map<Int, Class<Equipment>> = new Map();

	override public function new(player:PlayerEntity)
	{
		super();
		p = player;
	}
    override function create() {
        super.create();
        wheel.scale.set(7.5,7.5);
        wheel.updateHitbox();
        wheel.screenCenter(Y);
        wheel.x -= 128*7.5;
        add(wheel);
        screen.screenCenter();
        screen.x += 128*3;
        add(screen);
        point.screenCenter();
        add(point);
		playerReminder.x = screen.x + (13);
		playerReminder.y = screen.y + (220);
		playerReminder.color = FlxColor.BLACK;
		amountText.color = FlxColor.BLACK;
		add(playerReminder);
		add(token);
		add(amountText);
		weaponMap.set(0, BasicProjectileShootingItem);
		weaponMap.set(45, SwordItem);
		weaponMap.set(45 + 45, BasicProjectileShootingItem);
		weaponMap.set(45 + 45 + 45, SwordItem);
		weaponMap.set(45 + 45 + 45 + 45, BasicProjectileShootingItem);
		weaponMap.set(45 + 45 + 45 + 45 + 45, SwordItem);
		weaponMap.set(45 + 45 + 45 + 45 + 45 + 45, BasicProjectileShootingItem);
		weaponMap.set(45 + 45 + 45 + 45 + 45 + 45 + 45, SwordItem);
		var idiotProofing:FlxSprite = new FlxSprite(FlxG.width - 200, FlxG.height - 100, AssetPaths.exittip__png);
		idiotProofing.scale.set(2, 2);
		add(idiotProofing);
		add(Main.subtitlesBox);
    }
    var portion = 0;
    var nextAngleSwitch = 45;
	var gambaTime = -1.0;
	var p:PlayerEntity;

    override function destroy() {
        FlxTween.cancelTweensOf(point);
		FlxTween.cancelTweensOf(amountText);
		remove(Main.subtitlesBox);
        super.destroy();
    }
    override function update(elapsed:Float) {
		Main.detectConnections();
        if (wheel.angle >= nextAngleSwitch) {
			portion = Math.round((wheel.angle) / 45) * 45;
			nextAngleSwitch = portion + 45;
			trace(nextAngleSwitch);
			trace(wheel.angle);
			point.angle = -11;
			MultiSoundManager.playRandomSoundByItself(Main.audioPanner.x, Main.audioPanner.y, "wheel", FlxG.random.float(0.9, 1.1), 0.6);
			FlxTween.tween(point, {angle: 0}, 0.25, {ease: FlxEase.sineOut});
		}
		var startRoll = false;
		if (FlxG.state is PlayState)
		{
			var ps:PlayState = cast(FlxG.state);
			ps.playerLayer.forEachOfType(PlayerEntity, (pe) ->
			{
				if (pe.input.ui_accept)
				{
					if (p == pe)
					{
						startRoll = true;
					}
					if (gambaTime < 0 && p != pe)
					{
						p = pe;
					}
				}
			});
		}
		playerReminder.color = FlxColor.BLACK;
		playerReminder.text = StringTools.replace(StringTools.replace(Language.get("hint.slotMachine"), "%1", p.entityName), "%2", p.input.uiAcceptName());
        for (source in Main.activeInputs)
        {
			if (source.ui_deny)
			{
				if (gambaTime < 0)
				{
					close();
				}
			}
		}
		token.x = playerReminder.x;
		token.y = playerReminder.getGraphicBounds().bottom + 2;
		token.scale.set(5, 5);
		token.updateHitbox();
		amountText.x = playerReminder.x + token.width + 10;
		amountText.y = token.y;
		amountText.text = p.tokens + "/5";
		if (gambaTime > 0)
		{
			wheel.angle += elapsed * gambaTime;
		}
		else
		{
			gambaTime = -1;
		}
		if (p.handWeapon == null && p.holsteredWeapon == null)
		{
			amountText.text = "FREE!";
			amountText.color = FlxColor.LIME;
		}
		if (p.handWeapon != null && p.holsteredWeapon != null)
		{
			playerReminder.text = playerReminder.text.split("\n")[0] + "\nWill override primary!";
			playerReminder.color = FlxColor.RED;
		}
		if (startRoll)
		{
			if (((p.handWeapon == null && p.holsteredWeapon == null) || p.tokens > 4) && gambaTime < 0)
			{
				if (p.tokens > 4)
				{
					p.tokens -= 5;
				}
				gambaTime = FlxG.random.float(160, 2000);
				FlxTween.tween(this, {gambaTime: 0}, 5, {
					ease: FlxEase.smootherStepOut,
					onComplete: (t) ->
					{
						if (p.handWeapon == null)
						{
							p.handWeapon = Type.createInstance(weaponMap.get(portion % 360), [p]);
						}
						else
						{
							if (p.holsteredWeapon == null)
							{
								p.holsteredWeapon = Type.createInstance(weaponMap.get(portion % 360), [p]);
							}
							else
							{
								p.handWeapon = Type.createInstance(weaponMap.get(portion % 360), [p]);
							}
						}
					}
				});
			}
			else
			{
				amountText.color = FlxColor.RED;
				FlxTween.color(amountText, 0.65, FlxColor.RED, FlxColor.BLACK, {ease: FlxEase.sineOut});
			}
		}
        super.update(elapsed);
    }

}

