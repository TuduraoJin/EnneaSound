package org.xiph.system;

import flash.errors.Error;
import flash.events.EventDispatcher;
import flash.Vector;
import haxe.Timer;
import org.xiph.fogg.Packet;
import org.xiph.fogg.Page;
import org.xiph.foggy.OggVorbisDemuxer;
import org.xiph.fvorbis.Block;
import org.xiph.fvorbis.Comment;
import org.xiph.fvorbis.DspState;
import org.xiph.fvorbis.Info;

/**
 * Class to decode the OggVorbis...
 * Oggバイナリをデコードし、PCMを取り出しバッファに格納します。
 * シーク処理で、任意の位置に移動し、PCMデータを取り出す機能もあります。
 * loadメソッドでデータを読み込みます。読み込むデータはバイナリ全データです。
 * processHeaderメソッドでヘッダー情報を処理します。
 * processStartでデコードを開始します。
 * readメソッドでバッファからPCMデータを取り出します。
 * 
 * デコードを開始後は、Bufferのイベントにより、自動的にデコードを実行します。
 * Bufferのイベントリスナーにより、バッファが上限を下回ったら、デコードを再開しPCMをバッファに補充します。
 * PCMがバッファ上限を上回れば、リスナーによりデコードを停止します。
 * 
 * @author tudurao jin
 */

class OggDecoder extends EventDispatcher
{
    private var _vi : Info;
    private var _vc : Comment;
    private var _vd : DspState;
    private var _vb : Block;
	private var _dmx:OggVorbisDemuxer;
    private var _pcm : Array<Array<Vector<Float>>>;
    private var _index : Vector<Int>;
	private var _pcmRb:PCMRingBuffer;
	private var _seekPCMTargetGpos:Int;
	private var _seekPCMprevGpos:Int;
	private var _bufferTimeMS:Int;
	private var _need_samples:Bool;
	private var _isHeaderProcessed:Bool;
	private var _isDecoding:Bool;
	private var _eos:Bool;
	
	public static var BUFFER_COFF_LENGTH:Float = 2.5;
	public static var BUFFER_COFF_REDLINE:Float = 2;
	public static var BUFFER_COFF_GREENLINE:Float = 1;
	private static inline var BUFFER_SAMPLE_RATE:Int = 44100;
	
	/**
	 * Constructor
	 * @param	buffTime buffer size.
	 */
	public function new( buffTime:Int = 1000 ) 
	{
		super();
		_vi = new Info();
		_vc = new Comment();
		_vd = new DspState();
		_vb = new Block(_vd);
		_dmx = new OggVorbisDemuxer();
		this._bufferTimeMS = buffTime;
		this._need_samples = false;
		this._isHeaderProcessed = false;
		this._isDecoding = false;
		this._eos = false;
	}
	
	/**
	 * load data.
	 * @param	inData sound binary.
	 * @return true = success , false = failed.
	 */
	public function load( inData:Bytes ):Bool
	{
		var ret:Int = 0;
		inData.position = 0;
		ret = this._dmx.readNoCopy( inData , inData.bytesAvailable );
		
		//trace("[OggDecoder] <load> OggDemuxer.read() ret=" + Std.string(ret));
		if ( 0 < ret )
		{
			this._dmx.set_packet_cb( -1 , _proc_packet_head );
			//this._dmx.set_page_cb( -1 , _proc_page );
			return true;
		}
		
		return false;
	}
	
	/**
	 * buffer clear.
	 */
	public function clearBuffer():Void
	{
		if ( _isHeaderProcessed )
		{
			this._pcmRb.clear();
			_pcm = [null];
			_index = new Vector( _vi.channels, true);
		}
		this._need_samples = true;
		this._eos = false;
		_vd.synthesis_init(_vi);
		_vb.init(_vd);
	}
	
	/**
	 * reset status.
	 */
	public function reset():Void
	{
		_vi.clear();
		_vc.clear();
		_vd.clear();
		_vb.clear();
		this._need_samples = false;
		this._isHeaderProcessed = false;
		this._isDecoding = false;
		this._eos = false;
		if ( _isHeaderProcessed )
		{
			this._pcmRb.clear();
			this._pcmRb = null;
			_pcm = [null];
			_index = null;
		}
		this._dmx.pageseek_head();
		this._dmx.set_packet_cb( -1 , _proc_packet_head );
	}
	
