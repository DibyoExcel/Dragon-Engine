package;

import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.FlxSubState;
import flixel.FlxSprite;
import flixel.FlxCamera;

class CustomFadeTransition extends MusicBeatSubstate {
	public static var finishCallback:Void->Void;
	private var leTween:FlxTween = null;
	public static var nextCamera:FlxCamera;
	var isTransIn:Bool = false;
	var transBlack:FlxSprite;
	var transGradient:FlxSprite;
	public static var useGraphics:Bool = false;
	//transition idea inspired codename engine
	//bruh so ugly compile condition due html5
	#if !NO_PRELOAD_ALL
	public static var splashLoad1:FlxSprite;
	public static var splashLoad2:FlxSprite;
	#end
	private var transitionCamera:FlxCamera;

	public function new(duration:Float, isTransIn:Bool, grp:Bool = false) {
		super();

		this.isTransIn = isTransIn;
		var zoom:Float = CoolUtil.boundTo(FlxG.camera.zoom, 0.05, 1);
		var width:Int = Std.int(FlxG.width / zoom);
		var height:Int = Std.int(FlxG.height / zoom);
		#if !NO_PRELOAD_ALL if (!grp && !useGraphics) {#end
			transGradient = FlxGradient.createGradientFlxSprite(width, height, (isTransIn ? [0x0, FlxColor.BLACK] : [FlxColor.BLACK, 0x0]));
			transGradient.scrollFactor.set();
			add(transGradient);
	
			transBlack = new FlxSprite().makeGraphic(width, height + 400, FlxColor.BLACK);
			transBlack.scrollFactor.set();
			add(transBlack);
	
			transGradient.x -= (width - FlxG.width) / 2;
			transBlack.x = transGradient.x;
			#if !NO_PRELOAD_ALL } else {
			splashLoad1 = new FlxSprite(0, 0).loadGraphic(Paths.image('ui/splashLoad_1'));
			splashLoad2 = new FlxSprite(0, 0).loadGraphic(Paths.image('ui/splashLoad_2'));
			splashLoad1.antialiasing = ClientPrefs.globalAntialiasing;
			splashLoad2.antialiasing = ClientPrefs.globalAntialiasing;
			add(splashLoad2);
			add(splashLoad1);//because ...
			//warnign change resolution beyond 16 is gonna make the loading screen look really bad
			var scale = splashLoad1.height / FlxG.height;
			var scale2 = splashLoad2.height / FlxG.height;
			splashLoad1.setGraphicSize(Std.int(splashLoad1.width / scale), Std.int(splashLoad1.height / scale));
			splashLoad2.setGraphicSize(Std.int(splashLoad2.width / scale2), Std.int(splashLoad2.height / scale2));
			splashLoad1.updateHitbox();
			splashLoad2.updateHitbox();
			var scale = FlxG.width/1280;//well this original mean for 1280
			splashLoad1.scale.set(scale, scale);
			splashLoad2.scale.set(scale, scale);
			splashLoad1.updateHitbox();
			splashLoad2.updateHitbox();
			splashLoad1.screenCenter(Y);
			splashLoad2.screenCenter(Y);
		}#end

		if(isTransIn) {
			#if !NO_PRELOAD_ALL if (!grp) {#end
				transGradient.y = transBlack.y - transBlack.height;
				FlxTween.tween(transGradient, {y: transGradient.height + 50}, duration, {
					onComplete: function(twn:FlxTween) {
						close();
					},
				ease: FlxEase.linear});
				#if !NO_PRELOAD_ALL } else {
				splashLoad1.x = 0;
				splashLoad2.x = FlxG.width - splashLoad2.width;
				FlxTween.tween(splashLoad1, {x: -splashLoad1.width}, duration, { ease: FlxEase.circInOut });
				FlxTween.tween(splashLoad2, {x: FlxG.width}, duration, {
					onComplete: function(twn:FlxTween) {
						close();
					}, 
				ease: FlxEase.circInOut });
			}#end
		} else {
			useGraphics = grp;
			#if !NO_PRELOAD_ALL if (!grp) { #end
				transGradient.y = -transGradient.height;
				transBlack.y = transGradient.y - transBlack.height + 50;
				leTween = FlxTween.tween(transGradient, {y: transGradient.height + 50}, duration, {
					onComplete: function(twn:FlxTween) {
						if(finishCallback != null) {
							finishCallback();
						}
					},
				ease: FlxEase.linear});
				#if !NO_PRELOAD_ALL } else {
				splashLoad1.x = -splashLoad1.width;
				splashLoad2.x = FlxG.width;
				FlxTween.tween(splashLoad1, {x: 0}, duration, { ease: FlxEase.circInOut });
				FlxTween.tween(splashLoad2, {x: FlxG.width - splashLoad2.width}, duration, {
					onComplete: function(twn:FlxTween) {
						if(finishCallback != null) {
							finishCallback();
						}
					},
				ease: FlxEase.circInOut });
			}#end
		}
		transitionCamera = new FlxCamera();
		transitionCamera.bgColor.alpha =0;
		FlxG.cameras.add(transitionCamera, false);
		if(transitionCamera != null && transBlack != null && transGradient != null) {
			transBlack.cameras = [transitionCamera];
			transGradient.cameras = [transitionCamera];
		} #if !NO_PRELOAD_ALL else if (transitionCamera != null && splashLoad1 != null && splashLoad2 != null) {
			splashLoad1.cameras = [transitionCamera];
			splashLoad2.cameras = [transitionCamera];
		}#end
		nextCamera = null;
	}

	override function update(elapsed:Float) {
		if (transBlack != null && transGradient != null) {
			if(isTransIn) {
				transBlack.y = transGradient.y + transGradient.height;
			} else {
				transBlack.y = transGradient.y - transBlack.height;
			}
		}
		super.update(elapsed);
		if (transBlack != null && transGradient != null) {
			if(isTransIn) {
				transBlack.y = transGradient.y + transGradient.height;
			} else {
				transBlack.y = transGradient.y - transBlack.height;
			}
		}
	}

	override function destroy() {
		if(leTween != null) {
			finishCallback();
			leTween.cancel();
		}
		super.destroy();
	}
	override function close() {
		if (transitionCamera != null) {
			FlxG.cameras.remove(transitionCamera, true);
		}
		super.close();
	}
}