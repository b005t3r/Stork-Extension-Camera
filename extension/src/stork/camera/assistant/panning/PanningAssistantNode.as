/**
 * User: booster
 * Date: 12/12/14
 * Time: 13:17
 */
package stork.camera.assistant.panning {
import medkit.geom.shapes.Point2D;

import stork.camera.CameraNode;
import stork.core.Node;
import stork.game.camera.panning.FollowTargetActionNode;

public class PanningAssistantNode extends Node {
    private var _target:IPanningTarget;

    private var _followTargetAction:FollowTargetActionNode;
    private var _followTargetActionPriority:int;

    private var _followSpeed:Point2D = new Point2D(1, 1);

    public function PanningAssistantNode(followTargetActionPriority:int = int.MAX_VALUE, name:String = "PanningAssistant") {
        super(name);

        _followTargetActionPriority = followTargetActionPriority;
        _followTargetAction = new FollowTargetActionNode(this, name + "FollowTargetAction");
    }

    public function get target():IPanningTarget { return _target; }
    public function set target(value:IPanningTarget):void { _target = value; }

    public function get camera():CameraNode { return parentNode as CameraNode; }

    public function get followTargetAction():FollowTargetActionNode { return _followTargetAction; }
    public function get followTargetActionPriority():int { return _followTargetActionPriority; }

    /** In percents per second - how much distance from current location to target location is panned in one second. #default (1, 1) */
    public function get followSpeed():Point2D { return _followSpeed; }
}
}
