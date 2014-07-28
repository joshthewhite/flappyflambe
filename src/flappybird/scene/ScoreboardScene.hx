package flappybird.scene;

import flambe.Entity;
import flambe.display.ImageSprite;
import flambe.Component;
import flambe.System;

class ScoreboardScene extends Component
{
    private var _ctx :FlappyBirdContext;
    private var _score :Int;

    public function new (ctx :FlappyBirdContext, score :Int)
    {
        _ctx = ctx;
        _score = score;
    }

    override public function onAdded()
    {
        var scoreboard = new ImageSprite(_ctx.pack.getTexture("Scoreboard"));
        scoreboard.centerAnchor().setXY(System.stage.width / 2, System.stage.height / 2);
        var scoreboardEntity = new Entity().add(scoreboard);
        owner.addChild(scoreboardEntity);

        var boardBottom = scoreboard.y._ + (scoreboard.getNaturalHeight() / 2);

        var playBtn = new ImageSprite(_ctx.pack.getTexture("PlayButton"));
        var playBtnOffsetY = (playBtn.getNaturalHeight() / 2);
        playBtn.centerAnchor().setXY(System.stage.width / 2, boardBottom + playBtnOffsetY + 10);
        playBtn.pointerDown.connect(onClickPlay);
        owner.addChild(new Entity().add(playBtn));
    }

    private function onClickPlay(_)
    {
        _ctx.enterPlayingScene();
    }
}
