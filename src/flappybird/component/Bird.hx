package flappybird.component;

import flambe.swf.MovieSprite;
import flambe.Component;

class Bird extends Component
{
    private var _ctx :FlappyBirdContext;
    public var bird(default, null) :MovieSprite;

    public function new(ctx :FlappyBirdContext)
    {
        _ctx = ctx;
        bird = _ctx.library.createMovie("bird");
    }

    override public function onAdded()
    {
        owner.add(bird);
    }

    override public function onUpdate(dt :Float)
    {

    }
}
