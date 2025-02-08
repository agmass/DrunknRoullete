package entity.bosses;

import abilities.attributes.Attribute;
import abilities.equipment.items.Gamblevolver;
import abilities.equipment.items.SwordItem;
import backgrounds.LobbyBackground;
import flixel.FlxG;
import flixel.addons.text.FlxTypeText;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import objects.DroppedItem;
import objects.hitbox.ExplosionHitbox;
import objects.hitbox.Hitbox;
import openfl.filters.ShaderFilter;
import shader.CRTLinesShader;

class TutorialBoss extends Entity
{
	var dialouge:FlxTypeText = new FlxTypeText(0, 0, 0, "", 28);
	var face:FlxText = new FlxText(0, 0, 0, "z_z", 100);

	public var hitboxes:FlxTypedSpriteGroup<Hitbox> = new FlxTypedSpriteGroup();
	var lastState = 0;
	var speed = 0.25;

	override public function new(x, y)
	{
		super(x, y);
		manuallyUpdateSize = true;
		makeGraphic(750, 500, FlxColor.BLACK);
		face.shader = new CRTLinesShader();
		setSize(750, 500);
	}
	var breathing:Float = 0.0;
	var timeDialougeMap:Map<Int, Void->Void> = new Map();

	override function createAttributes()
	{
		super.createAttributes();
		attributes.set(Attribute.MAX_HEALTH, new Attribute(550, true));
	}

	var dying = false;

	override function damage(amount:Float, attacker:Entity)
	{
		if (!dying)
			super.damage(amount, attacker);
	}

	var explosionCooldown = 0.2;
	override function update(elapsed:Float)
	{
		if (health <= 0 && ragdoll == null)
		{
			health = 600;
			dying = true;
			face.text = "X_X";
		}
		if (dying)
		{
			explosionCooldown -= elapsed;
			if (explosionCooldown <= 0)
			{
				speed += 1;
				explosionCooldown = 0.2;
				var explosion:ExplosionHitbox = new ExplosionHitbox(FlxG.random.float(x, x + width), FlxG.random.float(y, y + height), 0);
				hitboxes.add(explosion);
			}
		}
		hitboxes.update(elapsed);

		for (hitbox in hitboxes)
		{
			if (hitbox.inactive)
			{
				hitboxes.remove(hitbox);
				hitbox.destroy();
			}
		}
		velocity.x = velocity.y = 0;
		if (lastState == -1 && LobbyBackground.state == 1)
		{
			LobbyBackground.elapsedTimeInState = 0;
			dialouge.size = 96;
			dialouge.resetText("HUH?");
			dialouge.start(0.015);
			var gilbert = new EquippedEntity(-100, -100);
			timeDialougeMap.set(0, () ->
			{
				face.text = "O_O";
				speed = 25;
			});
			timeDialougeMap.set(2000, () ->
			{
				speed = 0.25;
				dialouge.resetText("Give Weapon 1");
				face.text = "@_@";
				dialouge.size = 28;
				dialouge.start(0.05);
				var ps:PlayState = cast(FlxG.state);
				ps.interactable.add(new DroppedItem(getMidpoint().x, getMidpoint().y, new SwordItem(gilbert)));
				LobbyBackground.goalToContinue = () ->
				{
					var result = false;
					ps.playerLayer.forEachOfType(PlayerEntity, (p) ->
					{
						if (p.handWeapon is SwordItem)
							result = true;
					});
					return result;
				};
				LobbyBackground.state = 2;
			});
			timeDialougeMap.set(2500, () ->
			{
				dialouge.resetText("Weapon 2");
				face.text = "^_^";
				dialouge.start(0.05);
				var ps:PlayState = cast(FlxG.state);
				ps.interactable.add(new DroppedItem(getMidpoint().x, getMidpoint().y, new Gamblevolver(gilbert)));
				LobbyBackground.goalToContinue = () ->
				{
					var result = false;
					ps.playerLayer.forEachOfType(PlayerEntity, (p) ->
					{
						if (p.holsteredWeapon is Gamblevolver)
							result = true;
					});
					return result;
				};
				LobbyBackground.state = 2;
			});
			timeDialougeMap.set(3000, () ->
			{
				dialouge.resetText("Swap weapons with backslot");
				face.text = ":)";
				dialouge.start(0.05);
				var ps:PlayState = cast(FlxG.state);
				LobbyBackground.goalToContinue = () ->
				{
					var result = false;
					ps.playerLayer.forEachOfType(PlayerEntity, (p) ->
					{
						if (p.input.backslotJustPressed)
							result = true;
					});
					return result;
				};
				LobbyBackground.state = 2;
			});
			timeDialougeMap.set(3500, () ->
			{
				dialouge.resetText("Try out alt fire");
				face.text = ">:3";
				dialouge.start(0.05);
				var ps:PlayState = cast(FlxG.state);
				LobbyBackground.goalToContinue = () ->
				{
					var result = false;
					ps.playerLayer.forEachOfType(PlayerEntity, (p) ->
					{
						if (p.input.altFireJustPressed)
							result = true;
					});
					return result;
				};
				LobbyBackground.state = 2;
			});
			timeDialougeMap.set(4000, () ->
			{
				dialouge.resetText("Wow I'm am so proud of you");
				face.text = ":D";
				dialouge.start(0.05);
			});
			timeDialougeMap.set(4500, () ->
			{
				dialouge.resetText("Now die hahahahahahahahahahahahahahahahahahaha");
				face.text = "-w-";
				dialouge.start(0.075);
				bossHealthBar = true;
				healthBar.alpha = 0;

				FlxTween.tween(healthBar, {alpha: 1}, 2);
				LobbyBackground.state = 3;
				LobbyBackground.elapsedTimeInState = 0;
			});
		}
		for (i => s in timeDialougeMap)
		{
			if (Math.round(LobbyBackground.elapsedTimeInState * 1000) >= i)
			{
				timeDialougeMap.get(i)();
				timeDialougeMap.remove(i);
			}
		}
		lastState = LobbyBackground.state;
		y = 0;
		face.x = x + ((width - face.width) / 2);
		face.y = y + 100 + (((height - face.height) / 2));
		breathing += elapsed * speed;
		face.y += (Math.sin(breathing) * 15);
		dialouge.update(elapsed);
		screenCenter(X);
		super.update(elapsed);
	}

	override function draw()
	{
		super.draw();
		hitboxes.draw();
		dialouge.screenCenter();
		dialouge.y += (Math.sin(breathing) * 4);
		dialouge.y += 40;
		dialouge.alpha = 0.95 - (Math.sin(breathing) / 10);
		dialouge.draw();
		if (face.visible)
			face.draw();
	}

}