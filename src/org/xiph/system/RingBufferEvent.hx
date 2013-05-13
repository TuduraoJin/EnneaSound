package org.xiph.system;
import flash.events.Event;

/**
 * RingBuffer Event...
 * @author tudurao jin
 */

class RingBufferEvent extends Event
{
	public static inline var OVER_REDLINE:String = "over_RedLine";
	public static inline var OVER_GREENLINE:String = "over_GreenLine";
	public static inline var UNDER_REDLINE:String = "under_RedLine";
	public static inline var UNDER_GREENLINE:String = "under_GreenLine";
	public static inline var WRITE_OVERFLOW:String = "write_OverFlow";
	public static inline var READ_OVERFLOW_EMPTY:String = "read_OverFlow_Empty";

    public function new( type : String, bubbles : Bool = false, cancelable : Bool = false )
	{
        super( type , bubbles , cancelable );
    }
	
	override public function clone():RingBufferEvent 
	{
		var e:RingBufferEvent = new RingBufferEvent( this.type, this.bubbles , this.cancelable );
		return e;
	}
	
	override public function toString():String 
	{
		var ret_str:String = formatToString("RingBufferEvent" , "type", "bubbles", "cancelable", "eventPhase" );
		return ret_str;
	}
	
}