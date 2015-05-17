/**
 * User: booster
 * Date: 11/12/14
 * Time: 16:08
 */
package {
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.GameInputEvent;
import flash.events.KeyboardEvent;
import flash.ui.GameInput;
import flash.ui.GameInputControl;
import flash.ui.GameInputDevice;
import flash.ui.Keyboard;

import medkit.geom.shapes.Point2D;

import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Polygon;
import nape.space.Space;
import nape.util.ShapeDebug;

import platformer.HorizontalDragConstraint;
import platformer.JumpAction;
import platformer.Materials;
import platformer.MaxVelocityConstraint;
import platformer.MoveAction;

import starling.display.StorkRoot;

import stork.camera.CameraNode;
import stork.camera.CameraSpaceNode;
import stork.camera.FlashProjectionNode;
import stork.camera.assistant.panning.DelegatePanningTarget;
import stork.camera.assistant.panning.PanningAssistantNode;
import stork.camera.policy.AspectFitPolicy;
import stork.core.SceneNode;
import stork.event.nape.NapeSpaceEvent;
import stork.game.GameLoopNode;
import stork.nape.NapeSpaceNode;
import stork.nape.debug.NapeDebugDisplayNode;
import stork.nape.debug.NapeDebugDragNode;
import stork.nape.physics.IAction;
import stork.nape.physics.IConstraint;
import stork.nape.physics.NapePhysicsControllerNode;
import stork.starling.StarlingPlugin;

[SWF(width="720", height="480", backgroundColor="#333333", frameRate="60")]
public class NapeDemoMain extends Sprite {
    private static const NAPE_PRIORITY:int              = 10;
    private static const UPDATE_PRIORITY:int            = 20;
    private static const VALIDATION_PRIORITY:int        = 30;
    private static const PROJECTION_PRIORITY:int        = 40;

    private var _gameLoop:GameLoopNode                  = new GameLoopNode();

    private var _character:Body                         = new Body(BodyType.DYNAMIC);
    private var _moveAction:IAction                     = new MoveAction(25);
    private var _jumpAction:IAction                     = new JumpAction(25 * 8);
    private var _dragConstraint:IConstraint             = new HorizontalDragConstraint(25);
    private var _maxVelocityConstraint:IConstraint      = new MaxVelocityConstraint(750, 750, 150, 150);

    private var _gameInput:GameInput                    = new GameInput();

    private var _cameraSpace:CameraSpaceNode;
    private var _camera:CameraNode;
    private var _cameraProjection:FlashProjectionNode;

    public function NapeDemoMain() {
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    private function onAddedToStage(event:Event):void {
        var scene:SceneNode = new SceneNode();

        scene.registerPlugin(new StarlingPlugin(StorkRoot, this));
        scene.addNode(_gameLoop);

        _cameraSpace = new CameraSpaceNode(0, stage.stageWidth, 0, stage.stageHeight);
        scene.addNode(_cameraSpace);

        _camera = new CameraNode(0, 0, 360, 240, VALIDATION_PRIORITY);
        _camera.anchor.y = 0.75;
        _cameraSpace.addNode(_camera);
        _gameLoop.addNode(_camera.validateAction);

        var shapeDebug:ShapeDebug = new ShapeDebug(2000, 2000, 0x00000000);
        _cameraProjection = new FlashProjectionNode(shapeDebug.display, new AspectFitPolicy(), stage.stageWidth, stage.stageHeight, PROJECTION_PRIORITY);
        _camera.addNode(_cameraProjection);
        _gameLoop.addNode(_cameraProjection.updateAction);

        var s:Space = new Space(Vec2.weak(0, 1200));
        s.worldLinearDrag = 0;  // so the character is not slowed down by the "air" resistance

        var space:NapeSpaceNode = new NapeSpaceNode(s, NAPE_PRIORITY);
        scene.addNode(space);

        _gameLoop.addNode(space.action);

        var debug:NapeDebugDisplayNode = new NapeDebugDisplayNode(shapeDebug);
        scene.addNode(debug);

        debug.debug.drawConstraints = true;
        addChild(debug.debug.display);

        var drag:NapeDebugDragNode = new NapeDebugDragNode();
        scene.addNode(drag);

        drag.mouseDragTarget = shapeDebug.display;

        setUp(space.space);

        var bodyController:NapePhysicsControllerNode = new NapePhysicsControllerNode();
        scene.addNode(bodyController);

        bodyController.addAction(_character, _moveAction);
        bodyController.addAction(_character, _jumpAction);
        bodyController.addConstraint(_dragConstraint);
        bodyController.addConstraint(_maxVelocityConstraint);

        var panningAssistant:PanningAssistantNode = new PanningAssistantNode(UPDATE_PRIORITY);
        _camera.addNode(panningAssistant);
        _gameLoop.addNode(panningAssistant.followTargetAction);

        panningAssistant.target = new DelegatePanningTarget(function(p:Point2D):void {
            p.x = _character.position.x;
            p.y = _character.position.y;
        });
        panningAssistant.followSpeed.x = 3;
        panningAssistant.followSpeed.y = 5;

        scene.start();

        stage.addEventListener(Event.RESIZE, onResize);
        stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);

        space.addEventListener(NapeSpaceEvent.POST_UPDATE, onPostUpdate);

        _gameInput.addEventListener(GameInputEvent.DEVICE_ADDED, onDeviceAdded);
        _gameInput.addEventListener(GameInputEvent.DEVICE_REMOVED, onDeviceRemoved);
        _gameInput.addEventListener(GameInputEvent.DEVICE_UNUSABLE, onDeviceUnusable);
    }

    private function onDeviceAdded(event:GameInputEvent):void {
        var device:GameInputDevice = event.device;

        trace("device added: ", device);

        device.enabled = true;

        var count:int = device.numControls;
        for(var i:int = 0; i < count; ++i) {
            var deviceControl:GameInputControl = device.getControlAt(i);
            deviceControl.addEventListener(Event.CHANGE, onGameInputControlChange);

            trace("control: ", deviceControl.id);
        }
    }

    private function onGameInputControlChange(event:Event):void {
        var deviceControl:GameInputControl = event.target as GameInputControl;
        var value:Number = deviceControl.value;

        trace(deviceControl.id, ": ", deviceControl.value);

        if(deviceControl.id == "AXIS_1") {
            if(Math.abs(value) < 0.01) {
                _moveAction.deactivate();
                _dragConstraint.active = true;
            }
            else {
                _moveAction.activate(value);
                _dragConstraint.active = false;
            }
        }

        if(deviceControl.id == "BUTTON_9" && value > 0) {
            _jumpAction.activate(1);
        }
    }

    private function onDeviceRemoved(event:GameInputEvent):void {
        trace("device removed: ", event.device);
    }

    private function onDeviceUnusable(event:GameInputEvent):void {
        trace("device unusable: ", event.device);
    }

    private function onPostUpdate(event:NapeSpaceEvent):void {
        var velocity:Vec2 = _character.velocity;

        //trace("velocity: [", int(velocity.x * 1000) / 1000.0, ", ", int(velocity.y * 1000) / 1000.0, "]");
    }

    private function onResize(event:Event):void {
        _cameraProjection.viewportWidth = Stage(event.target).stageWidth;
        _cameraProjection.viewportHeight = Stage(event.target).stageHeight;
    }

    private function onKeyUp(event:KeyboardEvent):void {
        switch(event.keyCode) {
            case Keyboard.LEFT:
            case Keyboard.RIGHT:
                _moveAction.deactivate();
                _dragConstraint.active = true;
                break;

            case Keyboard.UP:
            case Keyboard.SPACE:
                break;
        }
    }

    private function onKeyDown(event:KeyboardEvent):void {
        switch(event.keyCode) {
            case Keyboard.LEFT:
                _moveAction.activate(-1);
                _dragConstraint.active = false;
                break;

            case Keyboard.RIGHT:
                _moveAction.activate(1);
                _dragConstraint.active = false;
                break;

            case Keyboard.UP:
            case Keyboard.SPACE:
                _jumpAction.activate(1);
                break;
        }
    }

    private function setUp(space:Space):void {
        var w:int = stage.stageWidth;
        var h:int = stage.stageHeight;

        // Create a static border around stage.
        var border:Body = new Body(BodyType.STATIC);
        border.shapes.add(new Polygon(Polygon.rect(0, 0, w, -1)));
        border.shapes.add(new Polygon(Polygon.rect(0, h, w, 1)));
        border.shapes.add(new Polygon(Polygon.rect(0, 0, -1, h)));
        border.shapes.add(new Polygon(Polygon.rect(w, 0, 1, h)));
        border.space = space;

        border.cbTypes.add(JumpAction.FLOOR);

        var floor:Body = new Body(BodyType.STATIC);
        floor.shapes.add(new Polygon(Polygon.rect(50, h - 50, w - 100, 1)));

        // stairs
        floor.shapes.add(new Polygon(Polygon.rect(50, h - 250, 50, 200)));
        floor.shapes.add(new Polygon(Polygon.rect(100, h - 200, 50, 150)));
        floor.shapes.add(new Polygon(Polygon.rect(150, h - 150, 50, 100)));
        floor.shapes.add(new Polygon(Polygon.rect(200, h - 100, 50, 50)));

        // obstacle
        floor.shapes.add(new Polygon(Polygon.rect(300, h - 100, 50, 50)));

        // floating platforms
        floor.shapes.add(new Polygon(Polygon.rect(150, h - 300, 150, 50)));
        floor.shapes.add(new Polygon(Polygon.rect(350, h - 350, 150, 50)));

        floor.space = space;

        floor.cbTypes.add(JumpAction.FLOOR);

        _character.shapes.add(new Polygon(Polygon.box(16, 32)));
        _character.position.setxy((w / 2), ((h - 50) - 32));
        _character.allowRotation = false;
        _character.setShapeMaterials(Materials.characterMaterial());
        _character.space = space;
        _character.cbTypes.add(JumpAction.CHARACTER);
    }
}
}
