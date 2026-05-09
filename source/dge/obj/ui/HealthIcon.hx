package dge.obj.ui;
//is only ui purpose not for gameplay
import HealthIcon as BaseHealthIcon;

class HealthIcon extends BaseHealthIcon
{
    public function new(char:String = 'bf', ?state:String = 'netral')
    {
        super(char, false);
        if (state == null) state = 'netral';
        if (spriteSheet) {
            if (state == 'netral') {
                animation.play('netral');
            } else if (state == 'lose') {
                animation.play('lose');
            } else if (state == 'win') {
                animation.play('win');
            }
        } else {
            if (animation != null && animation.curAnim != null) {
                if (state == 'netral') {
                    animation.curAnim.curFrame = 0;
                } else if (state == 'lose') {
                    animation.curAnim.curFrame = 1;
                } else if (state == 'win') {
                    animation.curAnim.curFrame = 2;
                }
            }
        }
    }

    public function changeIconState(char:String, ?state:String = 'netral')
    {
        super.changeIcon(char);
        if (state == null) state = 'netral';
        if (spriteSheet) {
            if (state == 'netral') {
                animation.play('netral');
            } else if (state == 'lose') {
                animation.play('lose');
            } else if (state == 'win') {
                animation.play('win');
            }
        } else {
            if (animation != null && animation.curAnim != null) {
                if (state == 'netral') {
                    animation.curAnim.curFrame = 0;
                } else if (state == 'lose') {
                    animation.curAnim.curFrame = 1;
                } else if (state == 'win') {
                    animation.curAnim.curFrame = 2;
                }
            }
        }
    }
}