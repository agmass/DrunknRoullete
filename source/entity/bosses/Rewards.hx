package entity.bosses;

class Rewards
{
	public var tokens:Int;
	public var healPlayers:Bool;

	public function new(tokens, healPlayers)
	{
		this.tokens = tokens;
		this.healPlayers = healPlayers;
	}
}