/**
 * User: booster
 * Date: 06/12/14
 * Time: 14:40
 */
package stork.camera {

import flash.geom.Matrix;

import stork.camera.policy.IProjectionPolicy;

import stork.core.Node;

public class CameraProjectionNode extends Node {
    private var _policy:IProjectionPolicy;

    private var _viewportWidth:Number;
    private var _viewportHeight:Number;

    private var _transformationMatrix:Matrix = new Matrix();

    public function CameraProjectionNode(policy:IProjectionPolicy, viewportWidth:Number, viewportHeight:Number, name:String = "CameraProjection") {
        super(name);

        _policy = policy;
        _viewportWidth = viewportWidth;
        _viewportHeight = viewportHeight;
    }

    public function get policy():IProjectionPolicy { return _policy; }

    public function get viewportWidth():Number { return _viewportWidth; }
    public function set viewportWidth(value:Number):void { _viewportWidth = value; }

    public function get viewportHeight():Number { return _viewportHeight; }
    public function set viewportHeight(value:Number):void { _viewportHeight = value; }

    public function get transformationMatrix():Matrix { return _transformationMatrix; }

    public function get camera():CameraNode { return parentNode as CameraNode; }

    public function update():void {
        _policy.updateTransform(_transformationMatrix, camera.space, camera, this);
    }
}
}
