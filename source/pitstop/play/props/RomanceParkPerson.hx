package pitstop.play.props;

import flixel.FlxG;

enum abstract RomanceParkPersonID(String) from String to String
{
	var invincible = 'bf person titlecard';
	var amongUs = 'bg person crewmate';
	var enderman = 'bg person ender';
	var caine = 'bg person ringmaster';
	var pico = 'bg person school shooter';
	var jax = 'bg person the funny one';

	var regular = 'bg person regular';
	var short = 'bg person short';
	var tall = 'bg person tall';
}

class RomanceParkPerson extends BGSprite
{
	public static final PEOPLE_SYMBOLS:Array<RomanceParkPersonID> = [invincible, amongUs, enderman, caine, pico, jax, regular, short, tall,];

	public static final PEOPLE_CHANCES:Map<RomanceParkPersonID, Float> = [
		invincible => 10,
		amongUs => 20.20,
		enderman => 16.5,
		caine => 8,
		pico => 19.99,
		jax => 9,
		regular => 0, // last thing used anyway
		short => 37.5,
		tall => 62.5,
	];

	public static var CANT_SEE_AGAIN:Array<RomanceParkPersonID> = [invincible, enderman, caine, pico, jax];

	public static var SEEN_PEOPLE:Array<RomanceParkPersonID> = [];

	public var person:RomanceParkPersonID = null;

	override public function new(x:Float = 0, y:Float = 0, parX:Float = 1, parY:Float = 1)
	{
		super('bgPersons', x, y, parX, parY, PEOPLE_SYMBOLS);

		for (key => value in PEOPLE_CHANCES)
		{
			if (FlxG.random.bool(value))
			{
				if (!(CANT_SEE_AGAIN.contains(key) && SEEN_PEOPLE.contains(key)))
				{
					SEEN_PEOPLE.push(key);

					person = key;
					this.animation.play(key);
					break;
				}
			}
		}

		if (this.animation.curAnim == null)
		{
			person = regular;
			this.animation.play(RomanceParkPersonID.regular);
		}
	}
}
