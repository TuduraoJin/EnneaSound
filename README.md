
# EnneaSound

EnneaSoundは、Flash上でOggVorbisを再生できるようにするライブラリです。
*EnneaSound* is a library that allows you to play *OggVoribis* on Flash.

このライブラリはFlash用Haxeで書かれています。Haxe 2.10でビルドしています。
This is written in Haxe for Flash. Build by Haxe 2.10.

OggVorbisのデコード処理はFOggを元に作成しています。
Decoding OggVorbis are created based on the [FOgg](https://launchpad.net/fogg).

OggVorbisの他に、FlashネイティブのSoundクラスを使用したMP3の再生、WAVの再生もサポートしています。
In addition to the OggVorbis, I support MP3 playback using the Sound class of native Flash, and playback of WAV.


## License

本ライブラリはLGPLライセンスです。これは元にしたFOggがLGPLライセンスであるためです。
This library is LGPL license. This is because FOgg that the source is a LGPL license.


## Classes
主に使用するクラスは'org.xiph.frontend'パッケージに入っています。
I am in the 'org.xiph.frontend' package class to be used primarily.

### BaseSound
各種サウンドクラスのスーパークラスです。OGG,MP3,WAVはこのクラスを継承しているので、BaseSoundクラスを通して制御出来ます。

### BaseSoundChannel
各種サウンドチャンネルクラスのスーパークラスです。


### OGG
OggVorbisをロードするクラスです。playメソッドでOGGVorbisChannelクラスを生成します。

### OGGVorbisChannel
OggVorbisの再生を制御します。内部ではOggDecoderクラスとflash.media.SoundクラスのSAMPLE_DATA_EVENTを使用しています。
OggDecoderがデコードしたPCMデータを動的に再生しています。

### MP3
flash.media.Soundクラスを使用して、MP3をロードするクラスです。

### MP3Channel
flash.media.SoundChannelを使用してMP3の再生を制御します。

### WAV
WAVをロードするクラスです。

### WAVChannel
WAVの再生を制御するクラスです。

### SoundFactory
各種サウンドクラスのインスタンスを生成するクラスです。getInstanceメソッドにファイルパスを渡すことで
拡張子を判別し、各種サウンドクラスのインスタンスを生成します。
また、Ogg関連のstaticなデータを初期化するinitメソッドがあります。このメソッドはOGGクラスを生成する前に実行してください。



## examples

	static var s:BaseSound;
	static var ch:BaseSoundChannel;
	
	static function main() 
	{
		var stage = Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		// entry point

		var testSound:String = "../resource/interlude1.ogg"; //any ogg sound path.
		SoundFactory.init(); //static Initialize Ogg
		s = SoundFactory.getInstance(testSound);
    	s.addEventListener(Event.COMPLETE , compHandler );
	}
	
	static private function compHandler(e:Event):Void 
	{
		ch = s.play(0, 0.5, 0); //play sound.
	}

