package org.xiph.frontend;

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.media.SoundLoaderContext;
import flash.net.URLRequest;
import ru.etcs.events.WaveSoundEvent;
import ru.etcs.media.WaveSound;

class WAV extends BaseSound 
{
    private var wave : WaveSound;
    
    public function new(url:URLRequest , ?inSlc:SoundLoaderContext )
	{
        super( inSlc );
        wave = new WaveSound(url);
        wave.addEventListener(Event.OPEN, onOpen);
        wave.addEventListener(Event.COMPLETE, onComplete);
        wave.addEventListener(ProgressEvent.PROGRESS, onProgress);
        wave.addEventListener(WaveSoundEvent.DECODE_ERROR, onDecodeError);
        wave.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
        //wave.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus);
    }
	
	/**
	 * create Channel , And play sound. チャンネルを生成して音楽を再生します。
	 * @param	offset
	 * @param	volume
	 * @param	pan
	 * @param	loop
	 * @return
	 */
    public override function play(offset:Float, volume:Float, pan:Float , loop:Int = 0) : BaseSoundChannel 
	{
        return new WAVChannel(this.wave, offset, volume, pan, loop);
    }
    
	private function onOpen( e:Event ):Void
	{
		dispatchEvent( e.clone() );
    }

    private function onProgress(e:ProgressEvent):Void
	{
		dispatchEvent( e.clone() );
    }
	
    private function onComplete(e:Event):Void
	{
		wave.removeEventListener(Event.OPEN, onOpen);
        wave.removeEventListener(Event.COMPLETE, onComplete);
        wave.removeEventListener(ProgressEvent.PROGRESS, onProgress);
        wave.removeEventListener(WaveSoundEvent.DECODE_ERROR, onDecodeError);
        wave.removeEventListener(IOErrorEvent.IO_ERROR, onIoError);
        //wave.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus);
		
		dispatchEvent( e.clone() );
    }

    private function onIoError(e:IOErrorEvent):Void
	{
		dispatchEvent( e.clone() );
    }
	
	private function onDecodeError(e:WaveSoundEvent):Void 
	{
		dispatchEvent( e.clone() );
	}
	
	override public function getURL():String 	{		return this.wave.url;	}
	override public function getLength() : Float {       return this.wave.length;    }
}