	/**
	 * dispose.
	 * check: please call at if delete this instance. このクラスのインスタンスを削除する場合に呼んでください。
	 */
	public function dispose():Void
	{
		reset();
		this._dmx.dispose();
		this._dmx = null;
	}
	
	
	/**
	 * process header. 
	 * check: please execute after load(). 先にload()を実行してください。
	 * @eventType OggDecoderEvent.HEADER_PROCESS_COMPLETE
	 */
	public function processHeader():Void
	{
		this._dmx.pageseek_head();
		var dmxSt:OggVorbisDemuxerStatus;
		var i:Int = 0;
		while ( i < 3 )
		{
			dmxSt = _dmx.process();
			//trace(" page=" + Std.string(i) +" DemuxerStatus=" + dmxSt);
			if ( dmxSt == OggVorbisDemuxerStatus.STOP || this._isHeaderProcessed ) {	break;	}
			if ( dmxSt == OggVorbisDemuxerStatus.EOF )
			{
				throw new Error("[OggDecoder] <processHeader> header decode failed." );
				break;
			}
			i++;
		}
		dispatchEvent(new OggDecoderEvent(OggDecoderEvent.HEADER_PROCESS_COMPLETE));
	}
	
	/**
	 * start decode. デコード開始
	 * check: please execute after processHeader(). 先にprocessHeader()を実行してください。
	 * If you want to play from the offset of any, please run the seek method before.　もし、任意のオフセットから再生したい場合、先にシークメソッドを実行してください。
	 */
	public function processStart():Void
	{
		this._isDecoding = true;
		Timer.delay( decode , 0 );
	}
	
	/**
	 * stop decode. デコード停止
	 */
	public function processStop():Void
	{
		this._isDecoding = false;
	}
	
	/**
	 * do the decoding process. デコード処理を行います。　
	 * It moves the pages, it processes the packet and page. ページの移動を行い、ページとパケットを処理します。
	 * @eventType OggDecoderEvent.BUFFER_STOREUP_START
	 * @eventType OggDecoderEvent.BUFFER_STOREUP_OK (in RingBuffer handler)
	 * @eventType OggDecoderEvent.BUFFER_STOREUP_MAX (in RingBuffer handler)
	 */
	private function decode():Void 
	{
		if ( this._eos || !this._isDecoding ) {	return;	}
		
		dispatchEvent(new OggDecoderEvent(OggDecoderEvent.BUFFER_STOREUP_START));
		
		var result:OggVorbisDemuxerStatus  = _dmx.process();
		
		if ( result == OggVorbisDemuxerStatus.EOF )
		{
			trace("[OggDecoder] <decode> EOF" );
			this._eos = true;
			this._isDecoding = false;
			dispatchEvent(new OggDecoderEvent(OggDecoderEvent.DECODE_EOF));
		}
		if( _need_samples && result == OggVorbisDemuxerStatus.OK ){		Timer.delay( decode , 0 );	}
    }
	
	/**
	 * read the PCM, which is decoded from the buffer.　バッファからデコードされたPCMを読み込みます。
	 * @param	dst　It is into which the data is read. データの読み込み先です。
	 * @param	inLength The length of the data to be read 読み込むデータの長さです。
	 * @return true = read is success. false = read is failed.
	 */
	public function read( dst:Bytes , inLength:Int ):Bool
	{
		var to_read:Int = inLength;
		if ( this._pcmRb.getSamples() < inLength ) {	to_read = this._pcmRb.getSamples();	}
		
		if ( 0 < to_read ){
			return this._pcmRb.readPCM( dst, to_read );	
		}else {
			return false;
		}
	}
	
	/**
	 * seek the position of the head of the Sound. 音の先頭の位置にシークします。
 	 * check: please execute after processHeader(). 先にprocessHeader()を実行してください。
	 * @return Value is greater than 0 = success. -1 = error.
	 * @eventType OggDecoderEvent.SEEK_COMPLETE If process success.
	 */
	public function seek_top():Int
	{
		if ( !this._isHeaderProcessed ) {		return -1;		}
		this._eos = false;
		var ret:Int = this._dmx.pageseek_body_top();
		if( 0 < ret ){	dispatchEvent(new OggDecoderEvent(OggDecoderEvent.SEEK_COMPLETE));	}
		return ret;
	}
	
