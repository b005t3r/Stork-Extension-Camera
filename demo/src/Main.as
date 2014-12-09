package {

import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.geom.Matrix;
import flash.ui.Keyboard;

import stork.camera.CameraNode;
import stork.camera.CameraProjectionNode;
import stork.camera.CameraSpaceNode;
import stork.camera.policy.AspectFillPolicy;
import stork.camera.policy.AspectFitPolicy;
import stork.core.SceneNode;
import stork.event.SceneEvent;
import stork.event.SceneStepEvent;
import stork.event.TweenEvent;
import stork.starling.SimpleResizePolicy;
import stork.starling.StarlingPlugin;
import stork.transition.TweenTransitions;
import stork.tween.AbstractTweenNode;
import stork.tween.JugglerNode;
import stork.tween.TimelineNode;
import stork.tween.TweenNode;

[SWF(width="480", height="720", backgroundColor="#666666", frameRate="60")]
public class Main extends Sprite {
    private var _useCamera:Boolean = false;
    private var _cameraSprite:CameraSprite;

    private var _camera:CameraNode;
    private var _cameraProjection:CameraProjectionNode;

    private var _juggler:JugglerNode;
    private var _scaleTween:AbstractTweenNode;
    private var _transitionTween:AbstractTweenNode;
    private var _rotateTween:AbstractTweenNode;
    private var _anchorTween:AbstractTweenNode;
    private var _alignmentTween:AbstractTweenNode;

    public function Main() {
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    private function onAddedToStage(event:Event):void {
        var scene:SceneNode = new SceneNode();

        scene.registerPlugin(new StarlingPlugin(CameraRoot, this, new SimpleResizePolicy(), true));

        _juggler = new JugglerNode();
        scene.addNode(_juggler);

        var cameraSpace:CameraSpaceNode = new CameraSpaceNode();
        scene.addNode(cameraSpace);

        _camera = new CameraNode(5, 5, 30, 20);
        //_camera.anchor.x = 0.5;
        //_camera.anchor.y = 1;
        cameraSpace.addNode(_camera);

        //_cameraProjection = new CameraProjectionNode(new AspectFitPolicy(), stage.stageWidth, stage.stageHeight);
        _cameraProjection = new CameraProjectionNode(new AspectFillPolicy(), stage.stageWidth, stage.stageHeight);
        //AspectFitPolicy(_cameraProjection.policy).alignment = 1.0;
        _camera.addNode(_cameraProjection);

        stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        stage.addEventListener(Event.RESIZE, onResize);

        scene.addEventListener(SceneEvent.SCENE_STARTED, function(e:SceneEvent):void {
            var viewport:CameraRoot = scene.getObjectByClass(CameraRoot) as CameraRoot;
            _cameraSprite = new CameraSprite(_camera.viewport.width, _camera.viewport.height, _camera.anchor.x * _camera.viewport.width, _camera.anchor.y * _camera.viewport.height);
            _cameraSprite.alpha = 0.2;
            _cameraSprite.x = _camera.viewport.x;
            _cameraSprite.y = _camera.viewport.y;
            _cameraSprite.pivotX = _camera.viewport.width * _camera.anchor.x;
            _cameraSprite.pivotY = _camera.viewport.height * _camera.anchor.y;

            viewport.addChild(_cameraSprite);

            scene.addEventListener(SceneStepEvent.STEP, function(e:SceneStepEvent):void {
                if(_transitionTween == null && _anchorTween == null && _rotateTween == null && _scaleTween == null) {
                    mapCameraToSprite(_cameraSprite, _camera);
                }
                else {
                    mapSpriteToCamera(_cameraSprite, _camera);
                }

                if(_useCamera) {
                    _cameraProjection.update();
                    viewport.transformationMatrix = _cameraProjection.transformationMatrix;
                }
                else {
                    viewport.transformationMatrix = new Matrix();
                }
            });
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
                _useCamera = ! _useCamera;
                break;

            case Keyboard.Q:
                if(_rotateTween == null) {
                    _rotateTween = createRotateTween(_camera);
                    _rotateTween.addEventListener(TweenEvent.FINISHED, function(e:TweenEvent) { _rotateTween = null; });
                    _juggler.addNode(_rotateTween);
                }
                break;

            case Keyboard.W:
                if(_transitionTween == null) {
                    _transitionTween = createTransitionTween(_camera);
                    _transitionTween.addEventListener(TweenEvent.FINISHED, function(e:TweenEvent) { _transitionTween = null; });
                    _juggler.addNode(_transitionTween);
                }
                break;

            case Keyboard.E:
                if(_anchorTween == null) {
                    _anchorTween = createAnchorTween(_camera);
                    _anchorTween.addEventListener(TweenEvent.FINISHED, function(e:TweenEvent) { _anchorTween = null; });
                    _juggler.addNode(_anchorTween);
                }
                break;

            case Keyboard.R:
                if(_scaleTween == null) {
                    _scaleTween = createScaleTween(_camera);
                    _scaleTween.addEventListener(TweenEvent.FINISHED, function(e:TweenEvent) { _scaleTween = null; });
                    _juggler.addNode(_scaleTween);
                }
                break;

            case Keyboard.T:
                if(_alignmentTween == null) {
                    _alignmentTween = createAlignmentTween(_cameraProjection);
                    _alignmentTween.addEventListener(TweenEvent.FINISHED, function(e:TweenEvent) { _alignmentTween = null; });
                    _juggler.addNode(_alignmentTween);
                }
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
        var maxTween:TweenNode = new TweenNode(projection.policy, 2, TweenTransitions.EASE_IN_OUT);
        var minTween:TweenNode = new TweenNode(projection.policy, 2, TweenTransitions.EASE_IN_OUT);

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
