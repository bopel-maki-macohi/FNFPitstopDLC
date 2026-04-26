package pitstop.play.scoring;

class RatingClass
{
	public var score:Int;
	public var rating:String;
	public var healthChange:Float;

	public function new(rating:String, score:Int, healthChangePercent:Float)
	{
		this.score = score;
		this.rating = rating;
		this.healthChange = (healthChangePercent / 100.0) * 2;
	}
}
