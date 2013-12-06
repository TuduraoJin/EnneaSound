package org.xiph.frontend;

import flash.events.Event;
import flash.media.SoundLoaderContext;
import flash.utils.ByteArray;
import haxe.Timer;
import org.xiph.system.OggUtil;

/**
 * バイナリからOGGChannelを生成するクラスです...
 * @author Tudurao Jin
 */
class BinaryOGG extends BaseSound
{
	private var _data : ByteArray;
	private var _playLength:Float;
	public var loop:Int = 0;
	
	public function new( ?inSlc:SoundLoaderContext ):Void
	{
		super(inSlc);
	}
	
	/**
	 * set Binary. バイナリをセットする。
	 * チャンネル作成準備が完了したらEvent.COMPLETEイベントを発行する。
	 * @param	inByte OGGVorbis file binary.
	 * @eventType Event.COMPLETE setup complete.
	 */
	public function setBinary( inByte:ByteArray ) 
	{
		this._data = inByte;
		
		//playlength
		this._playLength = OggUtil.getOggPlayLength( this._data );
		trace("[BinaryOGG] <new> playLength=" + Std.string(this._playLength));
		
		//id3
		this._baseID3 = OggUtil.getOggID3( this._data );
		trace("[BinaryOGG] <new> id3=" + this._baseID3.toString() );
		
		// deley dispatch COMPLETE EVENT 
		Timer.delay( function() {
			dispatchEvent( new Event(Event.COMPLETE) );
			}
			, 0 );
	}
	
	/**
	 * create Channel , And play sound.. チャンネルを生成して音楽を再生します。
	 * @param	offset
	 * @param	volume
	 * @param	pan
	 * @param	loop
	 * @return
	 */
	override public function play(offset:Float, volume:Float, pan:Float , loop:Int = 0 ) : BaseSoundChannel 
	{
		if ( _data != null ) {
			var oggch:OGGVorbisChannel = new OGGVorbisChannel(this._data, offset, volume, pan , loop, Std.int( this.slc.bufferTime) );
			oggch.seekQuality = OGG.seekQuality;
			oggch.samples_chunksize = OGG.chunksize;
			oggch.play();
			return oggch;
		}
		return null;
    }
	
	override public function getURL():String  	{		return "";	}
	override public function getLength():Float {       return this._playLength;    }
}