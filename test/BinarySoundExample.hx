package ;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLRequest;
import flash.net.URLStream;
import flash.utils.ByteArray;
import org.xiph.frontend.BaseSound;
import org.xiph.frontend.BaseSoundChannel;
import org.xiph.frontend.SoundFactory;

/**
 * BinarySound Class test...
 * @author Tudurao Jin
 */
class BinarySoundExample
{
	private var _ul:URLStream;
	private var _req : URLRequest;
	private var _data : ByteArray;
	private var _s:BaseSound;
	private var _ch:BaseSoundChannel;

	public function new() 
	{
		_ul = new URLStream();
	}
	
	public function load( url:URLRequest ):Void
	{
		 _req = url;
		 
		//load file
        _ul.addEventListener(Event.COMPLETE, onComplete);
		_ul.addEventListener(Event.OPEN, onOpen);
		_ul.load(_req);
		
	}
	private function onOpen( e:Event ):Void
	{
        this._data = new ByteArray();
    }
	
	private function onComplete(e:Event):Void
	{
		_ul.removeEventListener(Event.COMPLETE, onComplete);
		_ul.removeEventListener(Event.OPEN, onOpen);
		
		//read binary
		this._ul.readBytes( this._data , 0 , _ul.bytesAvailable );
		
		// create Instance by Binary
		var type:String = "";
		if (~/\.(ogg|oga)(\?.*)?$/i.match(_req.url)) {
			type = SoundFactory.SOUNDTYPE_OGG;
		} else if (~/\.(wav)(\?.*)?$/i.match(_req.url)) {
			type = SoundFactory.SOUNDTYPE_WAV;
		}
		
		SoundFactory.initOgg();
		_s = SoundFactory.getInstanceByBinary( this._data , type );
		_s.addEventListener(Event.COMPLETE , soundComplete );
    }
	
	private function soundComplete(e:Event):Void 
    {
		trace("[BinarySoundExample]");
		_s.removeEventListener(Event.COMPLETE , soundComplete );
		_ch = _s.play(0, 0.5, 0); //play sound.
    }
	
}