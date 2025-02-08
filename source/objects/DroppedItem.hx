package objects;

import abilities.equipment.Equipment;
import entity.PlayerEntity;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSprite;

class DroppedItem extends SpriteToInteract
{
	public var visual:FlxNapeSprite = new FlxNapeSprite();
	public var item:Equipment;

	override public function new(x, y, item:Equipment)
	{
		super(x, y);
		this.item = item;
		visual.loadGraphicFromSprite(item);
		alpha = 0;
		setSize(visual.width, visual.height);
		visual.createRectangularBody();
		visual.x = x;
		visual.y = y;
		visual.body.position.setxy(x, y);
		visual.body.space = Main.napeSpace;
		visual.body.rotate(visual.body.position, FlxG.random.float(0, 360));
		visual.setBodyMaterial(0.05, 0.3, 0.3, 4, 0.001);
	}

	override function update(elapsed:Float)
	{
		visual.update(elapsed);
		x = visual.body.position.x;
		y = visual.body.position.y;
		super.update(elapsed);
	}

	override function destroy()
	{
		visual.body.position.setxy(-1000, -1000);
		super.destroy();
	}

	override function interact(p:PlayerEntity)
	{
		item.wielder = p;
		if (p.handWeapon != null)
		{
			if (p.holsteredWeapon == null)
			{
				p.holsteredWeapon = item;
				if (FlxG.state is PlayState)
				{
					var ps:PlayState = cast(FlxG.state);
					ps.interactable.remove(this);
					destroy();
				}
			}
			else
			{
				if (FlxG.state is PlayState)
				{
					var ps:PlayState = cast(FlxG.state);
					ps.interactable.add(new DroppedItem(p.x, p.y, p.handWeapon));
					p.handWeapon = item;
					ps.interactable.remove(this);
					destroy();
				}
			}
		}
		else
		{
			p.handWeapon = item;
			if (FlxG.state is PlayState)
			{
				var ps:PlayState = cast(FlxG.state);
				ps.interactable.remove(this);
				destroy();
			}
		}
		super.interact(p);
	}

	override function draw()
	{
		super.draw();
		visual.draw();
	}
}