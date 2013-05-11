package org.xiph.fogg;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.Vector;
import haxe.Timer;
import org.xiph.fogg.Page;
import org.xiph.system.Bytes;

/**
 * SeekableSyncStateを高速化するクラス...
 * あらかじめすべてのデータを渡す必要がある。
 * セットアップ処理に時間がかかる。
 * Vectorを用いて、あらかじめすべてのページの位置、granul positionを記憶する。
 * @author tudurao jin
 */

class SeekableSyncStateFast extends SeekableSyncState, implements IEventDispatcher
{
	private var pagePosVec:Vector<Int>;
	private var gposVec:Vector<Int>;
	public var isSetuped(default,null):Bool;
	
	public static inline var SETUP_COMPLETE:String = "Setup_Complete";

	public function new() 
	{
		super();
		ed = new EventDispatcher(this);
	}
	
	//================================================//
	//             ---Override methods---             //

	override public function init():Void 
	{
		if ( pagePosVec == null && gposVec == null )
		{
			pagePosVec = new Vector<Int>();
			gposVec = new Vector<Int>();
		}
		super.init();
	}
	
	override public function reset():Int 
	{
		removeAllItem( this.pagePosVec );
		removeAllItem( this.gposVec );
		this.isSetuped = false;
		return super.reset();
	}
	
	override public function clear():Int 
	{
		removeAllItem( this.pagePosVec );
		removeAllItem( this.gposVec );
		this.isSetuped = false;
		return super.clear();
	}
	
	//override public function pageseek(og:Page):Int 
	//{
		//return super.pageseek(og);
	//}
	
	//override public function pageout(og:Page):Int 
	//{
		//return super.pageout(og);
	//}
	
	override public function pageseek_body_top():Int 
	{
		if ( isSetuped )
		{
			trace("[SeekableSyncStateFast] <pageseek_body_top> fast mode.");
			this.returned = this.pagePosVec[0];
			return 1;
		}else{
			return super.pageseek_body_top();
		}
	}
	
	override public function pageseek_body_end():Int 
	{
		if ( isSetuped )
		{
			trace("[SeekableSyncStateFast] <pageseek_body_end> fast mode.");
			this.returned = this.pagePosVec[ this.pagePosVec.length - 1 ];
			return 1;
		}else {
			return super.pageseek_body_end();
		}
	}
	
	//override public function pageout_body_top(og:Page):Int 
	//{
		//return super.pageout_body_top(og);
	//}
	
	//override public function pageout_body_end(og:Page):Int 
	//{
		//return super.pageout_body_end(og);
	//}
	
	override public function pageseek_back(og:Page):Int 
	{
		if ( isSetuped )
		{
			trace("[SeekableSyncStateFast] <pageseek_back> fast mode.");
			var result:Int = -1;
			var i:Int = this.pagePosVec.length - 1;
			while ( 0 <= i )
			{
				if ( this.pagePosVec[i] <= this.returned  )
				{
					//found
					this.returned = this.pagePosVec[i];
					result = pageout(og);
					if ( i > 0 ) {		this.returned = this.pagePosVec[i - 1];	}
					else {	this.returned = this.pagePosVec[i];	}
					break;
				}
				i--;
			}
			return result;
		}else {
			return super.pageseek_back(og);
		}
	}
	
	//override public function pageout_back(og:Page):Int 
	//{
		//return super.pageout_back(og);
	//}
	
	override public function pageseek_targetPage(t_PageNo:Int):Int 
	{
		if ( isSetuped )
		{
			trace("[SeekableSyncStateFast] <pageseek_targetPage> fast mode.");
			if ( this.pagePosVec.length - 1 < t_PageNo || t_PageNo < 0)
			{
				return -1;
			}
			this.returned = this.pagePosVec[t_PageNo];
			return 1;
			
		}else {
			return super.pageseek_targetPage(t_PageNo);
		}
	}
	
	//override public function pageout_targetPage(og:Page, t_PageNo:Int):Int 
	//{
		//return super.pageout_targetPage(og, t_PageNo);
	//}
	
