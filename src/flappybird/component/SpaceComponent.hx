package flappybird.component;

import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.callbacks.CbType;
import nape.callbacks.CbEvent;
import nape.shape.Shape;
import flambe.math.Rectangle;
import nape.phys.BodyType;
import flappybird.FlappyBirdContext;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.Material;
import nape.shape.Circle;
import nape.shape.Polygon;
import nape.space.Space;

import flambe.asset.AssetPack;
import flambe.Component;
import flambe.display.ImageSprite;
import flambe.Entity;
import flambe.math.FMath;

/**
 * Component that wraps a Nape physics simulation.
 */
class SpaceComponent extends Component
{
    public static inline var BUFFER = 40;
    public static inline var GAPSIZE = 90;

    private var _space :Space;
    private var _ctx :FlappyBirdContext;

    public var sensorType(default, null) :CbType;
    public var visibleType(default, null) :CbType;

    public function new (ctx :FlappyBirdContext, gravity :Int)
    {
        _space = new Space(new Vec2(0, gravity));
        _ctx = ctx;

        sensorType = new CbType();
        visibleType = new CbType();
    }

    override public function onUpdate (dt :Float)
    {
        _space.step(dt);
    }

    public function addBody (body :Body) :Entity
    {
        body.space = _space;
        return new Entity().add(new BodyComponent(body));
    }

    public function getSpace() :Space
    {
        return _space;
    }

    public function stopPipes()
    {
        for (body in _space.bodies) {
            body = cast(body, Body);
            if (body.type == BodyType.KINEMATIC) {
                body.velocity.setxy(0, 0);
                var shape :Shape = body.shapes.at(0);
                shape.filter.collisionGroup = 4;
            }
        }
    }

    public function addPipe(x :Float, speed :Int, bottom :Int) :Array<Entity>
    {
        var upperPipe = new ImageSprite(_ctx.pack.getTexture("Pipe"));
        upperPipe.centerAnchor();

        var lowerPipe = new ImageSprite(_ctx.pack.getTexture("Pipe"));
        lowerPipe.centerAnchor();

        var pipeWidth = upperPipe.getNaturalWidth();
        var pipeHeight = upperPipe.getNaturalHeight();

        var max = (bottom - BUFFER - GAPSIZE);
        var min = BUFFER;
        var topPipeBottom = Math.floor(Math.random() * (max - min)) + min;
        var topPipeY = topPipeBottom - Std.int(pipeHeight / 2);
        var lowerPipeX = topPipeY + GAPSIZE + pipeHeight;

        // Only show the part of the pipe that is above the land.
        lowerPipe.scissor = new Rectangle(0, 0, pipeWidth, bottom - (lowerPipeX - Std.int(pipeHeight / 2)));

        var bodyUpper = new Body(BodyType.KINEMATIC);
        bodyUpper.shapes.add(new Polygon(Polygon.box(pipeWidth, pipeHeight), Material.steel()));
        bodyUpper.position = new Vec2(x + pipeWidth * 2, topPipeY);
        bodyUpper.velocity = new Vec2(-speed, 0);
        bodyUpper.cbTypes.add(visibleType);

        var entityUp = addBody(bodyUpper);
        entityUp.add(upperPipe);

        var sensor = new Body(BodyType.KINEMATIC);
        sensor.position.setxy(x + (pipeWidth * 2), topPipeBottom);
        sensor.cbTypes.add(sensorType);
        sensor.space = _space;
        sensor.velocity = new Vec2(-speed, 0);

        var viewportShape :Shape = new Polygon(Polygon.box(1, bottom));
        viewportShape.sensorEnabled = true;
        viewportShape.body = sensor;

        var bodyLower = new Body(BodyType.KINEMATIC);
        bodyLower.shapes.add(new Polygon(Polygon.box(pipeWidth, pipeHeight), Material.steel()));
        bodyLower.position = new Vec2(x + pipeWidth * 2, lowerPipeX);
        bodyLower.velocity = new Vec2(-speed, 0);
        bodyLower.cbTypes.add(visibleType);

        var entityDown = addBody(bodyLower);
        entityDown.add(lowerPipe);

        return [entityUp, entityDown];
    }
}
