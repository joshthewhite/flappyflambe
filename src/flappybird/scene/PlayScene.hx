package flappybird.scene;

import flambe.display.TextSprite;
import flambe.animation.AnimatedFloat;
import flappybird.FlappyBirdContext;
import flappybird.component.Flash;
import haxe.Timer;

import nape.shape.Shape;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionType;
import nape.callbacks.CbType;
import nape.callbacks.CbEvent;
import nape.callbacks.InteractionListener;
import nape.geom.Vec2;
import nape.shape.Polygon;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;

import flambe.animation.Jitter;
import flambe.util.SignalConnection;
import flambe.script.Action;
import flambe.script.Delay;
import flambe.script.CallFunction;
import flambe.script.Sequence;
import flambe.script.Repeat;
import flambe.script.Script;
import flambe.display.Sprite;
import flambe.display.ImageSprite;
import flambe.animation.Sine;
import flambe.display.PatternSprite;
import flambe.Entity;
import flambe.display.FillSprite;
import flambe.Component;
import flambe.System;

import flappybird.component.Bird;
import flappybird.component.BackgroundScroller;
import flappybird.component.SpaceComponent;
import flappybird.component.BodyComponent;

class PlayScene extends Component
{
    public static inline var GRAVITY = 1000;
    public static inline var MAX_UP_SPEED = -300;
    public static inline var FLAP_FORCE = -1000;

    private var _ctx :FlappyBirdContext;

    private var _getReady :Entity;
    private var _bird :Entity;
    private var _world :Entity;
    private var _land :Entity;
    private var _sky :Entity;
    private var _pipelayer :Entity;
    private var _overlayConnection :SignalConnection;
    private var _birdBody :Body;
    private var _started = false;
    private var _dead = false;
    private var _scoreSprite :TextSprite;

    public var _score = new AnimatedFloat(0);

    public function new (ctx :FlappyBirdContext)
    {
        _ctx = ctx;
    }

    override public function onAdded()
    {
        var background = new FillSprite(0x5BC0C9, System.stage.width, System.stage.height);
        var space = new SpaceComponent(_ctx, GRAVITY);
        _world = new Entity().add(background).add(space);
        owner.addChild(_world);

        // Adds land sprite and physics body.
        var landSprite = addLand();

        var sky = new PatternSprite(_ctx.pack.getTexture("Sky"));
        sky.setSize(System.stage.width + 276, 109);
        sky.setXY(0, System.stage.height - sky.getNaturalHeight() - landSprite.getNaturalHeight());
        _sky = new Entity().add(sky).add(new BackgroundScroller(15, 276));
        _world.addChild(_sky);

        _pipelayer = new Entity();
        _world.addChild(_pipelayer);

        var getReady = new ImageSprite(_ctx.pack.getTexture("GetReady"));
        getReady.centerAnchor().setXY(System.stage.width / 2, System.stage.height * 0.33);
        _getReady = new Entity().add(getReady);
        _world.addChild(_getReady);

        var bird = new Bird(_ctx);
        var birdSprite = bird.bird;
        birdSprite.setAnchor(17, 12);
        birdSprite.setXY((System.stage.width * 0.33) - 17, (System.stage.height / 2) - 12);
        birdSprite.y.behavior = new Sine(birdSprite.y._, birdSprite.y._ + 10, 0.45);
        _bird = new Entity().add(bird);
        _world.addChild(_bird);

        var overlay = new FillSprite(0x000000, System.stage.width, System.stage.height);
        overlay.setAlpha(0);
        _overlayConnection = overlay.pointerDown.connect(flap);
        _world.addChild(new Entity().add(overlay));

        _scoreSprite = new TextSprite(_ctx.title40Font);
        _scoreSprite.text = "" + Std.int(_score._);
        _scoreSprite.centerAnchor().setXY(
            System.stage.width / 2,
            getReady.y._ - (getReady.getNaturalHeight() / 2) - (_scoreSprite.getNaturalHeight() / 2) - 15
        );
        _world.addChild(new Entity().add(_scoreSprite));

        _score.watch(function (score :Float, _) {
            _scoreSprite.text = "" + Std.int(score);
            _scoreSprite.x._ = System.stage.width / 2;
        });
    }

