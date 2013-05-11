package org.xiph.frontend;

import flash.media.SoundLoaderContext;
import flash.net.URLRequest;

/**
 * Factory Class...
 * create OGG,MP3,WAV classes Instance.
 * @author tudurao jin
 */

class SoundFactory 
{

	public function new() 
	{
	}
	
	/**
	 * get Instance. create Instance of MP3 or WAV or OGG Class.
	 * @param	src resource URL or FilePath.
	 * @param	?slc SoundLoaderContext.
	 * @return MP3 or WAV or OGG , If discrimination does not stick = null.
	 */
	public static function getInstance( src:String , ?slc:SoundLoaderContext ) : BaseSound
	{
        var url : URLRequest = new URLRequest(src);
        if (~/\.(mp3)(\?.*)?$/i.match(src)) {
            return new MP3( url , slc );
        } else if (~/\.(ogg|oga)(\?.*)?$/i.match(src)) {
            return new OGG( url , slc );
        } else if (~/\.(wav)(\?.*)?$/i.match(src)) {
            return new WAV( url , slc );
        }
        return null;
    }
	
	public static function init():Void
	{
		// Needed for OGG Vorbis playback support.
        org.xiph.fogg.Buffer._s_init();
        org.xiph.fvorbis.FuncFloor._s_init();
        org.xiph.fvorbis.FuncMapping._s_init();
        org.xiph.fvorbis.FuncTime._s_init();
        org.xiph.fvorbis.FuncResidue._s_init();
        //flash.system.Security.allowDomain("*");
	}

	public static function main() {
		init();
    }
	
}