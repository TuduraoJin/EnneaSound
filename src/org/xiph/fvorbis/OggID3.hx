package org.xiph.fvorbis;
import org.xiph.system.Bytes;

/**
 * ...
 * OggComments is just a simple storage structure for the supported ogg comment tags.
 * 
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
 * @author 
 */

class OggID3 
{
	public var title:String = "";
	public var version:String = "";
	public var album:String = "";
	public var trackNumber:String = "";
	public var artist:String = "";
	public var performer:String = "";
	public var copyright:String = "";
	public var license:String = "";
	public var organization:String = ""
	public var description:String = "";
	public var genre:String = "";
	public var date:String = "";
	public var location:String = "";
	public var contact:String = "";
	public var isrc:String = "";
		
	public function new() 
	{
		
	}
		
	public function populateFromCommentList( commentList:Array<Bytes> ):Void
	{//populateFromCommentList
		for (var i:int = 0; i < commentList.length; i++)
		{//parse
			var prop:String;
			var value:String;
			//var isKnown:Bool = false;
			var tokens:Array<Bytes> = commentList[i].split("=");
			
			prop = cast(tokens[0],String);
			if (tokens.length > 1)
			{//save value
				value = cast(tokens[1],String);
			}//save value
			
			switch(prop)
			{//switch
				case "TITLE":
					title = value;
				break;
				
				case "VERSION":
					version = value;
				break;
				
				case "ALBUM":
					album = value;
				break;
				
				case "TRACKNUMBER":
					trackNumber = value;
				break;
				
				case "ARTIST":
					artist = value;
				break;
				
				case "PERFORMER":
					performer = value;
				break;
				
				case "COPYRIGHT":
					copyright = value;
				break;
				
				case "LICENSE":
					license = value;
				break;
				
				case "ORGANIZATION":
					organization = value;
				break;
				
				case "DESCRIPTION":
					description = value;
				break;
				
				case "GENRE":
					genre = value;
				break;
				
				case "DATE":
					date = value;
				break;
				
				case "LOCATION":
					location = value;
				break;
				
				case "CONTACT":
					contact = value;
				break;
				
				case "ISRC":
					isrc = value;
				break;
				
				default:
					this[prop] = value;
				break;
			}//switch
		}//parse
	}//populateFromCommentList
	
	
}
