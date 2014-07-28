package flappybird.component;

import flambe.Component;
import flambe.animation.AnimatedFloat;
import flambe.display.Sprite;

class BackgroundScroller extends Component
{
    public var speed :AnimatedFloat;
    public var jumpSize :Int;

    public function new (speed :Float, jumpSize :Int)
    {
        this.speed = new AnimatedFloat(speed);
        this.jumpSize = jumpSize;
    }

    override public function onUpdate (dt :Float)
    {
        speed.update(dt);

        var sprite :Sprite = owner.get(Sprite);
        sprite.x._ -= dt * speed._;
        while (sprite.x._ < (jumpSize * -1)) {
            sprite.x._ += jumpSize;
        }
    }
}
