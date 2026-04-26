package pitstop.ui;

import flixel.FlxG;
import flixel.system.FlxAssets;
import openfl.display.Shape;
import pitstop.options.PreferencesMenu;
import flixel.math.FlxMath;
import openfl.system.System;
import lime.app.Application;
import flixel.util.FlxColor;
import openfl.text.TextFormat;
import openfl.text.TextField;

class Watermark extends TextField
{
	override public function new()
	{
		super();

		this.x = this.y = 0;

		this.width = FlxG.width;
		this.height = FlxG.height;

		#if FLIXEL_WATERMARK_FONT
		defaultTextFormat = new TextFormat(FlxAssets.FONT_DEFAULT, 16, FlxColor.WHITE);
		#else
		defaultTextFormat = new TextFormat('_sans', 12, FlxColor.WHITE);
		#end
	}

	var curTime:Float = 0;
	var times:Array<Float> = [];
	var cacheCount:Int = 0;

	var currentFPS:Float = 0;

	var entrys:Array<String> = [];

	override function __enterFrame(deltaTime:Float)
	{
		calcFPS(deltaTime);

		entrys = [];

		function addEntry(line:String, condition:Bool)
		{
			if (condition && PreferencesMenu.getPref('watermark'))
				entrys.push(line);
		}

		addEntry('Pitstop DLC v${Application.current.meta.get('version')}' + #if debug ' (PROTOTYPE)' #else '' #end, true);
		addEntry('FPS: $currentFPS', PreferencesMenu.getPref('fps-counter'));
		addEntry('Memory: ${Math.abs(FlxMath.roundDecimal(System.totalMemory / 1000000, 2))}mb', PreferencesMenu.getPref('memory-counter'));

		text = entrys.join('\n');

		drawBackdrop();
	}

	var backdrop:Shape;

	function drawBackdrop()
	{
		if (backdrop == null)
			backdrop = new Shape();

		if (parent != null)
			parent.addChildAt(backdrop, parent.getChildIndex(this) - 1);

		backdrop.x = this.x;
		backdrop.y = this.y;

		backdrop.alpha = .6;

		backdrop.graphics.clear();

		if (entrys.length > 0)
		{
			backdrop.graphics.beginFill(FlxColor.BLACK, 1);
			backdrop.graphics.drawRect(0, 0, (this.textWidth * 1.05), (textHeight * 1.1));
			backdrop.graphics.endFill();
		}
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
