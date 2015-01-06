/**
 * User: booster
 * Date: 11/12/14
 * Time: 16:34
 */
package stork.camera {
import flash.display.DisplayObject;

import stork.camera.policy.IProjectionPolicy;

public class FlashProjectionNode extends CameraProjectionNode {
    private var _display:DisplayObject;

    public function FlashProjectionNode(display:DisplayObject, policy:IProjectionPolicy, viewportWidth:Number, viewportHeight:Number, actionPriority:int = int.MAX_VALUE, name:String = "CameraProjection") {
        if(display != null) super(policy, viewportWidth, viewportHeight, actionPriority, name);
        else                throw new ArgumentError("'display' cannot be null");

        _display = display;
    }

    override public function set active(value:Boolean):void {
        super.active = value;

        // assign identity transform
        if(! value)
            _display.transform.matrix = transformationMatrix;
    }

    public function get display():DisplayObject { return _display; }

    override public function update():void {
        super.update();

        if(! active)
            return;

        _display.transform.matrix = transformationMatrix;
    }
}
}
