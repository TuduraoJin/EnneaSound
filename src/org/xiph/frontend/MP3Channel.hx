package org.xiph.frontend;

import flash.events.Event;
import flash.media.SoundTransform;

/**
 * @author tudurao jin
 */

class MP3Channel extends BaseSoundChannel 
{
    private var _sch:flash.media.SoundChannel;
    private var _s:flash.media.Sound;
	
    public function new(sound : flash.media.Sound, offset:Float, volume:Float, pan:Float , ?loop:Int = 0) 
	{
        super();
		this._st = new SoundTransform(volume, pan);
		this._offset = offset;
		this.loop = loop;
        this._sch = sound.play(offset, loop, this._st );
        this._sch.addEventListener(Event.SOUND_COMPLETE, channelComplete);
		this._s = sound;
		this.isPlayed = true;
    }
	
	public override function dispose():Void 
	{
		super.dispose();
		this._sch = null;
		this._s = null;
		this.isPlayed = false;
	}
	
	public override function play(?inOffset:Float, ?inVol:Float, ?inPan:Float, ?inLoop:Int):Void 
	{
		super.play( inOffset, inVol, inPan, inLoop);
		if ( _sch != null )
		{
			this.stop();
		}
        this._sch = _s.play( this._offset, this.loop, this._st );
		if ( this._sch != null )
        {
			this._sch.addEventListener(Event.SOUND_COMPLETE, channelComplete);
		}
	}
    
    public override function stop() : Void 
	{
        this._sch.removeEventListener(Event.SOUND_COMPLETE, channelComplete);
        this._sch.stop();
		this._sch = null;
		this.isPlayed = false;
    }

    public override function getPosition() : Float 
	{
        return this._sch.position;
    }
    
    public override function getVolume() : Float 
	{
        return this._sch.soundTransform.volume;
    }
    
    public override function getPan() : Float 
	{
        return this._sch.soundTransform.pan;
    }
    
    public override function setVolume(volume : Float) : Void 
	{
        var t : SoundTransform = this._sch.soundTransform;
        t.volume = volume;
        this._sch.soundTransform = t;
    }
    
    public override function setPan(pan : Float) : Void 
	{
        var t : SoundTransform = this._sch.soundTransform;
        t.pan = pan;
        this._sch.soundTransform = t;        
    }
    
    private function channelComplete(e:Event)
	{
        dispatchEvent( e.clone() );
    }
}
