package substate;

import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class WheelSubState extends FlxSubState {

    var wheel:FlxSprite = new FlxSprite(0,0,AssetPaths.wheel_of_fortune__png);
    var screen:FlxSprite = new FlxSprite(0,0,AssetPaths.wheelscreen__png);
    var point:FlxSprite = new FlxSprite(0,0,AssetPaths.pointer__png);
    override function create() {
        super.create();
        wheel.scale.set(7.5,7.5);
        wheel.updateHitbox();
        wheel.screenCenter(Y);
        wheel.x -= 128*7.5;
        add(wheel);
        screen.screenCenter();
        screen.x += 128*3;
        add(screen);
        point.screenCenter();
        add(point);
    }
    var portion = 0;
    var nextAngleSwitch = 45;

    override function destroy() {
        FlxTween.cancelTweensOf(point);
        super.destroy();
    }
    override function update(elapsed:Float) {
        Main.detectConnections();
        wheel.angle += elapsed*64;
        if (wheel.angle >= nextAngleSwitch) {
            portion = nextAngleSwitch;
            nextAngleSwitch += 45;
            FlxTween.tween(point, {angle: -11}, 0.05, {ease: FlxEase.sineIn,onComplete: (t)->{
                FlxTween.tween(point, {angle: 0}, 0.25, {ease: FlxEase.sineOut});
            }});
        }
        for (source in Main.activeInputs)
        {
            if (source.ui_deny)
                close();
        }
        super.update(elapsed);
    }
}

