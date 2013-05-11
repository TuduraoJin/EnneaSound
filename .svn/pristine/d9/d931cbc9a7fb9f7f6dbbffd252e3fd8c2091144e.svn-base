package org.xiph.frontend;

import flash.events.EventDispatcher;
import flash.media.SoundTransform;

/**
 * A base class of other classes soundChannel...
 * 
 * @author tudurao jin
 */

class BaseSoundChannel extends EventDispatcher 
{
	private var _st:SoundTransform;
	private var _offset:Float = 0;
	public var loop(default, default):Int = 0;
	public var isPlayed(default,null):Bool;
	
	public function new():Void {		super();	}
	public function dispose():Void{		this._st = null;	}
	public function play( ?inOffset:Float , ?inVol:Float , ?inPan:Float ,?inLoop:Int ):Void
	{
		if ( inOffset != null ) {	this._offset = inOffset;	}
		if ( inVol != null && this._st != null  ) {	this._st.volume = inVol;	}
		if ( inPan != null && this._st != null ) {	this._st.pan = inPan;	}
		if ( inLoop != null ) {	this.loop = inLoop;	}
		return;
	}
    public function stop() : Void {}
    public function getPosition() : Float {		return -1;	}
    public function getVolume() : Float {	return -1;	}
    public function getPan() : Float {	return -1;	}
    public function setVolume(volume : Float) : Void {	}
    public function setPan(pan : Float) : Void { }
}