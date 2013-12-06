package org.xiph.frontend;

import flash.events.Event;
import flash.media.SoundLoaderContext;
import flash.utils.ByteArray;
import ru.etcs.media.BinaryWaveSound;

/**
 * バイナリからWAVChannelを生成します。...
 * @author Tudurao Jin
 */
class BinaryWAV extends BaseSound
{
	private var wave : BinaryWaveSound;
	
	public function new( ?inSlc:SoundLoaderContext ):Void
	{
		super(inSlc);
	}
	
	/**
	 * set Binary. バイナリをセットする。
	 * チャンネル作成準備が完了したらEvent.COMPLETEイベントを発行する。
	 * @param	inByte WAV file binary.
	 * @eventType Event.COMPLETE setup complete.
	 */
	public function setBinary( inByte:ByteArray ) 
	{
		this.wave = new BinaryWaveSound();
		this.wave.setBinary(inByte);
		this.wave.addEventListener(Event.COMPLETE , onComplete );
	}
	
	private function onComplete(e:Event):Void 
	{
		this.wave.removeEventListener(Event.COMPLETE , onComplete );
		dispatchEvent(e.clone());
	}
	
	/**
	 * create Channel , And play sound. チャンネルを生成して音楽を再生します。
	 * @param	offset
	 * @param	volume
	 * @param	pan
	 * @param	loop
	 * @return
	 */
	override public function play(offset:Float, volume:Float, pan:Float , loop:Int = 0) : BaseSoundChannel 
	{
		if ( wave != null )	return new WAVChannel(this.wave, offset, volume, pan, loop);
		return null;
    }
	
	override public function getURL():String 	{	wave != null ?	return this.wave.url : return "";	}
	override public function getLength() : Float { 	wave != null ?	return this.wave.length : return 0;   }
}