	/**
	 * seek the position of the specified number of samples. (Page seek) 指定のサンプル数の位置にシークする。（ページシーク）
	 * @param	gpos granul position.
	 * @return Value is greater than 0 = success. -1 = error.
	 * @eventType OggDecoderEvent.SEEK_COMPLETE If process success.
	 */
	public function seek_pcm_page( gpos:Int ):Int
	{
		if ( !this._isHeaderProcessed ) {		return -1;		}
		if ( gpos <  0 ) {	return -1;	}
		if ( gpos == 0 ) {	return this.seek_top();	}
		
		this._eos = false;
		var ret:Int = this._dmx.pageseek_targetGpos( gpos );
		if( 0 < ret ){	dispatchEvent(new OggDecoderEvent(OggDecoderEvent.SEEK_COMPLETE));	}
		return ret;
	}
	
	/**
	 * seek the position of the specified time(millisecond). (Page seek) 指定の時間(millisecond)の位置にシークする。（ページシーク）
	 * @param	timeMS Value is offset.　オフセット。
	 * @return Value is greater than 0 = success. -1 = error.
	 * @eventType OggDecoderEvent.SEEK_COMPLETE If process success. ( in _proc_packet_seekPCM() )
	 */
	public function seek_time_page( timeMS:Float ):Int
	{
		var targetGpos:Float = OggUtil.convertMSToGPos( timeMS , this._vi.rate );
		var ret:Int = this.seek_pcm_page( Std.int(targetGpos) );
		return ret;
	}
	
	/**
	 * seek the position of the specified number of samples. (Exact seek) 指定のサンプル数の位置にシーク（厳密なシーク）
	 * @param	gpos granul position.
	 * @return  1 = success, and start seek by _proc_packet_seekPCM(). -1 = failed.
	 */
	public function seek_pcm( gpos:Int ):Int
	{
		if ( !this._isHeaderProcessed ) {		return -1;		}
		if ( gpos <  0 ) {	return -1;	}
		if ( gpos == 0 ) {	return this.seek_top();	}
		
		this._eos = false;
		
		//move target gpos. ターゲットの位置に移動
		if ( this._dmx.pageseek_targetGpos( gpos ) < 0 )
		{
			return -1;
		}
		
		//get prev page's gpos. 前のページのgranulposを得る。
		var og:Page = new Page();
		if ( this._dmx.pageseek_back() < 0 )
		{
			return -1;
		}
		this._dmx.pageout_next( og );
		this._seekPCMprevGpos = og.granulepos();
		
		//Remember the target position. ターゲット位置を記憶
		this._seekPCMTargetGpos = gpos;
		
		//demxuer callback set
		this._dmx.remove_packet_cb( og.serialno() );
		this._dmx.set_packet_cb( og.serialno() , this._proc_packet_seekPCM );
		Timer.delay( decode , 0 ); //start seek by decode.
		return 1;
	}
	
	/**
	 * seek the position of the specified time(millisecond). (Exact seek) 指定の時間(millisecond)の位置にシークする。（厳密なシーク）
	 * @param	timeMS Value is offset.　オフセット。
	 * @return 1 = success, and start seek by _proc_packet_seekPCM(). -1 = failed.
	 */
	public function seek_time( timeMS:Float ):Int
	{
		var targetGpos:Float = OggUtil.convertMSToGPos( timeMS , this._vi.rate );
		var ret:Int = this.seek_pcm( Std.int(targetGpos) );
		return ret;
	}
	
	//=============================================//
	//             Demuxer Callback                //
	
	/**
	 * default page callback.
	 * @param	p
	 * @param	sn
	 * @return
	 */
	private function _proc_page( p:Page , sn:Int ):OggVorbisDemuxerStatus 
	{
		trace("[OggDecoder] <_proc_page> Page No." + Std.string(p.pageno()) + " granpos=" + Std.string( p.granulepos() ) );
		return OggVorbisDemuxerStatus.OK;
	}
	
