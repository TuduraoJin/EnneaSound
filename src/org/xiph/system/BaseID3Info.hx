package org.xiph.system;
import flash.events.Event;
import flash.media.ID3Info;

/**
 * ID3 information acquisition class of BaseSound class...
 * @author tudurao jin
 */

class BaseID3Info 
{
	public var id3:ID3Info;
	
	public function new() 
	{
		id3 = new ID3Info();
	}
	
	public function toString():String
	{
		return ("[OggID3Info songName=\"" + id3.songName + "\" album=\"" + id3.album + 
			"\" artist=\"" + id3.artist + "\" track=\"" + id3.track + 
			" comment=\"" + id3.comment + "\" year=\"" + id3.year + 
			" genre=\"" + id3.genre + "]");
	}
	
	public var songName(get,set):String;
	private function get_songName():String{	return this.id3.songName;	}
	private function set_songName(value:String):String	{		return  this.id3.songName = value;	}
	
	public var album(get,set):String;
	private function get_album():String {		return  this.id3.album;	}
	private function set_album(value:String):String {return  this.id3.album = value;	}
	
	public var track(get,set):String;
	private function get_track():String {		return  this.id3.track;	}
	private function set_track(value:String):String {		return this.id3.track = value;	}
	
	public var artist(get,set):String;
	private function get_artist():String{		return this.id3.artist;		}
	private function set_artist(value:String):String{		return this.id3.artist = value;		}	
	
	public var comment(get,set):String;
	private function get_comment():String{		return this.id3.comment;	}
	private function set_comment(value:String):String{		return this.id3.comment = value;	}
	
	public var genre(get,set):String;
	private function get_genre():String{		return this.id3.genre;	}
	private function set_genre(value:String):String {		return this.id3.genre = value;	}
	
	public var year(get,set):String;
	private function get_year():String {		return this.id3.year;	}
	private function set_year(value:String):String {		return this.id3.year = value;	}
}