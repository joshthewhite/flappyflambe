package flappybird.scene;

import flambe.display.ImageSprite;
import flambe.animation.Sine;
import flappybird.component.Bird;
import flambe.display.TextSprite;
import flappybird.component.BackgroundScroller;
import flambe.display.PatternSprite;
import flambe.Entity;
import flambe.display.FillSprite;
import flambe.Component;
import flambe.System;

class HomeScene extends Component
{
    private var _ctx :FlappyBirdContext;

    public function new (ctx :FlappyBirdContext)
    {
        _ctx = ctx;
    }

    override public function onAdded()
    {
        var background = new FillSprite(0x5BC0C9, System.stage.width, System.stage.height);
        owner.addChild(new Entity().add(background));

        var land = new PatternSprite(_ctx.pack.getTexture("Land"));
        land.setSize(System.stage.width + 24, 112);
        land.setXY(0, System.stage.height - land.getNaturalHeight());
        owner.addChild(new Entity().add(land).add(new BackgroundScroller(135, 24)));

        var sky = new PatternSprite(_ctx.pack.getTexture("Sky"));
        sky.setSize(System.stage.width + 276, 109);
        sky.setXY(0, System.stage.height - sky.getNaturalHeight() - land.getNaturalHeight());
        owner.addChild(new Entity().add(sky).add(new BackgroundScroller(15, 276)));

        var title = new TextSprite(_ctx.title40Font);
        title.text = "FlappyBird";
        title.centerAnchor().setXY(System.stage.width / 2, System.stage.height * 0.33);
        owner.addChild(new Entity().add(title));

        var playBtn = new ImageSprite(_ctx.pack.getTexture("PlayButton"));
        var playBtnOffsetY = (playBtn.getNaturalHeight() / 2);
        playBtn.centerAnchor().setXY(System.stage.width / 2, land.y._ - playBtnOffsetY);
        playBtn.pointerDown.connect(onClickPlay);
        owner.addChild(new Entity().add(playBtn));

        var titleBottom = (title.y._ + (title.getNaturalHeight() / 2));
        var playBtnTop = playBtn.y._ - playBtnOffsetY;
        var birdY = titleBottom + ((playBtnTop - titleBottom) / 2);

        var bird = new Bird(_ctx);
        bird.bird.setXY((System.stage.width / 2) - 17, birdY - 12);
        bird.bird.y.behavior = new Sine(bird.bird.y._, bird.bird.y._ + 10, 0.45);
        owner.addChild(new Entity().add(bird));
    }

    private function onClickPlay(_)
    {
        _ctx.enterPlayingScene();
    }
}