	/**
	 * Callback to process the header. ヘッダーを処理するコールバック。
	 * @param	p
	 * @param	sn
	 * @return OggVorbisDemuxerStatus.OK = success process packet, next packet. OggVorbisDemuxerStatus.STOP = Processing of the packet header is complete. OggVorbisDemuxerStatus.ERROR = failed.
	 */
	private function _proc_packet_head( p:Packet, sn:Int ) : OggVorbisDemuxerStatus 
	{
		trace("[OggDecoder] <_proc_packet_head> Packet No." + Std.string(p.packetno));
		switch( p.packetno )
		{//switch packetno
			case 0:
				_vi.init();
				_vc.init();
				if (_vi.synthesis_headerin(_vc, p) < 0) {
					// not vorbis - clean up and ignore
					_vc.clear();
					_vi.clear();
					return OggVorbisDemuxerStatus.ERROR;
				} else {
					// vorbis
					// pass
				}
	        case 1:            _vi.synthesis_headerin(_vc, p);
			case 2:
				_vi.synthesis_headerin(_vc, p);
				_vd.synthesis_init(_vi);
				_vb.init(_vd);
				_pcm = [null];
				_index = new Vector( _vi.channels, true);
				
				//Initialize the buffer.
				//var buf_len:UInt = cast( (this._bufferTimeMS * _vi.rate) / 1000 , UInt ) * 8;
				var buf_len:UInt = cast( (this._bufferTimeMS * BUFFER_SAMPLE_RATE) / 1000 , UInt ) * 8;
				_pcmRb = new PCMRingBuffer( 
					cast(buf_len * BUFFER_COFF_LENGTH , UInt), 
					cast(buf_len * BUFFER_COFF_GREENLINE , UInt),
					cast(buf_len * BUFFER_COFF_REDLINE , UInt) );
				_pcmRb.addEventListener( RingBufferEvent.OVER_GREENLINE , overGLine ,false, 0, true);
				_pcmRb.addEventListener( RingBufferEvent.OVER_REDLINE , overRLine ,false, 0, true);
				_pcmRb.addEventListener( RingBufferEvent.UNDER_REDLINE , underRLine ,false, 0, true);
				
				this._need_samples = true; //decode flag.
				
				this._dmx.remove_packet_cb( sn );
				this._dmx.set_packet_cb(sn, _proc_packet_body);
				
				this._isHeaderProcessed = true;
				
				trace("[OggDecoder] <_proc_packet_head> Header decode complete.");
				return OggVorbisDemuxerStatus.STOP;
		}//switch packetno

        return OggVorbisDemuxerStatus.OK;
    }
	
	
	/**
	 * Callback to process the body. データの本体を処理するコールバック。
	 * @param	p
	 * @param	sn
	 * @return OggVorbisDemuxerStatus.OK = success process packet, next packet. OggVorbisDemuxerStatus.STOP = stop the decoding buffer is full.
	 */
	private function _proc_packet_body(p : Packet, sn : Int) : OggVorbisDemuxerStatus 
	{
		//trace("[OggDecoder] <_proc_packet_body> Packet No." + Std.string(p.packetno));
		var samples : Int;

		if (_vb.synthesis(p) == 0) {
			_vd.synthesis_blockin(_vb);
		}
		
		var ret:Int = 0;
		while ((samples = _vd.synthesis_pcmout(_pcm, _index)) > 0) 
		{
			//trace("[OggDecoder] <_proc_packet_body> Packet No." + Std.string(p.packetno) + " samples=" + Std.string(samples) );
			ret = this._pcmRb.writePCM( _pcm[0] , _index , samples , cast((44100 / _vi.rate) , Int) ); //data write
			_vd.synthesis_read(samples);
			if ( ret < 0 ) {	return OggVorbisDemuxerStatus.STOP;		}
		}
		
        return OggVorbisDemuxerStatus.OK;
	}
	
	private var _sample_total:Int = 0; //use seekPCM. count sample total.
	
