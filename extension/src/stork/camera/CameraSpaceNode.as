/**
 * User: booster
 * Date: 06/12/14
 * Time: 14:08
 */
package stork.camera {

import stork.core.ContainerNode;

public class CameraSpaceNode extends ContainerNode {
    private var _minX:Number;
    private var _maxX:Number;
    private var _minY:Number;
    private var _maxY:Number;

    public function CameraSpaceNode(minX:Number = -Infinity, maxX:Number = Infinity, minY:Number = -Infinity, maxY:Number = Infinity, name:String = "CameraSpace") {
        super(name);

        if(minX >= maxX || minY >= maxY) throw new ArgumentError("minX must be less than maxX and minY must be less than maxY");

        _minX = minX;
        _maxX = maxX;
        _minY = minY;
        _maxY = maxY;
    }

    public function get minX():Number { return _minX; }
    public function set minX(value:Number):void { _minX = value; }

    public function get maxX():Number { return _maxX; }
    public function set maxX(value:Number):void { _maxX = value; }

    public function get minY():Number { return _minY; }
    public function set minY(value:Number):void { _minY = value; }

    public function get maxY():Number { return _maxY; }
    public function set maxY(value:Number):void { _maxY = value; }
}
}
