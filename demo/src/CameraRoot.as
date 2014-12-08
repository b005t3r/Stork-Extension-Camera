/**
 * User: booster
 * Date: 07/12/14
 * Time: 16:42
 */
package {
import starling.display.Quad;
import starling.display.Sprite;
import starling.display.StorkRoot;
import starling.utils.Color;

public class CameraRoot extends StorkRoot {
    public static const colors:Array = [Color.AQUA, Color.FUCHSIA, Color.BLUE, Color.GRAY, Color.GREEN, Color.MAROON, Color.NAVY];

    public function CameraRoot() {
        var container:Sprite = new Sprite();

        for(var i:int = 0; i < 30; ++i) {
            for(var j:int = 0; j < 30; ++j) {
                var x:Number = i * 20 + 5;
                var y:Number = j * 20 + 5;
                var ci:int = Math.random() * colors.length;

                container.addChild(createQuad(x, y, colors[ci]));
            }
        }

        addChild(container);
        container.flatten(true);
    }

    private function createQuad(x:Number, y:Number, color:uint):Quad {
        var q:Quad = new Quad(10, 10, color);
        q.alignPivot();
        q.x = x;
        q.y = y;

        return q;
    }
}
}
