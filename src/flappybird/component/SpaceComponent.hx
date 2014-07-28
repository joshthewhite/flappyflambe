package flappybird.component;

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

    public function new (ctx :FlappyBirdContext, gravity :Int)
    {
        _space = new Space(new Vec2(0, gravity));
        _ctx = ctx;
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

    public function laySomePipe(x :Float, speed :Int, bottom :Int) :Array<Entity>
    {
        var upperPipe = new ImageSprite(_ctx.pack.getTexture("PipeWide"));
        upperPipe.centerAnchor();

        var lowerPipe = new ImageSprite(_ctx.pack.getTexture("PipeWide"));
        lowerPipe.centerAnchor();

        var pipeWidth = upperPipe.getNaturalWidth();
        var pipeHeight = upperPipe.getNaturalHeight();

        var max = (bottom - BUFFER - GAPSIZE);
        var min = BUFFER;
        var topPipeX = Math.floor(Math.random() * (max - min)) + min;
        topPipeX = topPipeX - Std.int(pipeHeight / 2);
        var lowerPipeX = topPipeX + GAPSIZE + pipeHeight;

        lowerPipe.scissor = new Rectangle(0, 0, pipeWidth, bottom - (lowerPipeX - Std.int(pipeHeight / 2)));

        var bodyUpper = new Body(BodyType.KINEMATIC);
        bodyUpper.shapes.add(new Polygon(Polygon.box(pipeWidth, pipeHeight), Material.steel()));
        bodyUpper.position = new Vec2(x + pipeWidth * 2, topPipeX);
        bodyUpper.velocity = new Vec2(-speed, 0);

        var entityUp = addBody(bodyUpper);
        entityUp.add(upperPipe);

        var bodyLower = new Body(BodyType.KINEMATIC);
        bodyLower.shapes.add(new Polygon(Polygon.box(pipeWidth, pipeHeight), Material.steel()));
        bodyLower.position = new Vec2(x + pipeWidth * 2, lowerPipeX);
        bodyLower.velocity = new Vec2(-speed, 0);

        var entityDown = addBody(bodyLower);
        entityDown.add(lowerPipe);

        return [entityUp, entityDown];
    }
}
