/**
 * User: booster
 * Date: 06/12/14
 * Time: 17:17
 */
package stork.camera.policy {
import stork.camera.*;

import flash.geom.Matrix;

public interface IProjectionPolicy {
    function updateTransform(matrix:Matrix, space:CameraSpaceNode, camera:CameraNode, projection:CameraProjectionNode):void
}
}
