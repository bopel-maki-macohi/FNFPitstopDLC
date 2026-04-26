package pitstop.options;

import pitstop.save.PreferencesSaveData;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import pitstop.options.AtlasText.AtlasFont;
import pitstop.options.TextMenuList.TextMenuItem;

class PreferencesMenu extends pitstop.options.OptionsState.Page
{
	public static var preferences:Map<String, Dynamic> = new Map();

	var items:TextMenuList;

	var checkboxes:Array<CheckboxThingie> = [];
	var menuCamera:FlxCamera;
	var camFollow:FlxObject;

	public function new(experimental:Bool = false)
	{
		super();

		menuCamera = new SwagCamera();
		FlxG.cameras.add(menuCamera, false);
		menuCamera.bgColor = 0x0;
		camera = menuCamera;

		add(items = new TextMenuList());

		for (pref in prefs)
			if (experimental && experimentalPrefs.contains(pref) || !experimental && !experimentalPrefs.contains(pref))
				createPrefItem(pref, prefsOptionMap.get(pref), preferences.get(prefsOptionMap.get(pref)));

		camFollow = new FlxObject(FlxG.width / 2, 0, 140, 70);
		if (items != null)
			camFollow.y = items.selectedItem.y;

		menuCamera.follow(camFollow, null, 0.06);
		var margin = 160;
		menuCamera.deadzone.set(0, margin, menuCamera.width, 40);
		menuCamera.minScrollY = 0;

		items.onChange.add(function(selected)
		{
			camFollow.y = selected.y;
		});
	}

	public static function getPref(pref:String):Dynamic
	{
		return preferences.get(pref);
	}

	// easy shorthand?
	public static function setPref(pref:String, value:Dynamic):Void
	{
		preferences.set(pref, value);
	}

	public static var prefs:Array<String> = [];
	public static var regularPrefs:Array<String> = [];
	public static var experimentalPrefs:Array<String> = [];

	static var prefsOptionMap:Map<String, Dynamic> = [];
	static var prefsValMap:Map<String, Dynamic> = [];

	// for array prefs but thats l8r
	static var prefsValuesMap:Map<String, Array<Dynamic>> = [];

	public static function makePref(display:String, name:String, defaultValue:Dynamic, ?experimental:Bool = false)
	{
		prefs.push(display);
		
		if (experimental)
			experimentalPrefs.push(display);
		else
			regularPrefs.push(display);

		prefsOptionMap.set(display, name);
		prefsValMap.set(name, defaultValue);
	}

	public static function initPrefs():Void
	{
		makePref('Naughtyness', 'censor-naughty', true);
		makePref('Downscroll', 'downscroll', false);

		makePref('Flashing Menu BG', 'flashing-menu', true);

		makePref('Camera Zooming on Beat', 'camera-zoom', true);

		makePref('Debug Display', 'watermark', true);
		makePref('Debug Display FPS Counter', 'fps-counter', true);
		makePref('Debug Display Memory Counter', 'memory-counter', true);

		makePref('Auto Pause', 'auto-pause', true);
		makePref('Ghost Tapping', 'ghost-tapping', false, true);

		for (key => value in prefsValMap)
			preferenceCheck(key, value);

		FlxG.autoPause = getPref('auto-pause');
	}

	private function createPrefItem(prefName:String, prefString:String, prefValue:Dynamic):Void
	{
		items.createItem(120, (120 * items.length) + 30, prefName, AtlasFont.Bold, function()
		{
			preferenceCheck(prefString, prefValue);

			switch (Type.typeof(prefValue).getName())
			{
				case 'TBool':
					prefToggle(prefString);
			}

			PreferencesSaveField.setField(prefString, preferences.get(prefString));
		});

		switch (Type.typeof(prefValue).getName())
		{
			case 'TBool':
				createCheckbox(prefString);
		}

		trace(Type.typeof(prefValue).getName());
	}

	function createCheckbox(prefString:String)
	{
		var checkbox:CheckboxThingie = new CheckboxThingie(0, 120 * (items.length - 1), preferences.get(prefString));
		checkboxes.push(checkbox);
		add(checkbox);
	}

	/**
	 * Assumes that the preference has already been checked/set?
	 */
	private function prefToggle(prefName:String)
	{
		var daSwap:Bool = preferences.get(prefName);
		daSwap = !daSwap;

		preferences.set(prefName, daSwap);

		checkboxes[items.selectedIndex].daValue = daSwap;
		trace('toggled? ' + preferences.get(prefName));

		switch (prefName)
		{
			case 'auto-pause':
				FlxG.autoPause = getPref('auto-pause');
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		// menuCamera.followLerp = CoolUtil.camLerpShit(0.05);

		items.forEach(function(daItem:TextMenuItem)
		{
			if (items.selectedItem == daItem)
				daItem.x = 150;
			else
				daItem.x = 120;
		});
	}

	private static function preferenceCheck(prefString:String, ?defaultValue:Dynamic):Void
	{
		if (preferences.get(prefString) == null)
		{
			if (PreferencesSaveField.getField(prefString) == null)
			{
				trace('set $prefString to default value: $defaultValue!');

				preferences.set(prefString, defaultValue);
				PreferencesSaveField.setField(prefString, defaultValue);
			}
			else
			{
				preferences.set(prefString, PreferencesSaveField.getField(prefString));
				trace('set $prefString to save value: ${preferences.get(prefString)}!');
			}
		}
		else
		{
			trace('found preference: ' + preferences.get(prefString));
		}
	}
}

class CheckboxThingie extends FlxSprite
{
	public var daValue(default, set):Bool;

	public function new(x:Float, y:Float, daValue:Bool = false)
	{
		super(x, y);

		frames = Paths.getSparrowAtlas('checkboxThingie');
		animation.addByPrefix('static', 'Check Box unselected', 24, false);
		animation.addByPrefix('checked', 'Check Box selecting animation', 24, false);

		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();

		this.daValue = daValue;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		switch (animation.curAnim.name)
		{
			case 'static':
				offset.set();
			case 'checked':
				offset.set(17, 70);
		}
	}

	function set_daValue(value:Bool):Bool
	{
		if (value)
			animation.play('checked', true);
		else
			animation.play('static');

		return value;
	}
}
