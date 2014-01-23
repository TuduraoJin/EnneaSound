
# EnneaSound

EnneaSoundは、Flash上でOggVorbisを再生できるようにするライブラリです。
*EnneaSound* is a library that allows you to play *OggVoribis* on Flash.

このライブラリはFlash用Haxeで書かれています。Haxe 3.0.1でビルドしています。
This is written in Haxe for Flash. Build by Haxe 3.0.1.

OggVorbisのデコード処理はFOggを元に作成しています。
Decoding OggVorbis are created based on the [FOgg](https://launchpad.net/fogg).

EnneaSoundではOggVorbisのオフセット指定再生、ループ再生に対応しています。また多重レイヤー再生（複数のOggVorbisファイルの同時再生）にも対応しています。
supported playback of the specified offset, loop playback.
supported multi-layer playback.  (playback of multiple files OggVorbis)

OggVorbisの他に、FlashネイティブのSoundクラスを使用したMP3の再生、WAVの再生もサポートしています。
In addition to the OggVorbis, I support MP3 playback using the Sound class of native Flash, and playback of WAV.

## License

本ライブラリはLGPLライセンスです。これは元にしたFOggがLGPLライセンスであるためです。
This library is released under the LGPL license. because FOgg that the source is the LGPL license. 
see LICENSE.md file for full legal text.


## Classes

主にフロントエンドで使用するクラスは'org.xiph.frontend'パッケージに入っています。
The Class to be used in the front-end contains in the 'org.xiph.frontend' package.

OggVorbisのデコード関連のクラスは'org.xiph.system' , 'org.xiph.fogg.foggy' パッケージに入っています。
The OggVorbis decode-related Class contains in the 'org.xiph.system' , 'org.xiph.fogg.foggy' package.

さらに低レベル層の処理をしているクラスは'org.xiph.fvorbis' , 'org.xiph.fogg.fogg' , 'org.xiph.ftremor' パッケージに入っています。
The processing of more low-level layer Classes contains in the 'org.xiph.fvorbis' , 'org.xiph.fogg.fogg' , 'org.xiph.ftremor' package.

以下に主なクラスの紹介をします。

### BaseSound
各種サウンドクラスのスーパークラスです。OGG,MP3,WAVはこのクラスを継承しているので、BaseSoundクラスを通して制御出来ます。

### BaseSoundChannel
各種サウンドチャンネルクラスのスーパークラスです。

### OGG
OggVorbisをロードするクラスです。playメソッドでOGGVorbisChannelクラスを生成します。

### OGGVorbisChannel
OggVorbisの再生を制御します。内部ではOggDecoderクラスとflash.media.SoundクラスのSAMPLE_DATA_EVENTを使用しています。
OggDecoderがデコードしたPCMデータを動的に再生しています。

### OggDecoder
OggVorbisファイルをデコードし、PCMを取り出します。
OggVorbisChannel内部で使用しています。
もし、自分が作ったクラスでOggVorbisを再生したい場合は、このクラスを参考にしてください。

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
また、Ogg関連のstaticなデータを初期化するinitOggメソッドがあります。このメソッドはOGGクラスを生成する前に実行してください。


## 注意事項 attension
### use SWC on AS3.
もしAS3にSWCをインポートして使用する場合、最初にHaxeシステムを初期化する必要があります。
最初に以下のようにコードを記述してください。
If you want to import and use the SWC to AS3, you need to initialize the Haxe system first.
Please write the code to the following first.

example:

	var mc:MovieClip = new MovieClip();
	stage.addChild(mc);
	haxe.initSwc(mc);

詳しくは以下を参照してください。
see more...
[Using/Exporting SWC Files](http://haxe.org/manual/swc).

### Initalize Ogg's static variables.
Oggを使用する場合、最初にstaticなデータを初期化する必要があります。SoundFactoryクラスのinitOggメソッドを使用してください。
If you want to use Ogg, you need to initialize the static data first. Please use the method of initOgg SoundFactory class.

example:

	SoundFactory.initOgg();


## サンプルコード code examples

	static var s:BaseSound;
	static var ch:BaseSoundChannel;
	
	static function main() 
	{
		var stage = Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		// entry point

		var testSound:String = "../resource/interlude1.ogg"; //any ogg sound path.
		SoundFactory.initOgg(); //static Initialize Ogg
		s = SoundFactory.getInstance(testSound);
    	s.addEventListener(Event.COMPLETE , compHandler );
	}
	
	static private function compHandler(e:Event):Void 
	{
		ch = s.play(0, 0.5, 0); //play sound.
	}

## 使用するときの考慮するべき点
### OggVorbisファイルのストリーミング再生はできません。Oggクラスで一旦ファイルをすべて読み込んでから再生しています。
