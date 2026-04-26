package pitstop.play.stages;

import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import pitstop.macros.DefineUtil;
import flixel.group.FlxSpriteGroup;
import flixel.FlxG;
import pitstop.play.props.RomanceParkPerson;
import flixel.addons.display.FlxBackdrop;

class RomanceParkStage extends StageGroup
{
	public var romancePark_bgPeople:FlxTypedSpriteGroup<RomanceParkPerson>;
    
	override function buildStage()
	{
		super.buildStage();

		PlayState.instance.defaultCamZoom = 0.8;
		RomanceParkPerson.SEEN_PEOPLE = [];

		var sky:FlxBackdrop = new FlxBackdrop(Paths.image('sky'), XY, -320);

		sky.scale.set(2, 2);
		sky.updateHitbox();

		sky.screenCenter();

		PlayState.instance.backgroundSprites.add(sky);

		sky.velocity.set(25, 0);

		var bgGrass:BGSprite = new BGSprite('bgGrass', 0, 0, .2, .2);
		var grass:BGSprite = new BGSprite('grass', 0, 0, .8, .8);
		var bench:BGSprite = new BGSprite('bench', 0, 0, .9, .9);

		for (bgSprite in [bgGrass, grass, bench])
		{
			bgSprite.scale.set(1.2, 1.2);
			bgSprite.updateHitbox();

			bgSprite.screenCenter();
		}

		bgGrass.y = FlxG.height - (bgGrass.height * 1.3);
		grass.y = FlxG.height - (grass.height * 0.5);
		bench.y = FlxG.height - (bench.height * 0.85);

		PlayState.instance.backgroundSprites.add(bgGrass);

		romancePark_bgPeople = new FlxTypedSpriteGroup<RomanceParkPerson>();
		PlayState.instance.backgroundSprites.add(romancePark_bgPeople);

		PlayState.instance.backgroundSprites.add(grass);
		PlayState.instance.backgroundSprites.add(bench);

		var peopleCount:Int = FlxG.random.int(8, 14);

		for (i in 0...peopleCount)
		{
			var person:RomanceParkPerson = new RomanceParkPerson(grass.x - (grass.width * 2), grass.y * 1.1, .5, .5);
			// trace('$i : ${person.person}');

			switch (person.person)
			{
				case short:
					person.y += person.height * 0.05;

				case jax:
					person.y -= person.height * 1.1;

				case caine:
					person.y -= person.height * 0.7;

				case regular:
					person.y -= person.height * 0.2;

				case enderman:
					person.y += person.height * 0.2;

				case invincible:
					person.y += person.height * 0.2;

				case pico:
					person.y -= person.height * 0.55;

				default:
					person.y -= person.height * 0.4;
			}

			var personMoveTime:Float = FlxG.random.float(4, 8) * (FlxG.random.int(5, i) + 1);

			if (DefineUtil.isDefined('SHORTEN_PERSON_MOVE_TIME'))
			{
				personMoveTime = i + 1;
				FlxG.camera.zoom = .2;
			}

			function movePerson(targetX:Float, onUpdate:FlxTween->Void = null)
			{
				var twn:FlxTween = FlxTween.tween(person, {x: targetX}, personMoveTime, {
					onComplete: t ->
					{
						romancePark_bgPeople.remove(person);
						person.destroy();
					},
					onUpdate: t ->
					{
						onUpdate(t);
					}
				});
				twn.onCancel = t ->
				{
					PlayState.instance.tweensList.remove(twn);
				}
				PlayState.instance.tweensList.push(twn);
			}

			movePerson(FlxG.width + (person.width * 2), t ->
			{
				switch (person.person)
				{
					// pico sees bf and dad and just dips
					case pico:
						if (t.percent >= 35)
						{
							t.cancel();

							person.flipX = true;
							FlxTimer.wait(FlxG.random.float(5, 15), () ->
							{
								movePerson(-person.width * 10);
							});
						}

					default:
				}
			});

			romancePark_bgPeople.add(person);
		}

		PlayState.instance.gf.y += 25;
		PlayState.instance.boyfriend.y -= 175;
	}
}
