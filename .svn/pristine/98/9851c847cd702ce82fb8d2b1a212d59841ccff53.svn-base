package ;

import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.Lib;
import flash.net.URLRequest;
import haxe.Timer;
import org.xiph.frontend.BaseSound;
import org.xiph.frontend.BaseSoundChannel;
import org.xiph.frontend.SoundFactory;
import org.xiph.system.OggDecoder;
import org.xiph.system.OggUtil;

/**
 * ...
 * @author 
 */

class MainTest
{
	static var s:BaseSound;
	static var ch:BaseSoundChannel;
	
	static function main() 
	{
		var stage = Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		// entry point
    
    	var testSound:String = "../resource/interlude1.ogg"; //any ogg sound path.
    	SoundFactory.init(); //static Initialize Ogg
    	s = SoundFactory.getInstance(testSound);
    	s.addEventListener(Event.COMPLETE , compHandler );
   	}
    
    static private function compHandler(e:Event):Void 
    {
    	ch = s.play(0, 0.5, 0); //play sound.
    }
}