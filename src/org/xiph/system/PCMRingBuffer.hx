package org.xiph.system;
import flash.errors.ArgumentError;
import flash.Vector;
import haxe.Timer;

/**
 * PCM data RingBuffer...
 * Float　の音楽データをリングバッファに write / read する。
 * 2 channel の音楽とモノラルに対応。モノラルの場合、片方の音を左右チャンネルに割り振り、ステレオに変換する。
 * samplesプロパティで蓄積した音のサンプル数を取得できる。
 * 
 * @author tudurao jin
 */

class PCMRingBuffer extends RingBuffer
{
	/**
	 * Constructor
	 * @param	inLength
	 * @param	inGreenLine
	 * @param	inRedLine
	 */
	public function new( inLength:UInt ,inGreenLine:UInt = 0, inRedLine:UInt = 0 )
	{
		var len:UInt = inLength;
		var glen:UInt = inGreenLine;
		var rlen:UInt = inRedLine;
		
		if ( 0 < len % 8 ) 
		{
			len = cast( Math.floor(len / 8) * 8, UInt);
			if ( len < glen ) {	glen = len;		}
			if ( len < rlen ) {	rlen = len;		}
		}
		
		super( len, glen , rlen );
		
		if ( this._length < 8 ) {	throw new ArgumentError("[PCMRingBuffer] <constructor> parameter error. length < 8.");	}
    }
	
	
	/**
	 * write PCM data. data from DspState.pcm_out method.
	 * @param	inPcm pcm data. Vector<Float>
	 * @param	inIndex Array located at the beginning of the PCM to write.
	 * @param	inSamples Number of samples to be written.
	 * @param	inSampleMultiplier The ratio of the sampling rate of a subject to sampling rate maximum value 44100. サンプリングレート最大値44100に対する対象のサンプリングレートの比率。
	 * @return  Number of samples written. A negative value means the overflow.
	 */
	public function writePCM( inPcm:Array<Vector<Float>>, inIndex:Vector<Int>, inSamples:Int , inSampleMultiplier:Int = 1 ):Int
    {
		var write_samples:Int = inSamples;
		var over_samples:Int = 0;
		if ( (write_samples * inSampleMultiplier) * 8 > this._length - this._buffAvailable ) {
			write_samples = Std.int( (( this._length - this._buffAvailable ) / inSampleMultiplier) / 8 );
			over_samples = inSamples - write_samples;
		}
		
		var i : Int;
        var end : Int;
		var oldAvail:UInt = _buffAvailable;
		this._buff.position = getTail();
		
        if (inPcm.length == 1)
		{
            // single channel source data
            var c = inPcm[0];
            i = inIndex[0];
            end = i + write_samples;
            while (i < end) {
				this.writePCMbyMultiplier( _buff , c[i] , inSampleMultiplier );
				this.writePCMbyMultiplier( _buff , c[i] , inSampleMultiplier );
				i++;
            }
			this._buffAvailable += (write_samples * inSampleMultiplier) * 8;
			
			//write overflows
			end = end + over_samples;
			this._overflowBuff.position = this._overflowBuff.length;
			while ( i < end ) {
				this.writePCMbyMultiplier( _overflowBuff , c[i] , inSampleMultiplier , false);
				this.writePCMbyMultiplier( _overflowBuff , c[i] , inSampleMultiplier , false);
				i++;
            }
			this._overflowBuff.position = 0;
        }
		else if (inPcm.length == 2)
		{
            // two channels
            var c1 = inPcm[0];
            var c2 = inPcm[1];
            i = inIndex[0];
            var i2 = inIndex[1];
            end = i + write_samples;
            while (i < end) {
				this.writePCMbyMultiplier( _buff , c1[i] , inSampleMultiplier );
				this.writePCMbyMultiplier( _buff , c2[i2] , inSampleMultiplier );
                i++;
				i2++;
            }
			this._buffAvailable += (write_samples * inSampleMultiplier) * 8;
			
			//write overflows
			this._overflowBuff.position = this._overflowBuff.length;
			end = end + over_samples;
			while ( i < end ) {
				this.writePCMbyMultiplier( _overflowBuff , c1[i] , inSampleMultiplier , false );
				this.writePCMbyMultiplier( _overflowBuff , c2[i2] , inSampleMultiplier , false );
                i++;
				i2++;
            }
			this._overflowBuff.position = 0;
        } 
		else 
		{
            throw new ArgumentError("[PCMRingBuffer] <writePCM2> wrong num channels.");
        }
		
		//Callback execution and dispatch events
		this.checkOverLine( oldAvail , _buffAvailable );
		
		//dispatch Overflow event
		if ( over_samples != 0 ) 
		{
			this.dispatchEvent( new RingBufferEvent( RingBufferEvent.WRITE_OVERFLOW ));
			return -1 * (inSamples * inSampleMultiplier) * 8;
		}
		return (inSamples * inSampleMultiplier) * 8;
	}
	
	
	/**
	 * Writing PCM data to the specified buffer. 指定したバッファにPCMデータを書き込む。
	 * Considering the SampleMultiplier, to interpolate to 44100 the number of samples. SampleMultiplierを考慮し、サンプル数を44100に補間する。
	 * @param	inTarget write target buffer.
	 * @param	inData PCM data.
	 * @param	inSampleMultiplier
	 * @param	isRotate rotate for buffer. not rotate for overflowbuffer.
	 */	
	private function writePCMbyMultiplier( inTarget:Bytes , inData:Float , inSampleMultiplier:Int , isRotate:Bool = true ):Void
	{
		var i:Int = 0;
		while ( i < inSampleMultiplier )
		{
			inTarget.writeFloat(inData);
			if ( isRotate && inTarget.position == this._length ) {	inTarget.position = 0;	}
			i++;
		}
	}
	
	
	
	/**
	 * read PCM data.
	 * @param	dst
	 * @param	inSamples Is the number of samples, not in bytes.
	 * @return true = success / fase = failed.
	 */
	public function readPCM( dst:Bytes , inSamples:UInt ):Bool
	{
		return this.read( dst , inSamples * 8 );
	}
	
	
	//=============================================//
	//             Getter / Setter                 //
	
	private function get_sample():Int{		return Std.int(this.bytesAvailable / 8);	}
	public var samples(get_sample, null):Int; //Is the number of samples, not in bytes.
	
	//             Getter / Setter                 //
	//=============================================//
	
}