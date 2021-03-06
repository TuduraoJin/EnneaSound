package org.xiph.system;
import flash.media.ID3Info;
import org.xiph.fvorbis.Comment;

/**
 * OggComment data class of ID3 compatible...
 * OggID3 is just a simple storage structure for the supported ogg comment tags.
 * Our encoder currently supports:
 * TITLE
 * VERSION
 * ALBUM
 * TRACKNUMBER
 * ARTIST
 * PERFORMER
 * COPYRIGHT
 * LICENSE
 * ORGANIZATION
 * DESCRIPTION
 * GENRE
 * DATE
 * LOCATION
 * CONTACT
 * ISRC
 * 
 * I have to convert the properties of the class flash.media.ID3Info following parameters.　以下のプロパティはID3Infoクラスのプロパティに変換しています。
 * title -> songName
 * album -> album
 * trackNumber -> track
 * artist  -> artist
 * genre -> genre
 * date -> year
 * 
 * @author tudurao jin
 */

class OggID3 extends BaseID3Info
{
	//public var title:String = "";   		-> songName
	public var version:String = "";
	//public var album:String = "";   		-> album
	//public var trackNumber:String = ""; 	-> track
	//public var artist:String = "";  		-> artist
	public var performer:String = "";
	public var copyright:String = "";
	public var license:String = "";
	public var organization:String = "";
	public var description:String = "";
	//public var genre:String = ""; 		-> genre
	//public var date:String = ""; 			-> year
	public var location:String = "";
	public var contact:String = "";
	public var isrc:String = "";
	
	/**
	 * Constructor
	 * @param	?vc
	 */
	public function new( ?vc:Comment ) 
	{
		super();
		if ( vc != null ) {	this.convert( vc );	}
	}
	
	/**
	 * convert the data in the Comment class.　Comment クラスのデータを変換します。
	 * @param	vc
	 */
	public function convert( vc:Comment ):Void
	{
		var i:Int = 0;
		var value:String = "";
		var tag:String = "";
		var array:Array<String>;
		
		while ( i < vc.comments )
		{
			//get String.
			array =  vc.getComment(i).split("=");
			tag = array[0];
			if ( array.length < 2 )	{		value = array[0];		}
			else {	value = array[1];		}
			
			switch(tag.toUpperCase())
			{//switch
				case "TITLE":					this.songName = value;
				case "VERSION":					this.version = value;
				case "ALBUM":					this.album = value;
				case "TRACKNUMBER":				this.track = value;
				case "ARTIST":		this.artist = value;
				case "PERFORMER":	this.performer = value;
				case "COPYRIGHT":	this.copyright = value;
				case "LICENSE":		this.license = value;
				case "ORGANIZATION":this.organization = value;
				case "DESCRIPTION":	this.description = value;
				case "COMMENT":		this.comment = value;
				case "GENRE":		this.genre = value;
				case "DATE":		this.year = value;
				case "LOCATION":	this.location = value;
				case "CONTACT":		this.contact = value;
				case "ISRC":		this.isrc = value;
				default:
			}//switch
			i++;
		}
	}
	
	/**
	 * output a string of property.　プロパティの文字列を出力します。
	 * @return
	 */
	override public function toString():String
	{
		return ("[OggID3Info songName=\"" + id3.songName + "\" album=\"" + id3.album + 
			"\" artist=\"" + id3.artist + "\" track=\"" + id3.track + 
			"\" comment=\"" + id3.comment + "\" year=\"" + id3.year + 
			"\" genre=\"" + id3.genre + " version=\"" + id3.version + 
			"\" organization=\"" + id3.organization + " performer=\"" + id3.performer +
			"\" contact=\"" + id3.contact + " copyright=\"" + id3.copyright +
			"\" isrc=\"" + id3.isrc + " license=\"" + id3.license +
			"\" location=\"" + id3.location +
			"]");
	}
}
