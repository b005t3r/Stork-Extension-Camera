package {

import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.geom.Matrix;
import flash.ui.Keyboard;

import stork.camera.CameraNode;
import stork.camera.CameraProjectionNode;
import stork.camera.CameraSpaceNode;
import stork.camera.policy.AspectFitPolicy;
import stork.core.SceneNode;
import stork.event.SceneEvent;
import stork.event.SceneStepEvent;
import stork.starling.StarlingPlugin;
import stork.transition.TweenTransitions;
import stork.tween.JugglerNode;
import stork.tween.TweenNode;

[SWF(width="480", height="480", backgroundColor="#666666", frameRate="60")]
public class Main extends Sprite {
    private var _useCamera:Boolean = false;
    private var _cameraQuad:CameraSprite;

    private var _camera:CameraNode;
    private var _cameraProjection:CameraProjectionNode;

    public function Main() {
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    private function onAddedToStage(event:Event):void {
        var scene:SceneNode = new SceneNode();

        scene.registerPlugin(new StarlingPlugin(CameraRoot, this, null, true));

        var juggler:JugglerNode = new JugglerNode();
        scene.addNode(juggler);

        var cameraSpace:CameraSpaceNode = new CameraSpaceNode();
        scene.addNode(cameraSpace);

        _camera = new CameraNode(5, 5, 30, 20);
        //_camera.scale.x = 2;
        //_camera.scale.y = 2;
        _camera.anchor.x = 0.333;
        _camera.anchor.y = 0.333;
        cameraSpace.addNode(_camera);

        var scaleTween:TweenNode = new TweenNode(_camera.scale, 2, TweenTransitions.EASE_IN_OUT);
        scaleTween.animateFromTo("x", 1, 2);
        scaleTween.animateFromTo("y", 1, 2);
        scaleTween.repeatCount = 0;
        scaleTween.repeatReversed = true;

        var rotateTween:TweenNode = new TweenNode(_camera, 2, TweenTransitions.EASE_IN_OUT);
        rotateTween.animateFromTo("rotation", 0, Math.PI);
        rotateTween.repeatCount = 0;
        rotateTween.repeatReversed = true;

        juggler.addNode(scaleTween);
        juggler.addNode(rotateTween);

        _cameraProjection = new CameraProjectionNode(new AspectFitPolicy(), stage.stageWidth, stage.stageHeight);
        _camera.addNode(_cameraProjection);

        stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);

        scene.addEventListener(SceneEvent.SCENE_STARTED, function(e:SceneEvent):void {
            var viewport:CameraRoot = scene.getObjectByClass(CameraRoot) as CameraRoot;
            _cameraQuad = new CameraSprite(_camera.viewport.width, _camera.viewport.height, _camera.anchor.x * _camera.viewport.width, _camera.anchor.y * _camera.viewport.height);
            _cameraQuad.alpha = 0.2;
            _cameraQuad.x = _camera.viewport.x;
            _cameraQuad.y = _camera.viewport.y;

            viewport.addChild(_cameraQuad);

            scene.addEventListener(SceneStepEvent.STEP, function(e:SceneStepEvent):void {
                _camera.viewport.x = _cameraQuad.x;
                _camera.viewport.y = _cameraQuad.y;
                _camera.viewport.width = _cameraQuad.width;
                _camera.viewport.height = _cameraQuad.height;

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

    private function onKeyDown(event:KeyboardEvent):void {
        if(event.keyCode == Keyboard.C)
            _useCamera = ! _useCamera;
    }
}
}
