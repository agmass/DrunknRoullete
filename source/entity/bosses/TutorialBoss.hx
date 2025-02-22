package entity.bosses;

import abilities.attributes.Attribute;
import abilities.equipment.items.Gamblevolver;
import abilities.equipment.items.SwordItem;
import backgrounds.LobbyBackground;
import flixel.FlxG;
import flixel.addons.text.FlxTypeText;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import input.KeyboardSource;
import objects.DroppedItem;
import objects.hitbox.ExplosionHitbox;
import objects.hitbox.Hitbox;
import openfl.filters.ShaderFilter;
import openfl.utils.QName;
import projectiles.ShellProjectile;
import shader.CRTLinesShader;
import shader.GlowInTheDarkShader;
import shader.SuperGlowInTheDarkShader;
import util.Language;
import util.Projectile;
#if cpp
import steamwrap.api.Steam;
#end

class TutorialBoss extends Entity
{
	var dialouge:FlxTypeText = new FlxTypeText(0, 0, 0, "", 28);
	var side_dialouge:FlxTypeText = new FlxTypeText(0, 0, 0, "", 28);
	var face:FlxText = new FlxText(0, 0, 0, "z_z", 100);

	var lastState = 0;
	var speed = 0.25;
	var startFadeout = false;
	var line = 0;
	var lastLine = 0;

	override public function new(x, y)
	{
		super(x, y);
		bleeds = false;
		manuallyUpdateSize = true;
		makeGraphic(750, 500, FlxColor.BLACK);
		face.shader = new CRTLinesShader();
		setSize(750, 500);
		typeTranslationKey = "scrimblo";
		entityName = Language.get("entity." + typeTranslationKey);
	}
	var breathing:Float = 0.0;
	var timeDialougeMap:Map<Int, Void->Void> = new Map();
	var superGlow:ShaderFilter = new ShaderFilter(new GlowInTheDarkShader());

	override function createAttributes()
	{
		super.createAttributes();
		attributes.set(Attribute.MAX_HEALTH, new Attribute(550, true));
		attributes.set(Attribute.ATTACK_DAMAGE, new Attribute(0.65));
	}

	var dying = false;

	var fading = false;
	public var died = false;
	override function damage(amount:Float, attacker:Entity)
	{
		if (!dying && !died && LobbyBackground.state == 3)
			return super.damage(amount, attacker);
		return false;
	}

