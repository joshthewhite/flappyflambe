package flappybird;

import flambe.scene.Director;
import flambe.Entity;
import flambe.System;
import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import flappybird.scene.PreloadScene;
import haxe.Timer;

class Main
{
    private static function main ()
    {
        System.init();

        var director = new Director();
        System.root.add(director);

        var manifest = Manifest.fromAssets("bootstrap");
        System.loadAssetPack(manifest).get(function (bootstrapPack :AssetPack) {
            var promise = System.loadAssetPack(Manifest.fromAssets("main"));
            promise.get(function (mainPack) {
                var ctx = new FlappyBirdContext(mainPack, director);
                ctx.enterHomeScene(false);
                bootstrapPack.dispose();
            });

            var preloadScene = new Entity().add(new PreloadScene(bootstrapPack));
            director.unwindToScene(preloadScene);
        });
    }
}