	/**
	 * Callback to process the seekPCM. PCMシークの処理をするコールバック。
	 * @param	p
	 * @param	sn
	 * @return OggVorbisDemuxerStatus.OK = not found seek position , next packet. OggVorbisDemuxerStatus.STOP = stop the decoding , found seek position.
	 * @eventType OggDecoderEvent.SEEK_COMPLETE If found seek position.
	 */
	private function _proc_packet_seekPCM( p:Packet , sn:Int ):OggVorbisDemuxerStatus
	{
		//trace("[OggDecoder] <_proc_packet_seekPCM> Packet No." + Std.string(p.packetno));
		var samples : Int;
		if (_vb.synthesis(p) == 0) {
			_vd.synthesis_blockin(_vb);
		}
		
		
		while ((samples = _vd.synthesis_pcmout(_pcm, _index)) > 0) 
		{
			_sample_total += samples;
			trace("[OggDecoder] <_proc_packet_seekPCM> targetGpos <= prevGpos+samples  :" + 
				Std.string( _seekPCMTargetGpos ) + " <= " + Std.string(this._seekPCMprevGpos + _sample_total) +
				" samples=" + Std.string(samples) +
				" moveIndex=" + Std.string( samples - ((this._seekPCMprevGpos + _sample_total) - this._seekPCMTargetGpos ) )
				);
			if ( this._seekPCMTargetGpos <= this._seekPCMprevGpos + _sample_total )
			{
				trace("[OggDecoder] <_proc_packet_seekPCM> seek pcm  position found." );
				
				//seek pcm  position found.
				for ( i in 0..._index.length )
				{
					_index[i] += samples - ((this._seekPCMprevGpos + _sample_total) - this._seekPCMTargetGpos );
				}
				this._pcmRb.writePCM( _pcm[0] , _index , samples , cast((44100 / _vi.rate) , Int) ); //data write
				this._vd.synthesis_read(samples);
				this._dmx.remove_packet_cb( sn );
				this._dmx.set_packet_cb( sn , this._proc_packet_body ); //packet callback reset
				this._seekPCMTargetGpos = -1;
				this._sample_total = 0;
				dispatchEvent(new OggDecoderEvent(OggDecoderEvent.SEEK_COMPLETE));
				return OggVorbisDemuxerStatus.STOP;
			}
			this._vd.synthesis_read(samples);
		}
		
        return OggVorbisDemuxerStatus.OK;
	}
	
	//             Demuxer Callback                //
	//=============================================//
	
	
	//=============================================//
	//             RingBuffer Callback             //
	
	/**
	 * It is the handler attempting to exceed the GreenLine.GreenLineを超えた時のハンドラです。
	 * I mean that the buffer has accumulated a certain number. バッファが一定数溜まったことを意味します。
	 * @param	e
	 */
	private function overGLine(e:RingBufferEvent):Void 
	{
        //trace("[OggDecoder] <overGLine> ");
		Timer.delay( dispatchStoreUPEv , 0 );
	}
	
	/**
	 * dispatch event.
	 */
	private function dispatchStoreUPEv():Void
	{
		dispatchEvent(new OggDecoderEvent(OggDecoderEvent.BUFFER_STOREUP_OK));
	}
	
	/**
	 * It is the handler attempting to exceed the Redline.RedLineを超えた時のハンドラです。
	 * I mean that the buffer is greater than the upper limit. バッファが上限を超えたことを意味します。
	 * @param	e
	 */
	private function overRLine(e:RingBufferEvent):Void 
	{
		//trace("[OggDecoder] <overRLine> ");
		_need_samples = false;
		dispatchEvent(new OggDecoderEvent(OggDecoderEvent.BUFFER_STOREUP_MAX));
	}
	
	/**
	 * It is the handler when below the RedLine. RedLineを下回った時のハンドラです。
	 * I mean that the buffer is below the upper limit by the read method.　readメソッドによりバッファが上限を下回ったことを意味します。
	 * @param	e
	 */
	private function underRLine(e:RingBufferEvent):Void 
	{
		//trace("[OggDecoder] <underRLine> ");
        _need_samples = true;
        Timer.delay(decode, 0);
	}
	
	//             RingBuffer Callback             //
	//=============================================//
	
	//=============================================//
	//              getter / setter                //
	
	public function getSamples():Int{		return this._pcmRb.getSamples();	}
	public function isHeaderProcessed():Bool {	return _isHeaderProcessed;	}
	public function isDecoding():Bool {	return _isDecoding;	}
	public function isBufferOK():Bool {
		if ( _pcmRb != null && ( _pcmRb.greenLine <= _pcmRb.getBytesAvailable() )) { return true;	}
		return false;
	}	
	public function isBufferMAX():Bool 
	{
		if ( _pcmRb != null && ( _pcmRb.redLine <= _pcmRb.getBytesAvailable() )) { return true;	}
		return false;
	}
	
	
	/**
	 * set Buffer size.
	 * @param	inLength buffer length.
	 * @param	inGreenLine Event BUFFER_STOREUP_OK is dispatch when data size exceeds this line.
	 * @param	inRedLine Event BUFFER_STOREUP_MAX is dispatch when data size exceeds this line. 
	 */
	public function setBufferSize( inLength:UInt , inGreenLine:UInt , inRedLine:UInt ):Void
	{
		this._pcmRb.length = inLength;
		this._pcmRb.greenLine = inGreenLine;
		this._pcmRb.redLine = inRedLine;
	}
	//              getter / setter                //
	//=============================================//

}