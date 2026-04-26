package pitstop.display;

import flixel.math.FlxMath;
import openfl.system.System;
import lime.app.Application;
import flixel.util.FlxColor;
import openfl.text.TextFormat;
import openfl.text.TextField;

class Watermark extends TextField
{
	override public function new(x:Float, y:Float)
	{
		super();

		this.x = x;
		this.y = y;

		defaultTextFormat = new TextFormat('_sans', 12, FlxColor.WHITE);
	}

	var curTime:Float = 0;
	var times:Array<Float> = [];
	var cacheCount:Int = 0;

	var currentFPS:Float = 0;

	override function __enterFrame(deltaTime:Float)
	{
		calcFPS(deltaTime);

		var entrys:Array<String> = [
			'Pitstop DLC v${Application.current.meta.get('version')}',
			'',
			'FPS: ${FlxMath.roundDecimal(currentFPS, 2)}',
			'Total Memory: ${Math.abs(FlxMath.roundDecimal(System.totalMemory / 1000000, 2))}',
		];

		text = entrys.join('\n');
	}

	function calcFPS(deltaTime:Float)
	{
		curTime += deltaTime;
		times.push(curTime);

		while (times[0] < curTime - 1000)
			times.shift();

		var currentCount = times.length;
		currentFPS = Math.round((currentCount + cacheCount) / 2);

		cacheCount = currentCount;
	}
}
