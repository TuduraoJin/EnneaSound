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
	
	private function get_title():String{	return this.id3.songName;	}
	private function set_title(value:String):String	{		return  this.id3.songName = value;	}
	public var songName(get_title, set_title):String;
	
	private function get_album():String {		return  this.id3.album;	}
	private function set_album(value:String):String {return  this.id3.album = value;	}
	public var album(get_album, set_album):String;
	
	private function get_trackNumber():String {		return  this.id3.track;	}
	private function set_trackNumber(value:String):String {		return this.id3.track = value;	}
	public var track(get_trackNumber, set_trackNumber):String;
	
	private function get_artist():String{		return this.id3.artist;		}
	private function set_artist(value:String):String{		return this.id3.artist = value;		}	
	public var artist(get_artist, set_artist):String;
	
	private function get_description():String{		return this.id3.comment;	}
	private function set_description(value:String):String{		return this.id3.comment = value;	}
	public var comment(get_description, set_description):String;
	
	private function get_genre():String{		return this.id3.genre;	}
	private function set_genre(value:String):String {		return this.id3.genre = value;	}
	public var genre(get_genre, set_genre):String;
	
	private function get_date():String {		return this.id3.year;	}
	private function set_date(value:String):String {		return this.id3.year = value;	}
	public var year(get_date, set_date):String;
}