	var explosionCooldown = 0.2;
	override function update(elapsed:Float)
	{
		for (projectile in collideables)
		{
			if (projectile.returnToShooter)
			{
				projectile.body.position.setxy(-1000, -1000);
				collideables.remove(projectile);
			}
		}
		noEpilepsy -= elapsed;
		if (noEpilepsy < 0)
			noEpilepsy = 1;
		if (died)
			return;
		if (health <= 0 && ragdoll == null)
		{
			health = 600;
			dying = true;

			face.text = "X_X";
		}
		if (dying && !died)
		{
			explosionCooldown -= elapsed;
			if (explosionCooldown <= 0)
			{
				FlxG.timeScale += elapsed;
				if (FlxG.timeScale >= 1.2 && !fading)
				{
					fading = true;
					FlxG.camera.fade(FlxColor.WHITE, 3.5, false, () ->
					{
						dying = false;
						died = true;
						face.angle = -10;
						healthBar.alpha = 0;
						nametag.alpha = 0;
						#if cpp
						Steam.setAchievement("DEFEAT_TUTORIAL");
						#end
						face.color = FlxColor.GRAY.getDarkened(0.2);

						FlxG.camera.fade(FlxColor.WHITE, 0.25, true);
						FlxG.timeScale = 1;
					});
				}
				explosionCooldown = 0.2;
				var explosion:ExplosionHitbox = new ExplosionHitbox(FlxG.random.float(x, x + width), FlxG.random.float(y, y + height), 0);
				hitboxes.add(explosion);
			}
		}
		if (FlxG.state is PlayState)
		{
			var ps:PlayState = cast(FlxG.state);
			for (hitbox in hitboxes)
			{
				FlxG.overlap(hitbox, ps, (h, e) ->
				{
					if (e is Entity)
					{
						if (h is Hitbox)
						{
							var e2:Entity = cast(e);
							var hitbox:Hitbox = cast(h);
							if (!hitbox.hitEntities.contains(e2))
							{
								h.onHit(e2);
							}
						}
					}
				});
			}
		}
		velocity.x = velocity.y = 0;
		if (lastState == -1 && LobbyBackground.state == -2)
		{
			LobbyBackground.elapsedTimeInState = 0;
			timeDialougeMap.set(0, () ->
			{
				var ps:PlayState = cast(FlxG.state);
				ps.HUDCam.flash(FlxColor.WHITE, 1);
				FlxG.camera.visible = false;
			});
			timeDialougeMap.set(3000, () ->
			{
				face.text = "z_o";
			});
			timeDialougeMap.set(3100, () ->
			{
				face.text = "o_o";
			});
			timeDialougeMap.set(3450, () ->
			{
				face.text = "-_-";
			});
			timeDialougeMap.set(3650, () ->
			{
				face.text = "O_O";
				face.offset.x = 70;
			});
			timeDialougeMap.set(3850, () ->
			{
				face.text = "-_-";
				face.offset.x = 0;
			});
			timeDialougeMap.set(4050, () ->
			{
				face.text = "O_O";
				face.offset.x = -70;
			});
			timeDialougeMap.set(4350, () ->
			{
				face.text = "O_O";
				face.offset.x = 0;
				face.offset.y = -30;
			});
			timeDialougeMap.set(5050, () ->
			{
				face.text = "O  _  O";
			});
			timeDialougeMap.set(5550, () ->
			{
				face.text = "- _ -";
			});
			timeDialougeMap.set(5750, () ->
			{
				face.text = "O  _  O";
			});
			timeDialougeMap.set(7000, () ->
			{
				face.text = ".-.";
				dialouge.visible = false;
				side_dialouge.x = 0;
				FlxTween.cancelTweensOf(side_dialouge);
				side_dialouge.resetText(Language.get("entity.scrimblo.rebootCancelled"));
				side_dialouge.start(0.005);
				FlxTween.tween(FlxG.camera, {zoom: 1, "scroll.x": 0, "scroll.y": 0}, 1, {ease: FlxEase.sineInOut});
			});
			timeDialougeMap.set(9000, () ->
			{
				lockAlpha = 0;
				dialouge.color = FlxColor.WHITE;
				side_dialouge.color = FlxColor.WHITE;
				side_dialouge.camera = FlxG.camera;
				dialouge.camera = FlxG.camera;
				face.offset.y = 0;
				dialouge.size = 24;
				LobbyBackground.state = 1;
			});
			timeDialougeMap.set(2000, () ->
			{
				var ps:PlayState = cast(FlxG.state);
				lockAlpha = 1;
				dialouge.camera = ps.HUDCam;
				dialouge.x = 0;
				dialouge.y = 0;
				side_dialouge.camera = ps.HUDCam;
				side_dialouge.x = -80;
				side_dialouge.y = FlxG.height - 52;

				side_dialouge.size = 48;
				dialouge.size = 128;

				FlxTween.tween(dialouge, {x: -1000}, 6);
				FlxTween.tween(side_dialouge, {x: -400}, 6);

				dialouge.color = FlxColor.RED;
				FlxG.camera.shake(0.01, 6);
				side_dialouge.color = FlxColor.RED;

				dialouge.delay = 0.01;
				side_dialouge.delay = 0.01;

				dialouge.resetText(Language.get("entity.scrimblo.warning") + " " + Language.get("entity.scrimblo.warning") + " "
					+ Language.get("entity.scrimblo.warning") + " " + Language.get("entity.scrimblo.warning") + " " + Language.get("entity.scrimblo.warning")
					+ " " + Language.get("entity.scrimblo.warning") + " ");
				dialouge.start(dialouge.delay);

				side_dialouge.resetText(Language.get("entity.scrimblo.side_warning"));
				side_dialouge.start(dialouge.delay);
				PlayState.unlockCamera = true;
				FlxG.camera.zoom = 2.5;
				FlxG.camera.focusOn(face.getMidpoint());
				FlxG.camera.visible = true;
			});
		}
		if (lastState == -2 && LobbyBackground.state == 1)
		{
			LobbyBackground.elapsedTimeInState = 0;
			line++;
			dialouge.visible = true;
			side_dialouge.size = 12;
			var gilbert = new EquippedEntity(-100, -100);
			timeDialougeMap.set(0, () ->
			{
				face.text = "o_o";
				speed = 0.25;
				dialouge.delay = 0.05;
			});
			timeDialougeMap.set(400, () ->
			{
				face.text = ":D";
			});
			timeDialougeMap.set(4500, () ->
			{
				face.text = ">:3";
				line++;
			});
			timeDialougeMap.set(9000, () ->
			{
				face.text = "@_@";
				line++;
				face.offset.x = 25;
			});
			timeDialougeMap.set(15000, () ->
			{
				face.offset.x = 0;
				face.text = ":O";
				line++;
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
			timeDialougeMap.set(17500, () ->
			{
				face.offset.x = -25;
				speed = 0.1;
				face.text = "0.-";
				line++;
				var ps:PlayState = cast(FlxG.state);
				LobbyBackground.goalToContinue = () ->
				{
					var result = false;
					ps.playerLayer.forEachOfType(PlayerEntity, (p) ->
					{
						if (p.input.attackPressed)
							result = true;
					});
					return result;
				};
				LobbyBackground.state = 2;
			});
			timeDialougeMap.set(22000, () ->
			{
				face.offset.x = 25;
				speed = 0.4;
				face.text = "^-^";
				line++;
				var ps:PlayState = cast(FlxG.state);
				LobbyBackground.goalToContinue = () ->
				{
					var result = false;
					ps.playerLayer.forEachOfType(PlayerEntity, (p) ->
					{
						if (p.input.altFirePressed)
							result = true;
					});
					return result;
				};
				LobbyBackground.state = 2;
			});
			timeDialougeMap.set(22100, () ->
			{
				speed = 0.25;
				face.text = "~_~";
				face.offset.x = -40;
				line++;
			});
			timeDialougeMap.set(24500, () ->
			{
				face.text = "qwq";
				face.offset.x = 0;
				line++;
				var ps:PlayState = cast(FlxG.state);
				ps.interactable.add(new DroppedItem(getMidpoint().x, getMidpoint().y, new Gamblevolver(gilbert)));
				LobbyBackground.goalToContinue = () ->
				{
					var result = false;
					ps.playerLayer.forEachOfType(PlayerEntity, (p) ->
					{
						if (p.handWeapon is Gamblevolver || p.holsteredWeapon is Gamblevolver)
							result = true;
					});
					return result;
				};
				LobbyBackground.state = 2;
			});
			timeDialougeMap.set(29500, () ->
			{
				face.text = "q_p";
				FlxTween.tween(face, {angle: 360}, 2, {ease: FlxEase.sineInOut, type: PINGPONG});
				line++;
				var ps:PlayState = cast(FlxG.state);
				LobbyBackground.goalToContinue = () ->
				{
					var result = false;
					ps.playerLayer.forEachOfType(PlayerEntity, (p) ->
					{
						if (p.input.backslotPressed)
							result = true;
					});
					return result;
				};
				LobbyBackground.state = 2;
			});
			timeDialougeMap.set(30000, () ->
			{
				face.text = "Oops...";
				FlxTween.cancelTweensOf(face);
				face.angle = 0;
				line++;
			});
			timeDialougeMap.set(32500, () ->
			{
				face.text = "8_8";
				line++;
			});
			timeDialougeMap.set(36500, () ->
			{
				face.text = "^_^";
				line++;
			});
			timeDialougeMap.set(44500, () ->
			{
				face.text = "n_n";
				FlxG.camera.filters.push(superGlow);
				lockAlpha = 1;
				line++;
			});
			timeDialougeMap.set(49500, () ->
			{
				face.text = "u_u";
				line++;
			});
			timeDialougeMap.set(53500, () ->
			{
				face.text = ">:)";
				FlxG.camera.filters.remove(superGlow);
				lockAlpha = 0;
				line++;				
				bossHealthBar = true;
				healthBar.alpha = 0;
				FlxTween.tween(healthBar, {alpha: 1}, 2);
				new FlxTimer().start(1.5, (t) ->
				{
					startFadeout = true;
					FlxTween.tween(dialouge, {alpha: 0}, 1);
				});
				LobbyBackground.state = 3;
				LobbyBackground.elapsedTimeInState = 0;
			});
		}
		lastState = LobbyBackground.state;
		for (i => s in timeDialougeMap)
		{
			if (Math.round(LobbyBackground.elapsedTimeInState * 1000) >= i)
			{
				timeDialougeMap.get(i)();
				timeDialougeMap.remove(i);
			}
		}
		y = 0;
		face.x = x + ((width - face.width) / 2);
		face.y = y + 100 + (((height - face.height) / 2));
		breathing += elapsed * speed;
		face.y += (Math.sin(breathing) * 15);
		dialouge.update(elapsed);
		side_dialouge.update(elapsed);
		screenCenter(X);
		if (FlxG.keys.justPressed.K)
		{
			LobbyBackground.state = 3;
		}
		if (LobbyBackground.state == 3)
		{
			attackCooldown -= elapsed;
			if (attackCooldown <= 0)
			{
				switch (FlxG.random.int(0, 1))
				{
					case 0:
						attackCooldown = 2.5;
						for (i in 0...7)
						{
							if (FlxG.random.bool(40))
							{
								var bomb:ShellProjectile = new ShellProjectile(getMidpoint().x, getMidpoint().y + 90);
								bomb.shooter = this;
								bomb.body.velocity.setxy((400 * (i - 3)), 300);
								collideables.add(bomb);
							}
						}
				}
			}
		}
		if (lastLine != line)
		{
			dialouge.resetText(Language.getForInputs("entity.scrimblo.dialouge." + line, Main.activeInputs[0]));
			dialouge.start(dialouge.delay);
			if (Language.get("entity.scrimblo.dialouge." + line + ".side") != "entity.scrimblo.dialouge." + line + ".side")
			{
				side_dialouge.resetText(Language.get("entity.scrimblo.dialouge." + line + ".side"));
				side_dialouge.start(side_dialouge.delay);
				side_dialouge.visible = true;
			}
			else
			{
				side_dialouge.visible = false;
			}
		}
		lastLine = line;
		super.update(elapsed);
	}

	var attackCooldown = 1.5;

	var noEpilepsy = 1.0;

	override function draw()
	{
		if (died)
		{
			super.draw();
			if (noEpilepsy < 0.5)
			{
				face.draw();
			}
			return;
		}
		super.draw();
		if (!startFadeout)
		{
			if (lockAlpha == 0)
			{
				dialouge.screenCenter();
				dialouge.y += (Math.sin(breathing) * 4);
				dialouge.y += 40;
				dialouge.alpha = 0.95 - (Math.sin(breathing) / 10);
			}
			else
			{
				dialouge.alpha = lockAlpha;
			}
		}
		if (dialouge.visible)
			dialouge.draw();
		if (side_dialouge.visible)
		{
			if (lockAlpha == 0)
			{
				side_dialouge.screenCenter();
				side_dialouge.y += (Math.sin(breathing) * 4);
				side_dialouge.y += 75;
				side_dialouge.alpha = 0.95 - (Math.sin(breathing) / 10);
			}
			else
			{
				side_dialouge.alpha = lockAlpha;
			}
			side_dialouge.draw();
		}
		if (face.visible)
			face.draw();
	}

	public static var lockAlpha = 0;

}