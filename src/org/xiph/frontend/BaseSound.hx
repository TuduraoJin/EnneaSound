package org.xiph.frontend;

import flash.events.EventDispatcher;
import flash.media.SoundLoaderContext;
import org.xiph.system.BaseID3Info;

/**
 * A base class of other sound classes...
 * 
 * @author tudurao jin
 */

class BaseSound extends EventDispatcher
{
	public var baseID3(default,null):BaseID3Info;
	public var slc(default,default) : SoundLoaderContext; //use OggDecoder buffer size in OggVorbisChannel.
	
	public function new( ?inSlc:SoundLoaderContext ):Void
	{
		super();
		this.baseID3 = new BaseID3Info();
		if ( inSlc == null ) {	this.slc = new SoundLoaderContext();	}
	}
	
    public function play(offset:Float, volume:Float, pan:Float , ?loop:Int = 0) : BaseSoundChannel {        return null;    }
	public function getURL():String {		return "";	}
    public function getLength() : Float {        return 0;    }
	public function getID3():BaseID3Info {	return baseID3;	}
	public function getClassName():String { return Type.getClassName( Type.getClass( this ));	}
}
