package ru.etcs.media;

import flash.display.Loader;
import flash.events.Event;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.utils.ByteArray;
import flash.utils.Endian;
import ru.etcs.events.WaveSoundEvent;

/**
 * 直接バイナリを渡すタイプのWaveSoundクラスです...
 * @author Tudurao Jin
 */
class BinaryWaveSound extends WaveSound
{
	private var _data:ByteArray;
	
	public function new(?stream:URLRequest = null) 
	{
		super(null);
		this.url = "";
	}
	
	/**
	 * set Binary.
	 * @param	bytes WAV binary data.
	 * @eventType Event.COMPLETE generated Sound.
	 */
	public function setBinary( byte:ByteArray ) 
	{
		this._data = byte;
		this._data.endian = Endian.LITTLE_ENDIAN;
		bytesLoaded = this._data.length;
		bytesTotal = this._data.length;
		
		waveHeader = new ByteArray();
		waveHeader.endian = Endian.LITTLE_ENDIAN;
		waveData = new ByteArray();
		waveData.endian = Endian.LITTLE_ENDIAN;
		this._data.readBytes(waveHeader,0,PCMFormat.HEADER_SIZE);
		waveFormat = new PCMFormat();
		
		try {
			waveFormat.analyzeHeader(waveHeader);
		} catch (e : Dynamic) {
			dispatchEvent(new WaveSoundEvent(WaveSoundEvent.DECODE_ERROR));
			return;
		}
		
		var bytesToRead:UInt = this._data.bytesAvailable < waveFormat.waveDataLength ? this._data.bytesAvailable : waveFormat.waveDataLength;
		this._data.readBytes(waveData,0,bytesToRead);
		var swf:SWFFormat = new SWFFormat(waveFormat);
		var compiledSWF:ByteArray = swf.compileSWF(waveData);
		var loader:Loader = new Loader();
		var context : LoaderContext = new LoaderContext();
		context.allowCodeImport = true;
		loader.loadBytes(compiledSWF, context);
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE,generateCompleteHandler);
	}
	
}