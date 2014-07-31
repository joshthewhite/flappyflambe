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
    private var _isBird :Bool;

    public function new (body :Body, isBird = false)
    {
        _body = body;
        _isBird = isBird;
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
            return;
        }

        var sprite :Sprite = owner.get(Sprite);
        sprite.x._ = pos.x;
        sprite.y._ = pos.y;
        //sprite.rotation._ = FMath.toDegrees(_body.rotation);

        if (_isBird) {
            var velY = _body.velocity.y;
            var rotation = 45.0;
            if (velY <= -50) {
                rotation = -25.0;
            } else if (velY < 350) {
                rotation = velY * (45 / 350);
            }
            sprite.rotation._ = rotation;
        }
    }

    override public function onRemoved()
    {
        // Remove this body from the space
        _body.space = null;
    }
}
