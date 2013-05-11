package org.xiph.system;
import flash.events.Event;

/**
 * OggDecoder Event...
 * @author tudurao jin
 */

class OggDecoderEvent extends Event
{
    public static inline var BUFFER_STOREUP_START:String = "buffer_storeup_start";
	public static inline var BUFFER_STOREUP_OK:String = "buffer_storeup_ok"; //Buffer is stored up the minimum required quantities data.
	public static inline var BUFFER_STOREUP_MAX:String = "buffer_storeup_max"; //data stored up in buffer max range.
    public static inline var HEADER_PROCESS_COMPLETE:String = "header_process_complete";
    public static inline var DECODE_EOF:String = "decode_EOF";
	public static inline var SEEK_COMPLETE:String = "seek_complete";

    public function new( type : String, bubbles : Bool = false, cancelable : Bool = false )
	{
        super( type , bubbles , cancelable );
    }
	
	override public function clone():OggDecoderEvent 
	{
		var e:OggDecoderEvent = new OggDecoderEvent( this.type, this.bubbles , this.cancelable );
		return e;
	}
	
	override public function toString():String 
	{
		var ret_str:String = formatToString("OggDecoderEvent" , "type", "bubbles", "cancelable", "eventPhase" );
		return ret_str;
	}
}