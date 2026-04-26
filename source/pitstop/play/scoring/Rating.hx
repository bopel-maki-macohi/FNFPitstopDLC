package pitstop.play.scoring;

enum abstract Rating(RatingClass) from RatingClass to RatingClass
{
	public static var SICK:RatingClass = new RatingClass('sick', 350, 1);
	public static var GOOD:RatingClass = new RatingClass('good', 200, 0.75);
	public static var BAD:RatingClass = new RatingClass('bad', 100, 0);
	public static var SHIT:RatingClass = new RatingClass('shit', 50, -1);
}
