/**
 * User: booster
 * Date: 12/12/14
 * Time: 15:25
 */
package stork.game.camera.panning {
import medkit.geom.shapes.Point2D;

import stork.camera.assistant.panning.PanningAssistantNode;
import stork.game.GameActionNode;

public class FollowTargetActionNode extends GameActionNode {
    private static var _camPosition:Point2D = new Point2D();

    private var _assistant:PanningAssistantNode;

    public function FollowTargetActionNode(assistant:PanningAssistantNode, name:String = "FollowTargetAction") {
        if(assistant != null)   super(assistant.followTargetActionPriority, name);
        else                    throw new ArgumentError("'assistant' cannot be null");

        _assistant = assistant;
    }

    override protected function actionUpdated(dt:Number):void {
        var position:Point2D = _assistant.target.getLocation(_camPosition);

        if(position == null)
            return;

        var followSpeedX:Number = _assistant.followSpeed.x * dt;
        var followSpeedY:Number = _assistant.followSpeed.y * dt;

        var x:Number = (position.x * followSpeedX) + _assistant.camera.viewport.x * (1 - followSpeedX);
        var y:Number = (position.y * followSpeedY) + _assistant.camera.viewport.y * (1 - followSpeedY);

        _assistant.camera.viewport.x = x;
        _assistant.camera.viewport.y = y;
    }
}
}
