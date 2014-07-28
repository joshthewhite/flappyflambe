package flappybird;

import flambe.scene.Scene;
import flambe.scene.FadeTransition;
import flambe.Entity;
import flambe.animation.Ease;
import flambe.asset.AssetPack;
import flambe.display.Font;
import flambe.scene.Director;
import flambe.scene.SlideTransition;
import flambe.util.Logger;
import flambe.System;
import flappybird.scene.HomeScene;
import flappybird.scene.PlayScene;
import flappybird.scene.ScoreboardScene;
import flambe.swf.Library;
import flambe.swf.Flipbook;

/**
 * Contains all the game state that needs to get passed around.
 */
class FlappyBirdContext
{
    public static inline var TRANSITION_TIME = 0.5;
    public static inline var LAND_SPEED = 135;

    /** The main asset pack. */
    public var pack(default, null) :AssetPack;

    public var director(default, null) :Director;
    public var logger(default, null) :Logger;

    // Some constructed assets
    public var title40Font(default, null) :Font;
    public var library(default, null) :Library;

    public function new(mainPack :AssetPack, director :Director)
    {
        this.pack = mainPack;
        this.director = director;

        title40Font = new Font(pack, "fonts/Title40");
        logger = System.createLogger("default");

        var birdFrames = [];
        for (frame in 1...4) {
            birdFrames.push(pack.getTexture("Bird-0" + frame));
        }
        var birdBook :Flipbook = new Flipbook("bird", birdFrames);
        birdBook.setDuration(0.45);
        library = Library.fromFlipbooks([birdBook]);
    }

    public function enterHomeScene (animate :Bool = true)
    {
        var playScene = new Entity().add(new HomeScene(this));
        director.unwindToScene(playScene, animate ? new FadeTransition(TRANSITION_TIME, Ease.quadOut) : null);
    }

    public function enterPlayingScene (animate :Bool = true)
    {
        var playScene = new Entity().add(new PlayScene(this));
        director.unwindToScene(playScene, animate ? new SlideTransition(TRANSITION_TIME, Ease.quadOut) : null);
    }

    public function showPrompt(score :Int)
    {
        var scene = new Entity().add(new Scene(false));
        scene.addChild(new Entity().add(new ScoreboardScene(this, score)));
        director.pushScene(scene);
    }
}
