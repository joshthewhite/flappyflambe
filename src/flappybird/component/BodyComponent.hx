package flappybird.component;

import nape.phys.Body;

import flambe.Component;
import flambe.display.Sprite;
import flambe.math.FMath;
import flambe.System;

/**
 * Tracks a body, and updates the placement of the entity's sprite.
 */
class BodyComponent extends Component
{
    private var _body :Body;

    public function new (body :Body)
    {
        _body = body;
    }

    public function getBody() :Body
    {
        return _body;
    }

    override public function onUpdate(dt :Float)
    {
        var pos = _body.position;
        if (pos.x < -100) {
            owner.dispose();
        } else {
            var sprite :Sprite = owner.get(Sprite);
            sprite.x._ = pos.x;
            sprite.y._ = pos.y;
            sprite.rotation._ = FMath.toDegrees(_body.rotation);
        }
    }

    override public function onRemoved()
    {
        // Remove this body from the space
        _body.space = null;
    }
}
