/**
 * User: booster
 * Date: 11/12/14
 * Time: 9:34
 */
package stork.game.camera {

import stork.camera.CameraProjectionNode;
import stork.game.GameActionNode;

public class CameraProjectionUpdateActionNode extends GameActionNode {
    private var _projection:CameraProjectionNode;

    public function CameraProjectionUpdateActionNode(projection:CameraProjectionNode, name:String = "CameraProjectionUpdateAction") {
        if(projection != null)  super(projection.updateActionPriority, name);
        else                    throw new ArgumentError("'projection' cannot be null");

        _projection = projection;
    }

    override protected function actionUpdated(dt:Number):void {
        _projection.update();
    }
}
}
