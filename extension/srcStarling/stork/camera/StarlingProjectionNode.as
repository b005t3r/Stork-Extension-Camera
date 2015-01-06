/**
 * User: booster
 * Date: 11/12/14
 * Time: 13:14
 */
package stork.camera {

import starling.display.DisplayObject;

import stork.camera.policy.IProjectionPolicy;

public class StarlingProjectionNode extends CameraProjectionNode {
    private var _display:DisplayObject;

    public function StarlingProjectionNode(display:DisplayObject, policy:IProjectionPolicy, viewportWidth:Number, viewportHeight:Number, actionPriority:int = int.MAX_VALUE, name:String = "CameraProjection") {
        if(display != null) super(policy, viewportWidth, viewportHeight, actionPriority, name);
        else                throw new ArgumentError("'display' cannot be null");

        _display = display;
    }

    override public function set active(value:Boolean):void {
        super.active = value;

        // assign identity transform
        if(! value)
            _display.transformationMatrix = transformationMatrix;
    }

    public function get display():DisplayObject { return _display; }

    override public function update():void {
        super.update();

        if(! active)
            return;

        _display.transformationMatrix = transformationMatrix;
    }
}
}
