package flappybird.scene;

import flambe.display.Font.TextAlign;
import flambe.display.TextSprite;
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
        var playBtn = new ImageSprite(_ctx.pack.getTexture("PlayButton"));
        var playBtnOffsetY = playBtn.getNaturalHeight() / 2;

        var scoreboard = new ImageSprite(_ctx.pack.getTexture("Scoreboard"));
        scoreboard.centerAnchor().setXY(System.stage.width / 2, (System.stage.height / 2) - playBtnOffsetY);
        var scoreboardEntity = new Entity().add(scoreboard);
        owner.addChild(scoreboardEntity);
        var boardBottom = scoreboard.y._ + (scoreboard.getNaturalHeight() / 2);

        var scoreSprite = new TextSprite(_ctx.title40Font);
        scoreSprite.setScale(0.5);
        scoreSprite.text = "" + Std.int(_score);
        scoreSprite.setXY(150, 90);
        scoreSprite.setWrapWidth(160);
        scoreSprite.align = TextAlign.Center;
        scoreboardEntity.addChild(new Entity().add(scoreSprite));

        var bestScoreSprite = new TextSprite(_ctx.title40Font);
        bestScoreSprite.setScale(0.5);
        bestScoreSprite.text = "" + Std.int(_ctx.bestScore);
        bestScoreSprite.setXY(150, 132);
        bestScoreSprite.setWrapWidth(160);
        bestScoreSprite.align = TextAlign.Center;
        scoreboardEntity.addChild(new Entity().add(bestScoreSprite));

        var playBtn = new ImageSprite(_ctx.pack.getTexture("PlayButton"));
        playBtn.centerAnchor().setXY(System.stage.width / 2, boardBottom + playBtnOffsetY + 10);
        playBtn.pointerDown.connect(onClickPlay);
        owner.addChild(new Entity().add(playBtn));
    }

    private function onClickPlay(_)
    {
        _ctx.enterPlayingScene();
    }
}
