/**
 * User: booster
 * Date: 09/12/14
 * Time: 18:06
 */
package stork.camera.policy {
import flash.geom.Matrix;

import stork.camera.CameraNode;
import stork.camera.CameraProjectionNode;

import stork.camera.CameraSpaceNode;

/** Fits projection's viewport with camera's viewport not changing it's aspect ratio. */
public class AspectFillPolicy implements IProjectionPolicy {
    private var _alignment:Number = 0.5;

    /** How the camera's viewort is aligned; when 0 it's at the left/top edge, when 1 it's at the right/bottom one. @default 0.5 */
    public function get alignment():Number { return _alignment; }
    public function set alignment(value:Number):void { _alignment = value; }

    public function updateTransform(matrix:Matrix, space:CameraSpaceNode, camera:CameraNode, projection:CameraProjectionNode):void {
        var cax:Number = camera.anchor.x;
        var cay:Number = camera.anchor.y;
        var cvw:Number = camera.viewport.width;
        var cvh:Number = camera.viewport.height;
        var rx:Number = camera.viewport.x; // rotation's center x
        var ry:Number = camera.viewport.y; // rotation's center y
        var csx:Number = camera.scale.x;
        var csy:Number = camera.scale.y;
        var pvw:Number = projection.viewportWidth;
        var pvh:Number = projection.viewportHeight;

        var cvr:Number = cvw / cvh;
        var pvr:Number = pvw / pvh;

        var scale:Number = cvr < pvr
                ? cvw / pvw // camera's viewport is proportionally taller than projection's viewport
                : cvh / pvh // camera's viewport is proportionally wider than projection's viewport
            ;

        var scvw:Number = cvw * csx;
        var scvh:Number = cvh * csy;
        var scvx:Number = rx - cax * cvw * csx;
        var scvy:Number = ry - cay * cvh * csy;
        var spvw:Number = scale * pvw * csx;
        var spvh:Number = scale * pvh * csy;
        var spvx:Number = scvx + (scvw - spvw) * _alignment;
        var spvy:Number = scvy + (scvh - spvh) * _alignment;

        var cr:Number = camera.rotation;

        matrix.identity();
        matrix.translate(-rx, -ry);
        matrix.rotate(-cr);
        matrix.translate(rx - spvx, ry - spvy);
        matrix.scale(1 / scale / csx, 1 / scale / csy);
    }
}
}
