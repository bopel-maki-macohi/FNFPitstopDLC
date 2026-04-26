package pitstop.play.stages;

class MainStage extends StageGroup
{
	override function buildStage()
	{
		super.buildStage();

		PlayState.instance.defaultCamZoom = 0.9;

		var stageBack:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);

		var stageFront:BGSprite = new BGSprite('stagefront', -650, 600, 0.9, 0.9);
		stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));

		var stageCurtains:BGSprite = new BGSprite('stagecurtains', -500, -300, 1.3, 1.3);
		stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));

		PlayState.instance.backgroundSprites.add(stageBack);
		PlayState.instance.backgroundSprites.add(stageFront);
		PlayState.instance.backgroundSprites.add(stageCurtains);
	}
}
