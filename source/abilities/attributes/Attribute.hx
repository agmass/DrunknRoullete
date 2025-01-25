package abilities.attributes;

import haxe.ds.HashMap;

class Attribute {

	public static var MOVEMENT_SPEED:AttributeType = new AttributeType("movement_speed", 1, 150, 1200);
	public static var ATTACK_DAMAGE:AttributeType = new AttributeType("attack_damage", 0.01, 0.75, 2);
	public static var ATTACK_KNOCKBACK:AttributeType = new AttributeType("attack_knockback", 0.01, 0.4, 5);
	public static var JUMP_HEIGHT:AttributeType = new AttributeType("jump_height", 0.5, 50);
	public static var MAX_HEALTH:AttributeType = new AttributeType("health", 1, 45);

	public static var SIZE_X:AttributeType = new AttributeType("size_x", 0.001, 0.45, 2);
	public static var SIZE_Y:AttributeType = new AttributeType("size_y", 0.001, 0.45, 2);
	public static var ATTACK_SPEED:AttributeType = new AttributeType("attack_speed", 0.01, 0.45, 2);
	public static var REGENERATION:AttributeType = new AttributeType("regeneration", 0.01, 1, 10);

	public static var DASH_SPEED:AttributeType = new AttributeType("player.dash_speed", 1, 150, 600);
	public static var JUMP_COUNT:AttributeType = new AttributeType("player.jump_count", 1, 0, 99999999999999999999999, true);
	public static var CRIT_CHANCE:AttributeType = new AttributeType("player.crit_chance", 0.1, 1, 100);
	public static var CROUCH_SCALE:AttributeType = new AttributeType("player.crouch_scale", 0.001, 0.45, 0.9);

	public static var attributesList = [
		MOVEMENT_SPEED,
		ATTACK_DAMAGE,
		MAX_HEALTH,
		ATTACK_SPEED, 
		SIZE_X,
		DASH_SPEED,
		JUMP_COUNT,
		CRIT_CHANCE,
		REGENERATION 
	];


    public var defaultValue = 0.0;
    private var value = 0.0;
	public var bypassLimits = false;
    public var modifiers:Array<AttributeContainer> = new Array();
	public var temporaryModifiers:Map<AttributeContainer, Float> = new Map();

	public var min = 0.0;
	public var max = 0.0;

	public function new(defaultAmount, ?bypass = false)
	{
        defaultValue = defaultAmount;
        value = defaultAmount;
		bypassLimits = bypass;
    }

    public function refreshAndGetValue():Float {
        var finalValue = defaultValue;
		var firstAddValue = 0.0;
        for (i in modifiers) {
			if (i.operation == AttributeOperation.FIRST_ADD)
			{
				finalValue += i.amount; 
				firstAddValue += i.amount;
			}
		}
		for (i in modifiers)
		{
            if (i.operation == AttributeOperation.ADD) finalValue += i.amount;
			else if (i.operation == AttributeOperation.MULTIPLY)
				finalValue *= i.amount;
			if (!bypassLimits)
			{
				if (finalValue >= max)
				{
					finalValue = max + firstAddValue;
				}
				if (finalValue <= min)
				{
					finalValue = min + firstAddValue;
				}
			}
		}
        value = finalValue;
        return finalValue;
    }

    public function removeOperation(container:AttributeContainer) {
        modifiers.remove(container);
        refreshAndGetValue();
    }
	public function containsOperation(container:AttributeContainer):Bool
	{
		return modifiers.contains(container);
	}

    public function addOperation(container:AttributeContainer) {
		if (!modifiers.contains(container))
		{
			modifiers.push(container);
			refreshAndGetValue();
		}
    }

	public function addTemporaryOperation(container:AttributeContainer, time:Float)
	{
		temporaryModifiers.set(container, time);
		addOperation(container);
	}

	public function update(elapsed:Float)
	{
		for (a => f in temporaryModifiers)
		{
			temporaryModifiers.set(a, f - elapsed);
			if (f - elapsed < 0)
			{
				removeOperation(a);
				temporaryModifiers.remove(a);
			}
		}
	}

    public function getValue():Float {
        return value;
    }

	public static function parseOperation(string:String):AttributeOperation
	{
		if (string == "add")
			return AttributeOperation.ADD;
		if (string == "first_add")
			return AttributeOperation.FIRST_ADD;
		if (string == "multiply")
			return AttributeOperation.MULTIPLY;
		return AttributeOperation.ADD;
	}

}