    private function addLand() :PatternSprite
    {
        var landSprite = new PatternSprite(_ctx.pack.getTexture("Land"));

        var offset = 24;
        var speed = 135;
        var x = 0;
        var y = System.stage.height - landSprite.getNaturalHeight();
        var width = System.stage.width + offset;
        var height = 112;

        landSprite.setSize(width, height);
        landSprite.setXY(x, y);
        _land = new Entity().add(landSprite).add(new BackgroundScroller(speed, offset));
        _world.addChild(_land);

        var space :SpaceComponent = _world.get(SpaceComponent);
        var landBody = new Body(BodyType.STATIC);
        landBody.shapes.add(new Polygon(Polygon.rect(x, y, width, height)));
        landBody.cbTypes.add(space.visibleType);
        space.addBody(landBody);

        // Might as well tack on the ceiling here.
        var ceilBody = new Body(BodyType.STATIC);
        ceilBody.shapes.add(new Polygon(Polygon.rect(0, -20, width, 3)));
        space.addBody(ceilBody);

        return landSprite;
    }

    private function flap(_)
    {
        if (!_started) {
            startFlapping();
        }

        _birdBody.applyImpulse(new Vec2(0, FLAP_FORCE));

        if (_birdBody.velocity.y < MAX_UP_SPEED) {
            _birdBody.velocity.y = MAX_UP_SPEED;
        }
    }

    private function startFlapping()
    {
        _started = true;

        var bird :Bird = _bird.get(Bird);
        var sprite :Sprite = bird.bird;

        _world.removeChild(_getReady);
        sprite.y.behavior = null;

        var space :SpaceComponent = _world.get(SpaceComponent);

        var birdType = new CbType();

        _birdBody = new Body();
        var birdShape = new Polygon(Polygon.box(34, 24), Material.sand());
        birdShape.filter.collisionMask = ~4;
        _birdBody.shapes.add(birdShape);
        _birdBody.position = new Vec2(sprite.x._, sprite.y._);
        _birdBody.cbTypes.add(birdType);
        _birdBody.space = space.getSpace();

        _bird.add(new BodyComponent(_birdBody, true));

        var landSprite :Sprite = _land.get(Sprite);

        var pipeScript = new Script();
        var scripts = new Array<Action>();
        scripts.push(new CallFunction(function () {
            var entities = space.addPipe(
                System.stage.width,
                FlappyBirdContext.LAND_SPEED,
                Std.int(landSprite.y._)
            );

            for (entity in entities) {
                _pipelayer.addChild(entity);
            }
        }));
        scripts.push(new Delay(1.15));
        pipeScript.run(new Repeat(new Sequence(scripts)));
        _world.add(pipeScript);

        space.getSpace().listeners.add(new InteractionListener(
            CbEvent.BEGIN,
            InteractionType.COLLISION,
            space.visibleType,
            birdType,
            handleCollision
        ));

        space.getSpace().listeners.add(new InteractionListener(
            CbEvent.BEGIN,
            InteractionType.SENSOR,
            birdType,
            space.sensorType,
            handleScore
        ));
    }

    private function handleScore(e :InteractionCallback) :Void
    {
        _score._ += 1;
    }

    private function handleCollision(e :InteractionCallback)
    {
        // Find the one that isn't the bird.
        var int = e.int1;
        var shape :Shape = int.castShape;
        var body :Body = int.castBody;
        var normal = body.arbiters.at(0).collisionArbiter.normal;

        if (normal.y == 1 && body.type == BodyType.STATIC) {
            return;
        }

        if (_dead) {
            return;
        }
        _dead = true;

        _world.add(new Flash(System.stage.width, System.stage.height, function () {
            _ctx.showPrompt(Std.int(_score._));
        }));

        if (_score._ > _ctx.bestScore) {
            _ctx.bestScore = Std.int(_score._);
        }

        // Stop everything.
        _overlayConnection.dispose();
        _scoreSprite.alpha.animateTo(0, 0.2);
        _world.get(SpaceComponent).stopPipes();
        _land.get(BackgroundScroller).speed._ = 0;
        _sky.get(BackgroundScroller).speed._ = 0;
        _world.remove(_world.get(Script));
        _birdBody.velocity.x = 0;
    }
}
