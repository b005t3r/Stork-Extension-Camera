/**
 * User: booster
 * Date: 12/12/14
 * Time: 14:57
 */
package stork.camera.assistant.panning {
import medkit.geom.shapes.Point2D;

public interface IPanningTarget {
    function getLocation(result:Point2D = null):Point2D
}
}
