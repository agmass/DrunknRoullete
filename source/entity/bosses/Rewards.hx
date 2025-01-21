package entity.bosses;

class Rewards
{
	public var tokens:Int;
	public var opensElevator:Bool;

	public function new(tokens, opensElevator)
	{
		this.tokens = tokens;
		this.opensElevator = opensElevator;
	}
}