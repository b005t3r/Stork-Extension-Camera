package {

import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

import stork.camera.CameraNode;
import stork.camera.CameraProjectionNode;
import stork.camera.CameraSpaceNode;
import stork.camera.StarlingProjectionNode;
import stork.camera.policy.AspectFitPolicy;
import stork.core.SceneNode;
import stork.event.SceneEvent;
import stork.event.TweenEvent;
import stork.game.DelegateActionNode;
import stork.game.GameLoopNode;
import stork.starling.SimpleResizePolicy;
import stork.starling.StarlingPlugin;
import stork.transition.TweenTransitions;
import stork.tween.AbstractTweenNode;
import stork.tween.JugglerNode;
import stork.tween.TimelineNode;
import stork.tween.TweenNode;

[SWF(width="720", height="480", backgroundColor="#666666", frameRate="60")]
public class StarlingDemoMain extends Sprite {
    private static const JUGGLER_PRIORITY:int           = 10;
    private static const PRE_VALIDATION_PRIORITY:int    = 24;
    private static const VALIDATION_PRIORITY:int        = 25;
    private static const POST_VALIDATION_PRIORITY:int   = 26;
    private static const PROJECTION_PRIORITY:int        = 30;

    private var _cameraSprite:CameraSprite;

    private var _cameraSpace:CameraSpaceNode;
    private var _camera:CameraNode;
    private var _cameraProjection:StarlingProjectionNode;

    private var _gameLoop:GameLoopNode;
    private var _juggler:JugglerNode;
    private var _scaleTween:AbstractTweenNode;
    private var _transitionTween:AbstractTweenNode;
    private var _rotateTween:AbstractTweenNode;
    private var _anchorTween:AbstractTweenNode;
    private var _alignmentTween:AbstractTweenNode;

    public function StarlingDemoMain() {
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    private function onAddedToStage(event:Event):void {
        var scene:SceneNode = new SceneNode();

        scene.registerPlugin(new StarlingPlugin(CameraRoot, this, new SimpleResizePolicy(), true));

        _gameLoop = new GameLoopNode();
        scene.addNode(_gameLoop);

        _juggler = new JugglerNode(JUGGLER_PRIORITY);
        scene.addNode(_juggler);
        _gameLoop.addNode(_juggler.stepAction);

        _cameraSpace = new CameraSpaceNode(0, 600 - 10, 0, 600 - 10);
        scene.addNode(_cameraSpace);

        _camera = new CameraNode(5, 5, 30, 20, VALIDATION_PRIORITY);
        _cameraSpace.addNode(_camera);
        _gameLoop.addNode(_camera.validateAction);

        scene.addEventListener(SceneEvent.SCENE_STARTED, function(e:SceneEvent):void {
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
            stage.addEventListener(Event.RESIZE, onResize);

            var viewport:CameraRoot = scene.getObjectByClass(CameraRoot) as CameraRoot;
            _cameraProjection = new StarlingProjectionNode(viewport, new AspectFitPolicy(), stage.stageWidth, stage.stageHeight, PROJECTION_PRIORITY);
            _camera.addNode(_cameraProjection);
            _gameLoop.addNode(_cameraProjection.updateAction);

            _cameraSprite           = new CameraSprite(_camera.viewport.width, _camera.viewport.height, _camera.anchor.x * _camera.viewport.width, _camera.anchor.y * _camera.viewport.height);
            _cameraSprite.alpha     = 0.2;
            _cameraSprite.x         = _camera.viewport.x;
            _cameraSprite.y         = _camera.viewport.y;
            _cameraSprite.pivotX    = _camera.viewport.width * _camera.anchor.x;
            _cameraSprite.pivotY    = _camera.viewport.height * _camera.anchor.y;
            viewport.addChild(_cameraSprite);

            _gameLoop.addNode(new DelegateActionNode(PRE_VALIDATION_PRIORITY, "PreCameraValidationAction", function(dt:Number):void {
                if(_transitionTween == null && _anchorTween == null && _rotateTween == null && _scaleTween == null)
                    mapCameraToSprite(_cameraSprite, _camera);
                else
                    mapSpriteToCamera(_cameraSprite, _camera);
            }));

            _gameLoop.addNode(new DelegateActionNode(POST_VALIDATION_PRIORITY, "PostCameraValidationAction", function(dt:Number):void {
                mapSpriteToCamera(_cameraSprite, _camera);
            }));
        });

        scene.start();
    }

    private function mapSpriteToCamera(sprite:CameraSprite, camera:CameraNode):void {
        sprite.x        = camera.viewport.x;
        sprite.y        = camera.viewport.y;
        sprite.width    = camera.viewport.width;
        sprite.height   = camera.viewport.height;
        sprite.pivotX   = camera.viewport.width * camera.anchor.x;
        sprite.pivotY   = camera.viewport.height * camera.anchor.y;
        sprite.scaleX   = camera.scale.x;
        sprite.scaleY   = camera.scale.y;
        sprite.rotation = camera.rotation;
    }

    private function mapCameraToSprite(sprite:CameraSprite, camera:CameraNode):void {
        camera.viewport.x       = sprite.x;
        camera.viewport.y       = sprite.y;
        camera.viewport.width   = sprite.width;
        camera.viewport.height  = sprite.height;
    }

    private function onResize(event:Event):void {
        _cameraProjection.viewportWidth = Stage(event.target).stageWidth;
        _cameraProjection.viewportHeight = Stage(event.target).stageHeight;
    }

    private function onKeyDown(event:KeyboardEvent):void {
        switch(event.keyCode) {
            case Keyboard.C:
                _cameraProjection.active = ! _cameraProjection.active;
                break;

            case Keyboard.Q:
                if(_rotateTween == null) {
                    _rotateTween = createRotateTween(_camera);
                    _rotateTween.addEventListener(TweenEvent.FINISHED, function(e:TweenEvent):void { _rotateTween = null; });
                    _juggler.addNode(_rotateTween);
                }
                break;

            case Keyboard.W:
                if(_transitionTween == null) {
                    _transitionTween = createTransitionTween(_camera);
                    _transitionTween.addEventListener(TweenEvent.FINISHED, function(e:TweenEvent):void { _transitionTween = null; });
                    _juggler.addNode(_transitionTween);
                }
                break;

            case Keyboard.E:
                if(_anchorTween == null) {
                    _anchorTween = createAnchorTween(_camera);
                    _anchorTween.addEventListener(TweenEvent.FINISHED, function(e:TweenEvent):void { _anchorTween = null; });
                    _juggler.addNode(_anchorTween);
                }
                break;

            case Keyboard.R:
                if(_scaleTween == null) {
                    _scaleTween = createScaleTween(_camera);
                    _scaleTween.addEventListener(TweenEvent.FINISHED, function(e:TweenEvent):void { _scaleTween = null; });
                    _juggler.addNode(_scaleTween);
                }
                break;

            case Keyboard.T:
                if(_alignmentTween == null) {
                    _alignmentTween = createAlignmentTween(_cameraProjection);
                    _alignmentTween.addEventListener(TweenEvent.FINISHED, function(e:TweenEvent):void { _alignmentTween = null; });
                    _juggler.addNode(_alignmentTween);
                }
                break;

            case Keyboard.A:
                _camera.validate();
                mapSpriteToCamera(_cameraSprite, _camera);
                break;
        }
    }

    private function createScaleTween(camera:CameraNode):AbstractTweenNode {
        var scaleUp:TweenNode   = new TweenNode(camera.scale, 2.5, TweenTransitions.EASE_IN_OUT);
        var scaleDown:TweenNode = new TweenNode(camera.scale, 3.5, TweenTransitions.EASE_IN_OUT);

        scaleUp.animateFromTo("x", camera.scale.x, 2);
        scaleUp.animateFromTo("y", camera.scale.y, 2);

        scaleDown.animateFromTo("x", 2, 1.5);
        scaleDown.animateFromTo("y", 2, 1.5);

        var timeline:TimelineNode = new TimelineNode();
        timeline.addTween(scaleUp);
        timeline.addTween(scaleDown);
        timeline.repeatCount = 2;
        timeline.repeatReversed = true;

        return timeline;
    }

    private function createTransitionTween(camera:CameraNode):AbstractTweenNode {
        var moveRight:TweenNode = new TweenNode(camera.viewport, 1);
        var moveDown:TweenNode  = new TweenNode(camera.viewport, 1);
        var moveLeft:TweenNode  = new TweenNode(camera.viewport, 1);
        var moveUp:TweenNode    = new TweenNode(camera.viewport, 1);

        moveRight.animateFromTo("x", camera.viewport.x, camera.viewport.x + 40);
        moveDown.animateFromTo("y", camera.viewport.y, camera.viewport.y + 25);
        moveLeft.animateFromTo("x", camera.viewport.x + 40, camera.viewport.x);
        moveUp.animateFromTo("y", camera.viewport.y + 25, camera.viewport.y);

        var timeline:TimelineNode = new TimelineNode(TweenTransitions.EASE_IN_OUT);
        timeline.addTween(moveRight);
        timeline.addTween(moveDown);
        timeline.addTween(moveLeft);
        timeline.addTween(moveUp);

        return timeline;
    }

    private function createRotateTween(camera:CameraNode):AbstractTweenNode {
        var rotateQuarterAndBackTween:TweenNode = new TweenNode(camera, 1, TweenTransitions.EASE_IN);
        var rotateWholeAndBackTween:TweenNode   = new TweenNode(camera, 2, TweenTransitions.EASE_IN);

        rotateQuarterAndBackTween.animateTo("rotation", Math.PI * 0.25);
        rotateQuarterAndBackTween.repeatCount = 2;
        rotateQuarterAndBackTween.repeatReversed = true;

        rotateWholeAndBackTween.animateTo("rotation", Math.PI * 2);
        rotateWholeAndBackTween.repeatCount = 2;
        rotateWholeAndBackTween.repeatReversed = true;

        var timeline:TimelineNode = new TimelineNode();
        timeline.addTween(rotateQuarterAndBackTween);
        timeline.addTween(rotateWholeAndBackTween);

        return timeline;
    }

    private function createAnchorTween(camera:CameraNode):AbstractTweenNode {
        var moveRight:TweenNode = new TweenNode(camera.anchor, 1);
        var moveDown:TweenNode  = new TweenNode(camera.anchor, 1);
        var moveLeft:TweenNode  = new TweenNode(camera.anchor, 1);
        var moveUp:TweenNode    = new TweenNode(camera.anchor, 1);

        moveRight.animateFromTo("x", camera.anchor.x, 0.66);
        moveDown.animateFromTo("y", camera.anchor.y, 0.66);
        moveLeft.animateFromTo("x", 0.66, 0.33);
        moveUp.animateFromTo("y", 0.66, 0.33);

        var timeline:TimelineNode = new TimelineNode(TweenTransitions.EASE_IN_OUT);
        timeline.addTween(moveRight);
        timeline.addTween(moveDown);
        timeline.addTween(moveLeft);
        timeline.addTween(moveUp);
        timeline.repeatReversed = true;
        timeline.repeatCount = 2;

        return timeline;
    }

    private function createAlignmentTween(projection:CameraProjectionNode):AbstractTweenNode {
        var maxTween:TweenNode = new TweenNode(projection.policy, 1, TweenTransitions.EASE_IN_OUT);
        var minTween:TweenNode = new TweenNode(projection.policy, 1, TweenTransitions.EASE_IN_OUT);

        var val:Number = projection.policy["alignment"];
        maxTween.animateFromTo("alignment", val, 1);
        minTween.animateFromTo("alignment", 1, 0);

        var timeline:TimelineNode = new TimelineNode();
        timeline.addTween(maxTween);
        timeline.addTween(minTween);
        timeline.repeatReversed = true;
        timeline.repeatCount = 4;

        return timeline;
    }
}
}
