package util;

import entity.Entity;
import entity.PlayerEntity;

class Run
{
	public var players:Array<PlayerEntity> = [];
	public var roomsTraveled = 0;
	public var combo = 0;
	public var nextBoss:Entity = null;
	public var cheatedThisRun = false;

	public function new() {}
}