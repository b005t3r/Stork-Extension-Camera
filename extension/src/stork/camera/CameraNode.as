/**
 * User: booster
 * Date: 06/12/14
 * Time: 14:18
 */
package stork.camera {

import medkit.geom.GeomUtil;
import medkit.geom.shapes.Point2D;
import medkit.geom.shapes.Rectangle2D;

import stork.core.ContainerNode;

public class CameraNode extends ContainerNode {
    private var _viewport:Rectangle2D   = new Rectangle2D();
    private var _anchor:Point2D         = new Point2D(0.5, 0.5);
    private var _scale:Point2D          = new Point2D(1, 1);
    private var _rotation:Number        = 0;

    public function CameraNode(x:Number, y:Number, width:Number, height:Number, name:String = "Camera") {
        super(name);

        _viewport.setTo(x, y, width, height);
    }

    /** Camera's viewport in local space. */
    public function get viewport():Rectangle2D { return _viewport; }

    /** Camera's viewport anchor percents (0 is the left edge, 1 is the right edge, etc.). @default (0.5; 0.5) */
    public function get anchor():Point2D { return _anchor; }

    /** Camera's viewport scale factor (1 for 1:1 mapping from local to parent). @default 1 */
    public function get scale():Point2D { return _scale; }

    /** Camera's viewport rotation around its anchor point, in radians, clockwise, 0 is up, always between (-PI, PI). @default 0 */
    public function get rotation():Number { return _rotation; }
    public function set rotation(value:Number):void { _rotation = GeomUtil.normalizeLocalAngle(value); }

    public function get space():CameraSpaceNode { return parentNode as CameraSpaceNode; }

    public function getBounds(bounds:Rectangle2D = null):Rectangle2D {
        if(bounds == null) bounds = new Rectangle2D();

        // TODO: implement

        return bounds;
    }

    /** Needs to be called after changing camera's properties to e.g. ensure camera's viewport is still in space's bounds. */
    public function validate():void {
        // TODO: validate camera's viewport
    }
}
}
