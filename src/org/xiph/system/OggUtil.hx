package org.xiph.system;

import org.xiph.fogg.Packet;
import org.xiph.fogg.Page;
import org.xiph.fogg.SeekableSyncState;
import org.xiph.fogg.StreamState;
import org.xiph.fogg.SyncState;
import org.xiph.fvorbis.Comment;
import org.xiph.fvorbis.Info;
import org.xiph.system.Bytes;

/**
 * Utility classes related Ogg...
 * @author tudurao jin
 */

class OggUtil 
{
	
	public function new() 
	{
	}
	
	//get the playback time of OGG.　(Millisecond)  OGGの再生時間を求める。ミリ秒単位。 
	public static function getOggPlayLength( inData:Bytes ):Float
	{
		var oy : SeekableSyncState = new SeekableSyncState();
        var og : Page = new Page();
        oy.init();
		
		inData.position = 0;
		
		//set up SyncState
		var index : Int = oy.buffer( inData.bytesAvailable );
        oy.data = inData;
		oy.wrote( inData.bytesAvailable );
		
		var os:StreamState = new StreamState();
		var vi:Info = new Info();
		var vc:Comment = new Comment();
		
		//process header 
		if ( !getOggHeaderData( oy , os , vi , vc ) )
		{
			//OggHeader error 
			inData.position = 0;
			return -1;
		}
		var e_gpos:Int = -1;
		var ret:Int = oy.pageout_body_end( og );
		if ( ret < 0 || og.eos() == 0 )
		{
			inData.position = 0;
			return -1;
		}
		e_gpos = og.granulepos();
		
		//check error. granulposかsamplingrateが得られていないならエラー
		if ( e_gpos == -1 || vi.rate == 0 )
		{
			inData.position = 0;
			return -1;
		}
		inData.position = 0;
		
		//convert granulpos to ms
		return convertGPosToMS( e_gpos , vi.rate );
	}
	
	//header processing. Info and comment is updated. ヘッダー処理を行う。Infoとcommentが更新される。
	public static function getOggHeaderData( oy:SyncState , os:StreamState , vi:Info , vc:Comment ):Bool
	{
		var og:Page = new Page();
		var op:Packet = new Packet();
		var i:Int = 0;
		while (i < 3)
		{
			//page out. ページを取り出す
			var result : Int = oy.pageout(og);
			//tracePage( og );//デバッグ
			if (result == 0) {
				trace("[OggUtil] <getOggHeaderData> Error reading 3 header packet.");
				return false;
			}
			if (result == 1) {
				if ( i == 0 ) {	os.init(og.serialno());		}
				os.pagein(og);
				while ( i < 3 ) 
				{
					result = os.packetout(op);
					if (result == 0) {
						trace("[OggUtil] <getOggHeaderData> no packet. break.");
						break;
					};
					if (result == -1) {
						trace("[OggUtil] <getOggHeaderData> Corrupt secondary header.  Exiting.");
						return false;
					};
					switch( op.packetno )
					{
						case 0:
							vi.init();
							vc.init();
							vi.synthesis_headerin(vc, op);
						case 1:
							vi.synthesis_headerin(vc, op);
						case 2:
							vi.synthesis_headerin(vc, op);
					}
					vi.synthesis_headerin(vc, op);
					i++;
				};
			}
		};
		
		if ( i < 3 )
		{
			return false;
		}
		return true;
	}
	
	
	//get ogg comments object
	public static function getOggID3( inData:Bytes ):OggID3
	{
		var oy : SeekableSyncState = new SeekableSyncState();
        var og : Page = new Page();
        oy.init();
		
		inData.position = 0;
		
		//SyncStateの設定
		var index : Int = oy.buffer( inData.bytesAvailable );
        oy.data = inData;
		oy.wrote( inData.bytesAvailable );
		
		var os:StreamState = new StreamState();
		var vi:Info = new Info();
		var vc:Comment = new Comment();
		
		if ( !OggUtil.getOggHeaderData( oy , os , vi , vc ) )
		{
			inData.position = 0;
			trace("[OggUtil] Header decode error.");
			return null;
		}
		
		//create ID3 object
		var oggid3:OggID3 = new OggID3();
		oggid3.convert( vc );
		return oggid3;
	}
	
	//convert millisecond -> granulpos. 指定時間( millisecond )をgranulposに変換
	public static function convertMSToGPos( ms:Float , rate:Float ):Float
	{
		return ( ms / 1000 ) * rate;
	}
	
	//convert granulpos -> millisecond. granulposを指定時間( millisecond )に変換
	public static function convertGPosToMS( gpos:Float , rate:Float ):Float
	{
		return ( gpos / rate ) * 1000;
	}
	
}