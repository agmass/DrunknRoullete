package abilities.attributes;

import haxe.ds.HashMap;

class Attribute {

    public static var MOVEMENT_SPEED:String = "movement_speed";
    public static var ATTACK_DAMAGE:String = "attack_damage";
    public static var JUMP_HEIGHT:String = "jump_height";
    public static var MAX_HEALTH:String = "health";

    public static var DASH_SPEED:String = "player.dash_speed";
    public static var JUMP_COUNT:String = "player.jump_count";

	public static var SIZE_X:String = "player.size_x";
	public static var SIZE_Y:String = "player.size_y";

    public var defaultValue = 0.0;
    private var value = 0.0;
    public var modifiers:Array<AttributeContainer> = new Array();

    public function new(defaultAmount) {
        defaultValue = defaultAmount;
        value = defaultAmount;
    }

    public function refreshAndGetValue():Float {
        var finalValue = defaultValue;
        for (i in modifiers) {
			if (i.operation == AttributeOperation.FIRST_ADD)
				finalValue += i.amount;
		}
		for (i in modifiers)
		{
            if (i.operation == AttributeOperation.ADD) finalValue += i.amount;
            else if (i.operation == AttributeOperation.MULTIPLY) finalValue *= i.amount;
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

    public function getValue():Float {
        return value;
    }

}