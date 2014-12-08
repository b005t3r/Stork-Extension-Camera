/**
 * User: booster
 * Date: 06/12/14
 * Time: 17:38
 */
package stork.camera.policy {
import flash.geom.Matrix;

import stork.camera.CameraNode;
import stork.camera.CameraProjectionNode;

import stork.camera.CameraSpaceNode;

public class AspectFitPolicy implements IProjectionPolicy {
    private var _layout:Number = 0.0;

    public function get layout():Number { return _layout; }
    public function set layout(value:Number):void { _layout = value; }

    public function updateTransform(matrix:Matrix, space:CameraSpaceNode, camera:CameraNode, projection:CameraProjectionNode):void {
        var cvx:Number = camera.viewport.x;
        var cvy:Number = camera.viewport.y;
        var cax:Number = camera.anchor.x;
        var cay:Number = camera.anchor.y;
        var csx:Number = camera.scale.x;
        var csy:Number = camera.scale.y;
        var cvw:Number = camera.viewport.width;
        var cvh:Number = camera.viewport.height;
        var pvw:Number = projection.viewportWidth;
        var pvh:Number = projection.viewportHeight;

        var cvr:Number = cvw / cvh;
        var pvr:Number = pvw / pvh;

        var scale:Number = cvr > pvr
            ? cvw / pvw // camera's viewport is proportionally wider than projection's viewport
            : cvh / pvh // camera's viewport is proportionally taller than projection's viewport
        ;

        var spvw:Number = scale * pvw;
        var spvh:Number = scale * pvh;
        //var spvx:Number = cvx + ((cvw - spvw) + (spvw - spvw * csx) * cax) / 2;
        //var spvy:Number = cvy + ((cvh - spvh) + (spvh - spvh * csy) * cay) / 2;
        var spvx:Number = cvx + (cvw + spvw * (cax * (1 - csx) - 1)) * 0.5;
        var spvy:Number = cvy + (cvh + spvh * (cay * (1 - csy) - 1)) * 0.5;

        var cx:Number = (spvx + spvw * csx / 2);
        var cy:Number = (spvy + spvh * csy / 2);
        var rx:Number = cvx + cvw * cax; // rotation's center x
        var ry:Number = cvy + cvh * cay; // rotation's center y
        var dx:Number = rx - cx;
        var dy:Number = ry - cy;
        var d:Number = Math.sqrt(dx * dx + dy * dy);
        var a:Number = Math.atan2(dx, -dy) + 2 * Math.PI;
        var drx:Number = cx + Math.sin(a + camera.rotation) * d;
        var dry:Number = cy - Math.cos(a + camera.rotation) * d;

        matrix.identity();
        matrix.translate(-rx, -ry);
        matrix.rotate(camera.rotation);
        matrix.translate(drx - spvx, dry - spvy);
        matrix.scale(1 / scale / csx, 1 / scale / csy);
    }
}
}
