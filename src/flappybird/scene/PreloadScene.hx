package flappybird.scene;

import flambe.display.ImageSprite;
import flambe.Entity;
import flambe.display.FillSprite;
import flambe.asset.AssetPack;
import flambe.Component;
import flambe.System;

class PreloadScene extends Component
{
    private var _pack :AssetPack;

    public function new (pack :AssetPack)
    {
        _pack = pack;
    }

    override public function onAdded()
    {
        var background = new FillSprite(0x000000, System.stage.width, System.stage.height);
        owner.addChild(new Entity().add(background));

        var logo = new ImageSprite(_pack.getTexture("Logo"));
        logo.centerAnchor().setXY(System.stage.width / 2, System.stage.height / 2);
        owner.addChild(new Entity().add(logo));
    }
}
