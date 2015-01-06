/**
 * User: booster
 * Date: 12/12/14
 * Time: 15:07
 */
package stork.camera.assistant.panning {
import medkit.geom.shapes.Point2D;

public class DelegatePanningTarget implements IPanningTarget {
    private var _getLocationFunction:Function; // function(p:Point2D):void

    public function DelegatePanningTarget(getLocationFunction:Function) {
        _getLocationFunction = getLocationFunction;
    }

    public function getLocation(result:Point2D = null):Point2D {
        if(result == null) result = new Point2D();

        _getLocationFunction(result);

        return result;
    }
}
}
