/**
 * User: booster
 * Date: 06/12/14
 * Time: 14:18
 */
package stork.camera {

import flash.geom.Matrix;

import medkit.geom.GeomUtil;

import medkit.geom.shapes.Point2D;
import medkit.geom.shapes.Rectangle2D;

import stork.core.ContainerNode;
import stork.game.camera.CameraValidationActionNode;

public class CameraNode extends ContainerNode {
    private static var _helperRect:Rectangle2D  = new Rectangle2D();
    private static var _helperPointA:Point2D    = new Point2D();
    private static var _helperPointB:Point2D    = new Point2D();

    private var _viewport:Rectangle2D           = new Rectangle2D();
    private var _anchor:Point2D                 = new Point2D(0.5, 0.5);
    private var _scale:Point2D                  = new Point2D(1, 1);
    private var _rotation:Number                = 0;

    private var _transformationMatrix:Matrix    = new Matrix();

    private var _validateActionPriority:int;
    private var _validateAction:CameraValidationActionNode;

    public function CameraNode(x:Number, y:Number, width:Number, height:Number, validateActionPriority:int = int.MAX_VALUE, name:String = "Camera") {
        super(name);

        _viewport.setTo(x, y, width, height);

        _validateActionPriority = validateActionPriority;
        _validateAction = new CameraValidationActionNode(this, name + "ValidationAction");
    }

    /** Camera viewport's in parent space. */
    public function get viewport():Rectangle2D { return _viewport; }

    /** Camera viewport's anchor in percents (0 is the left edge, 1 is the right edge, etc.). @default (0.5; 0.5) */
    public function get anchor():Point2D { return _anchor; }

    /** Camera viewport's scale factor (1 for 1:1 mapping from local to parent). @default 1 */
    public function get scale():Point2D { return _scale; }

    /** Camera viewport's rotation around its anchor point, in radians, clockwise, 0 is up. @default 0 */
    public function get rotation():Number { return _rotation; }
    public function set rotation(value:Number):void { _rotation = value; }

    public function get validateActionPriority():int { return _validateActionPriority; }
    public function get validateAction():CameraValidationActionNode { return _validateAction; }

    public function get space():CameraSpaceNode { return parentNode as CameraSpaceNode; }

    /** Camera viewport's bounds  */
    public function getBounds(bounds:Rectangle2D = null):Rectangle2D {
        if(bounds == null) bounds = new Rectangle2D();

        var pivotX:Number = _anchor.x * _viewport.width;
        var pivotY:Number = _anchor.y * _viewport.height;

        if(_rotation == 0.0) {
            _transformationMatrix.setTo(_scale.x, 0.0, 0.0, _scale.y, _viewport.x - pivotX * _scale.x, _viewport.y - pivotY * _scale.y);
        }
        else {
            var cos:Number = Math.cos(_rotation);
            var sin:Number = Math.sin(_rotation);
            var a:Number = _scale.x * cos;
            var b:Number = _scale.x * sin;
            var c:Number = _scale.y * -sin;
            var d:Number = _scale.y * cos;
            var tx:Number = _viewport.x - pivotX * a - pivotY * c;
            var ty:Number = _viewport.y - pivotX * b - pivotY * d;

            _transformationMatrix.setTo(a, b, c, d, tx, ty);
        }

        _helperPointA.setTo(0, 0);
        _helperPointB.setTo(_viewport.width, _viewport.height);

        GeomUtil.transformPoint2D(_transformationMatrix, _helperPointA.x, _helperPointA.y, _helperPointA);
        GeomUtil.transformPoint2D(_transformationMatrix, _helperPointB.x, _helperPointB.y, _helperPointB);

        if(_helperPointA.x > _helperPointB.x) {
            bounds.x        = _helperPointB.x;
            bounds.width    = _helperPointA.x - _helperPointB.x;
        }
        else {
            bounds.x        = _helperPointA.x;
            bounds.width    = _helperPointB.x - _helperPointA.x;
        }

        if(_helperPointA.y > _helperPointB.y) {
            bounds.y        = _helperPointB.y;
            bounds.height   = _helperPointA.y - _helperPointB.y;
        }
        else {
            bounds.y        = _helperPointA.y;
            bounds.height   = _helperPointB.y - _helperPointA.y;
        }

        return bounds;
    }

    /**
     * Needs to be called after changing camera's properties to e.g. ensure camera's viewport is still in space's bounds.
     * Camera has to be added to parent, otherwise error is thrown.
     */
    public function validate():void {
        var s:CameraSpaceNode = space;

        if(s == null) throw new UninitializedError("camera not added to space");

        var spaceMinX:Number = s.minX;
        var spaceMaxX:Number = s.maxX;
        var spaceMinY:Number = s.minY;
        var spaceMaxY:Number = s.maxY;

        var bounds:Rectangle2D = null;

        var cameraOffsetX:Number = NaN;
        var cameraOffsetY:Number = NaN;

        var offset:Number;

        // ! isNaN
        if(spaceMinX == spaceMinX) {
            if(bounds == null)
                bounds = getBounds(_helperRect);

            offset = spaceMinX - bounds.x;

            if(offset > 0)
                cameraOffsetX = offset;
        }

        // ! isNaN
        if(spaceMaxX == spaceMaxX) {
            if(bounds == null)
                bounds = getBounds(_helperRect);

            offset = spaceMaxX - (bounds.x + bounds.width);

            if(offset < 0) {
                // isNaN
                if(cameraOffsetX != cameraOffsetX)
                    cameraOffsetX = offset;
                else
                    throw new Error("camera does not fit into the space");
            }
        }

        // ! isNaN
        if(spaceMinY == spaceMinY) {
            if(bounds == null)
                bounds = getBounds(_helperRect);

            offset = spaceMinY - bounds.y;

            if(offset > 0)
                cameraOffsetY = offset;
        }

        // ! isNaN
        if(spaceMaxY == spaceMaxY) {
            if(bounds == null)
                bounds = getBounds(_helperRect);

            offset = spaceMaxY - (bounds.y + bounds.height);

            if(offset < 0) {
                // isNaN
                if(cameraOffsetY != cameraOffsetY)
                    cameraOffsetY = offset;
                else
                    throw new Error("camera does not fit into the space");
            }
        }

        // ! isNaN
        if(cameraOffsetX == cameraOffsetX)
            _viewport.x += cameraOffsetX;

        // ! isNaN
        if(cameraOffsetY == cameraOffsetY)
            _viewport.y += cameraOffsetY;
    }
}
}
