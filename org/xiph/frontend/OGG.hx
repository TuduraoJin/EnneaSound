package org.xiph.frontend;

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.media.SoundLoaderContext;
import flash.net.URLRequest;
import flash.net.URLStream;
import flash.utils.ByteArray;
import org.xiph.system.OggUtil;

/**
 * The "OGG" class implements OGG Vorbis playback support, through
 * the use of Flash 10's enhanced Sound API. More specifically, the
 * ability to dynamically write audio data, needed for the Vorbis
 * decoder to communicate with.
 *
 * The class was created using the existing implementation found here:
 *     https://launchpad.net/fogg
 *  
 *  Revision 58 of the FOgg repo hosted at the link above was used as a base.
 * 
 * @author tudurao jin
 */

class OGG extends BaseSound 
{
    private var _req : URLRequest;
    private var _ul : URLStream;
    private var _data : ByteArray;
	private var _playLength:Float;
	//public var slc(default,default) : SoundLoaderContext; 
	public var loop(default, default):Int = 0;
	public static var seekQuality(default, default):Bool = false; //global. It is set to seek quality of OggVorbisChannel instance created from this instance.
	public static var chunksize(default, default):Int = 8192; //global. between 2048 - 8192 (flash.media.Sound SAMPLE_DATA_EVENT )
	
    public function new(url:URLRequest , ?inSlc:SoundLoaderContext ) 
	{
        super( inSlc );
        _req = url;
		this.slc = new SoundLoaderContext();
		this._playLength = 0;
        _ul = new URLStream();
        _ul.addEventListener(Event.OPEN, onOpen);
        _ul.addEventListener(ProgressEvent.PROGRESS, onProgress);
        _ul.addEventListener(Event.COMPLETE, onComplete);
        _ul.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
        _ul.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurity);
		_ul.load(_req);
    }

    public override function play(offset:Float, volume:Float, pan:Float , ?loop:Int = 0 ) : BaseSoundChannel 
	{
		var oggch:OGGVorbisChannel = new OGGVorbisChannel(this._data, offset, volume, pan , loop, Std.int( this.slc.bufferTime) );
		oggch.seekQuality = OGG.seekQuality;
		oggch.samples_chunksize = OGG.chunksize;
		oggch.play();
		return oggch;
    }
	
	private function onOpen( e:Event ):Void
	{
        this._data = new ByteArray();
        dispatchEvent( e.clone() );
    }

    private function onProgress(e:ProgressEvent):Void
	{
		dispatchEvent( e );
    }
	
    private function onComplete(e:Event):Void
	{
		_ul.removeEventListener(Event.OPEN, onOpen);
        _ul.removeEventListener(ProgressEvent.PROGRESS, onProgress);
        _ul.removeEventListener(Event.COMPLETE, onComplete);
        _ul.removeEventListener(IOErrorEvent.IO_ERROR, onIoError);
        _ul.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurity);
		
		this._ul.readBytes( this._data );
		//playlength
		this._playLength = OggUtil.getOggPlayLength( this._data );
		trace("[OGG] <onComplete> playLength=" + Std.string(this._playLength));
		
		//id3
		this.baseID3 = OggUtil.getOggID3( this._data );
		trace("[OGG] <onComplete> id3=" + this.baseID3.toString() );
		
        dispatchEvent( e.clone() );
    }

    private function onIoError(e:IOErrorEvent):Void
	{
		dispatchEvent( e.clone() );
	}
	
	private function onSecurity(e:SecurityErrorEvent):Void 
	{
		dispatchEvent( e.clone() );
	}
	
	override public function getURL():String  	{		return _req.url;	}
	override public function getLength():Float {       return this._playLength;    }
}