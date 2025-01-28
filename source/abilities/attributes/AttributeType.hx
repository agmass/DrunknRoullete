package abilities.attributes;

class AttributeType
{
	public var id:String;
	public var additionMultiplier:Float;
	public var mustBeAddition:Bool;

	public var minBound:Float;
	public var maxBound:Float;

	public function new(id, additionMultiplier, ?minBound = 0.0, ?maxBound = 999999999.9, ?mustBeAddition = false)
	{
		this.id = id;
		this.additionMultiplier = additionMultiplier;
		this.maxBound = maxBound;
		this.minBound = minBound;
		this.mustBeAddition = mustBeAddition;
	}
}