/**
 * User: booster
 * Date: 11/12/14
 * Time: 13:53
 */
package stork.game.camera {
import stork.camera.CameraNode;
import stork.game.GameActionNode;

public class CameraValidationActionNode extends GameActionNode {
    private var _camera:CameraNode;

    public function CameraValidationActionNode(camera:CameraNode, name:String = "CameraValidationAction") {
        if(camera != null)  super(camera.validationActionPriority, name);
        else                throw new ArgumentError("'camera' cannot be null");

        _camera = camera;
    }

    override protected function actionUpdated(dt:Number):void {
        _camera.validate();
    }
}
}