	override public function pageseek_targetGpos(t_gpos:Int):Int 
	{
		if ( isSetuped )
		{
			trace("[SeekableSyncStateFast] <pageseek_targetGpos> fast mode.");
			if ( this.gposVec[gposVec.length - 1] < t_gpos || t_gpos < 0)
			{
				return -1;
			}
			
			var i:UInt = 0;
			while ( i < this.gposVec.length )
			{
				if ( t_gpos <= this.gposVec[i] )
				{
					//found
					this.returned = this.pagePosVec[i]; //move page
					return 1;
				}
				i++;
			}
			return -1;
		}else {
			return super.pageseek_targetGpos(t_gpos);
		}
	}
	
	//override public function pageout_targetGpos(og:Page, t_gpos:Int):Int 
	//{
		//return super.pageout_targetGpos(og, t_gpos);
	//}
	
	//             ---Override methods---             //
	//================================================//
	
	
	private function removeAllItem( vec:Vector<Int> ):Void
	{
		if ( vec == null ) { 	return;		}
		for ( i in 0...vec.length )
		{
			vec.pop();
		}
	}
	
	
	
	//set data, and setup param.
	//check: inData is full data.
	public function setData( inData:Bytes ):Void
	{
		if ( pagePosVec == null && gposVec == null )
		{
			pagePosVec = new Vector<Int>();
			gposVec = new Vector<Int>();
		}
		
		//set data
		inData.position = 0;
		this.buffer( inData.bytesAvailable );
		this.data = inData;
		this.wrote( inData.bytesAvailable );
		this.isSetuped = false;
		
		//vectorにページの位置を格納する。
		var og:Page = new Page();
		var result:Int = 0;
		var prev_returned:Int = 0;
		
		//move head
		this.pageseek_head();
		Timer.delay( setupVec , 0 ); //do setup.
	}
	
	private static inline var SETUP_LOOPSET:Int = 400; //setupVecでの　一回のページ処理量
	
	//set up Vector for Page position and granul position.
	//dispatch SETUP_COMPLETE event.
	private function setupVec():Void
	{
		trace("setupVec");
		
		//vectorにページの位置を格納する。
		var og:Page = new Page();
		var result:Int = 0;
		var prev_returned:Int = returned;
		
		var page:Int = pagePosVec.length;
		var i:Int = 0;
		while ( i < SETUP_LOOPSET ) {
			result = pageout( og );
			if ( result <= 0 )
			{
				//setup is over.
				//trace("[SeekableSyncStateFast] <setData> setup is over.");
				//traceVec(); //debug
				this.pageseek_head();
				this.isSetuped = true;
				dispatchEvent(new Event( SETUP_COMPLETE )); //イベント発行
				return;
			}else{
				//trace("[SeekableSyncStateFast] <setData> i=" + Std.string(i) + " pageNo= " + Std.string( og.pageno() ) + " granpos=" + Std.string(og.granulepos()) );
				this.pagePosVec[page] = prev_returned;
				this.gposVec[page] = og.granulepos();
				i++;
				page++;
			}
			prev_returned = returned;
		}
		
		Timer.delay( setupVec , 0 );
	}
	
	private function traceVec():Void
	{
		if ( pagePosVec == null && gposVec == null )
		{
			return;
		}
		
		var i:Int = 0;
		for( i in 0...pagePosVec.length ) {
			trace("[SeekableSyncStateFast] <traceVec> page " + Std.string( i )+ " Pos=" + Std.string(pagePosVec[i]) + " granpos=" + Std.string(gposVec[i]));
		}
		
	}
	
	
	//================================================//
	//        ---IEventDispather interface---         //
	
	var ed:EventDispatcher;
	
	public function addEventListener(type : String, listener : Dynamic -> Void, useCapture : Bool = false, priority : Int = 0, useWeakReference : Bool = false) : Void
	{
		ed.addEventListener( type , listener , useCapture , priority , useWeakReference );
	}
	
	public function dispatchEvent(event : Event) : Bool
	{
		return ed.dispatchEvent( event );
	}
	
	public function hasEventListener(type : String) : Bool
	{
		return ed.hasEventListener( type );
	}
	
	public function removeEventListener(type : String, listener : Dynamic -> Void, useCapture : Bool = false) : Void
	{
		ed.removeEventListener( type , listener , useCapture );
	}
	
	public function willTrigger(type : String) : Bool
	{
		return ed.willTrigger( type );
	}

	//        ---IEventDispather interface---         //
	//================================================//
	
}