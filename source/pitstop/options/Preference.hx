package pitstop.options;

class Preference
{
	public var id:String;
	public var display:String;

	public var defaultValue:Dynamic;

	public function new(id:String, display:String, defaultValue:Dynamic)
	{
		this.id = id;
		this.display = display;
		this.defaultValue = defaultValue;
	}

	public var description:String = '';

	public function setDescription(description:String):Preference
	{
		this.description = description;

		return this;
	}

	public var experimental:Bool = false;

	public function setExperimental():Preference
	{
		this.experimental = true;

		return this;
	}

	public function setRegular():Preference
	{
		this.experimental = false;

		return this;
	}
}
