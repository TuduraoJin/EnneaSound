package org.xiph.frontend;

import flash.events.Event;
import flash.events.SampleDataEvent;
import flash.media.Sound;
import flash.media.SoundTransform;
import flash.utils.ByteArray;
import flash.Vector;
import org.xiph.foggy.Demuxer;
import org.xiph.system.ADQueue;
import org.xiph.system.VSoundDecoder;


class OGGChannel extends BaseSoundChannel {
    private var _aq : ADQueue; // audio data queue
    private var _dec : VSoundDecoder;

    private var _decoding : Bool;
    private var _need_data : Bool;
    private var _need_samples : Bool;
    private var _data_min : Bool;
    private var _data_complete : Bool;
    private var _read_pending : Bool;

    private var _s : Sound;
    private var _sch : flash.media.SoundChannel;

    //private var _c1 : Int;
    private var data : ByteArray;

    public static inline var SAMPLERATE : Int = 44100;
    public static inline var DATA_CHUNK_SIZE : Int = 16384;
	
	//add --------------
	private var _st:SoundTransform;
	private var _offset:Float;
	

    public function new(data:ByteArray, offset:Float, volume:Float, pan:Float) {
        super();
        
        data.position = 0;
        this.data = new ByteArray();
        data.readBytes(this.data);
        data.position = 0;
            
        _need_data = false;
        _need_samples = true;
        _data_min = false; // FIXME: should be _samples_min !!
        _data_complete = true;
        _read_pending = false;
        _decoding = true;
        
        _c1 = 0;
        
        _aq = new ADQueue(Std.int(1000 * SAMPLERATE / 1000));
        _dec = new VSoundDecoder();
        
        _aq.over_min_cb = _on_over_min;
        _aq.over_max_cb = _on_over_max;
        _aq.under_max_cb = _on_under_max;

        _dec.decoded_cb = _on_decoded;
        
        haxe.Timer.delay(_try_write_data, 0);

        _s = new Sound();
        _sch = null;
        _s.addEventListener(SampleDataEvent.SAMPLE_DATA, _data_cb);
		
		//---------add
		this._st = new SoundTransform( volume , pan );
		this._offset = offset;
		
        haxe.Timer.delay(_decode, 0);
    }
    
    public override function stop() : Void {
		if ( _sch == null )
		{
			trace("[OGGChannel] <stop> SoundChannel = null ");
			this._decoding = false;
			return;
		}
        _sch.removeEventListener(Event.SOUND_COMPLETE, channelComplete);
        _sch.stop();
    }

    public override function getPosition() : Float {
		if ( _sch != null )	{	return this._sch.position;		}
        return 0;
    }
    
    public override function getVolume() : Float {
		if ( _sch != null )	{	return this._sch.soundTransform.volume;		}
		return 0;
    }
    
    public override function getPan() : Float {
		if ( _sch != null )	{	return this._sch.soundTransform.pan;		}
        return 0;
    }
    
    public override function setVolume(volume : Float) : Void {
		if ( _sch != null )	
		{
			var t : SoundTransform = this._sch.soundTransform;
			t.volume = volume;
			this._sch.soundTransform = t;
		}
    }
    
    public override function setPan(pan : Float) : Void 
	{
		if ( _sch != null )	
		{
			var t : SoundTransform = this._sch.soundTransform;
			t.pan = pan;
			this._sch.soundTransform = t;
		}
    }
    
    
    
    
    function _try_write_data() : Void {
        _read_pending = false;

        if (! _need_data)
            return;

        var to_read : Int = this.data.length;
        if (to_read >= DATA_CHUNK_SIZE) {
            to_read = DATA_CHUNK_SIZE;
        } else if (_data_complete) {
            if (_dec.dmx.eos) {
                _need_data = false;
                return;
            }
            // pass
        } else {
            // we could reshedule read here, but if we don't have
            // enough data and we're still downloading then
            // on_progress should call us again... right?
            return;
        }

        _need_data = false;

        _dec.dmx.read(this.data, to_read);

        //if (_data_complete)
        //    _dec.dmx.read(_ul, 0);

        if (_need_samples)
            haxe.Timer.delay(_decode, 0);
    }

    function _decode() : Void {
        var result : Int = 0;

        while(_need_samples && (result = _dec.dmx.process(1)) == 1) {
            // pass
        }

        if (result == Demuxer.EOF) {
            // pass
        } else if (result == 0) {
			//init
            _need_data = true;
            if (!_read_pending) {
                _read_pending = true;
                haxe.Timer.delay(_try_write_data, 0);
            }
        }
    }
   
    

    // ADQueue callbacks
    function _on_over_min() : Void {
        _data_min = true;
        if (_decoding && _sch == null) {
            //_sch = _s.play();
            _sch = _s.play( 0 , 0 , this._st );
            _sch.addEventListener(Event.SOUND_COMPLETE, channelComplete);
        }
    }

    function _on_over_max() : Void {
        _need_samples = false;
    }

    function _on_under_max() : Void {
        _need_samples = true;
        haxe.Timer.delay(_decode, 0);
    }



    // VSoundDecoder callback
    function _on_decoded(pcm : Array<Vector<Float>>, index : Vector<Int>, samples : Int) : Void {
        _aq.write(pcm, index, samples);
    }



    // Sound data callback
    function _data_cb(event : SampleDataEvent) : Void {
        var avail : Int = _aq._samples;
        var to_write = avail > 8192 ? 8192 : avail; // FIXME: unhardcode!

        if (to_write > 0) {
            _aq.read(event.data, to_write);
            //_c1 += to_write;
        } else {
			trace("[OGGChannel] <_data_cb> to_write =< 0");
        }
    }
    
    private function channelComplete(e) {
		trace("end play pos");
		trace(this._sch.position );
        dispatchEvent( e.clone() );
    }
}
