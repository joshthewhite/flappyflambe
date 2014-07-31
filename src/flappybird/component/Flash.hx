package flappybird.component;

import flambe.script.Delay;
import flambe.display.Sprite;
import flambe.script.Sequence;
import flambe.script.Shake;
import flambe.script.Parallel;
import flambe.script.CallFunction;
import flambe.script.Sequence;
import flambe.script.Script;
import flambe.script.AnimateTo;
import flambe.Entity;
import flambe.display.FillSprite;
import flambe.Component;

class Flash extends Component
{
    public static inline var FLASH_DURATION = 0.2;

    private var _width :Int;
    private var _height :Int;
    private var _callback :Void -> Void;

    public function new(width :Int, height :Int, ?callback :Void -> Void)
    {
        _width = width;
        _height = height;
        _callback = callback;
    }

    override public function onAdded()
    {
        var filler = new FillSprite(0xFFFFFF, _width, _height);
        filler.alpha._ = .5;
        filler.setXY(0, 0);

        var script = new Script();
        var flash = new Entity().add(filler).add(script);

        script.run(
            new Sequence([
                new Parallel([
                    new Delay((FLASH_DURATION * 2) + 0.2),
                    new CallFunction(function () {
                        var ownerScript = new Script();
                        var ownerSprite :Sprite = owner.get(Sprite);
                        var oldX = ownerSprite.x._;
                        var oldY = ownerSprite.y._;

                        ownerScript.run(new Sequence([
                            new Shake(5, 5, FLASH_DURATION * 2),
                            new CallFunction(function () {
                                ownerSprite.x._ = oldX;
                                ownerSprite.y._ = oldY;
                            })
                        ]));
                        owner.add(ownerScript);
                    }),
                    new Sequence([
                        new AnimateTo(filler.alpha, .8, FLASH_DURATION),
                        new AnimateTo(filler.alpha, 0, FLASH_DURATION),
                    ]),
                ]),
                new CallFunction(function () {
                    owner.removeChild(flash);
                    owner.remove(this);
                    if (_callback != null) {
                        _callback();
                    }
                }),
            ])
        );

        owner.addChild(flash);
    }
}
