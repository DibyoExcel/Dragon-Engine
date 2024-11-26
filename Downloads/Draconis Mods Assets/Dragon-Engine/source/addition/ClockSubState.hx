package addition;

import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSprite;

class ClockSubState extends FlxState {
    private var clockFace:FlxSprite;
    private var hourHand:FlxSprite;
    private var minuteHand:FlxSprite;
    private var secondHand:FlxSprite;
    private var centerX:Float;
    private var centerY:Float;

    override public function create():Void {
        super.create();
        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image((ClientPrefs.darkmode ? 'menuDesatDark' : 'menuDesat')));
		bg.color = 0xffffff;
		bg.screenCenter();
		//bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

        centerX = FlxG.width / 2;
        centerY = FlxG.height / 2;

        // Create clock face
        clockFace = new FlxSprite(centerX - 100, centerY - 100).makeGraphic(200, 200, (ClientPrefs.darkmode ? 0xffffffff : 0xff000000));
        add(clockFace);

        // Create hour hand
        hourHand = new FlxSprite(centerX - 5, centerY - 40).makeGraphic(10, 40, 0xFFFF00FF);
        hourHand.origin.set(5, 40); // Set origin to bottom center
        add(hourHand);

        // Create minute hand
        minuteHand = new FlxSprite(centerX - 3, centerY - 60).makeGraphic(6, 60, 0xFF00FF00);
        minuteHand.origin.set(3, 60); // Set origin to bottom center
        add(minuteHand);

        // Create second hand
        secondHand = new FlxSprite(centerX - 2, centerY - 80).makeGraphic(4, 80, 0xFFFF0000);
        secondHand.origin.set(2, 80); // Set origin to bottom center
        add(secondHand);
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        if (FlxG.keys.justPressed.ESCAPE) {
            FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(new MainMenuState());
        }

        var date = Date.now();
        var seconds = date.getSeconds();
        var minutes = date.getMinutes();
        var hours = date.getHours();

        // Rotate hands
        hourHand.angle = (hours % 12) * 30 + (minutes / 2);
        minuteHand.angle = minutes * 6 + (seconds / 10);
        secondHand.angle = seconds * 6;
    }
}
