# 追加したい機能 milestone

* OggDecoderのデコードスピードの向上  
現状のスピードでは約15チャンネルの多重再生までしか正常に再生できない。(動作スペックによる)  
それ以上のチャンネルを同時に再生すると、ブチブチになる。  
* FOggの懸念事項  granuleposを32ビットIntから64ビットIntに変更する。  
ogg's granulepos type is a 64 bit integer - don't use 32 int type to store granulepos in fogg!  

# 変更履歴 Changes

version 1.2.3.1
-------------------
__2014/1/23__  

* MP3Channel , WAVChannel  
一度停止されたチャンネルが再度再生された場合に、isPlayedフラグが変更されなかった不具合を修正。  
PLAY_COMPLETEされた際に、isPlayedフラグがfalseに変更されなかった不具合を修正。  
* All Class  
EventListhnersを幾つか弱参照に修正。

version 1.2.3
-------------------
* BaseSound, MP3, OGG, WAV, BinaryOGG, BinaryWAV  
add close method.

version 1.2.2
-------------------
__2013/12/4__  

* update comment. and bugfix. 
* BinaryOGG.hx , BinaryWAV.hx  
rename setBytes -> setBinary
* OggDecoder.load method  
引数を修正。 isCopyを削除  
* remove argment isCopy method.  

__2013/12/3__  

* add BinaryOGG.hx , BinaryWAV.hx , BinaryWaveSound.hx  
* SoundFactory.hx  
add getInstanceByBinary method.
* BaseSoundChannel  
getPanの値を修正。-1 -> -2

version 1.2.1
-------------------

* Floor0 , Floor1  
bugfix inverse1 method.
バグ修正。AS3にて、トップレベルクラスのパブリックスタティックメソッドを呼び出すとタイプエラーが発生する。（Std.isメソッドなど。）  
詳しい理由は分からないが、SWFをApplicationDomain.currentdomainに読み込んだ場合に発生する気がする。  
bugfix... The Error occurred when calling top level Class's public static method on AS3.(the function Std.is...)  TypeError: Error #1006: value is not a function  
I don’t know why the error occurred... It seems to occur if you want to load SWF to ApplicationDomain.currentdomain.  
Floor0でのみ発生したが、念のためFloor1にも適用した。  

version 1.2
-------------------

__2013/11/29__  

* コンパイルコマンドをアップデート。  
update compile command.  
* コンパイルにメインメソッドを含まないように修正。include文を使用してコンパイルするように変更した。  
remove main method. use macro include(package).  
* 不要なファイルを削除。  
remove files.  
org.xiph.fogg.SeekableSyncStateFast,Page.old  
org.xiph.fvorbis.AllocChain.hx , ChainingExample.hx , DecodeExample.hx , JOrbisException.hx
, fvorbis.OggID3.hx, VorbisFile.hx
org.xiph.system.AudioSink.hx , VSound.hx , VSoundDecoder.hx
* Mdct  
static inlineで初期化している配列bitrevをHaxe3に対応。（メソッド化）
* SoundFactory  
SoundFactory.initメソッドをinitOggメソッドにリネーム。  
rename init -> initOgg  
SoundFactoryからメインメソッドを削除。  

__2013/11/25__  

* Haxe3.0.1 migration bug fix.  
* update getter/setter.  
読み取り専用(getter)のプロパティについては、getterを使用せず、パブリックメソッドに修正した。  
getterのみのアクセス権を付与すると、アクセッサの実体を持ってしまうため不要なデータが増えてしまっていた。  
For read-only property (getter), do not use getter, was modified to public method.  
because unnecessary real variable of read-only accessor had increased.(since Haxe2... I didn't found it.)  
change getter/setter Classes...  
_OggDecoder_  
samples -> getSamples()  
isHeaderProcessed -> isHeaderProcessed()  
isDecoding -> isDecoding()  
isBufferOK -> isBufferOK()  
isBufferMAX -> isBufferMAX()  
_RingBuffer_  
bytesAvailable -> getBytesAvailable()  
position -> getPosition()  
_PCMRingBuffer_  
samples -> getSamples()
_BaseSoundChannel_  
isPlayed -> isPlayed()  
_BaseSound_  
baseID3 -> delete. use getID3()  
* OggID3.convertメソッドで、Oggタグが小文字の場合、正しく判定が行われていなかった問題を修正。  
toUpperCaseメソッドで大文字に変換して判定するようにした。  
In OggID3.convert method, lower case letters, Ogg tags Fixed a problem that decision has not been performed correctly.  

__2013/11/23__  

* Migration to Haxe3. before test ...

version 1.1
-------------------
__2013/6/4__

* サンプリングレートが44100未満の場合に再生速度が速くなる問題を修正。  
Fixed an issue where playback speed is faster in the case of less than 44100 sampling rate.  
* OggDecoder.  
_proc_packet_body,_proc_packet_seekPCMメソッドでPCMRingBuffer.writeのSampleMultiplierに対応。  
change Supports SampleMultiplier of PCMRingBuffer.write _proc_packet_body, in _proc_packet_seekPCM method.  
* PCMRingBuffer.  
add writePCMbyMultiplier method.  
change writePCM method. add argments inSampleMultiplier. and use writePCMbyMultiplier.  
* RingBuffer.
read メソッドでオーバーフローの長さ以上に読み込んでしまう不具合を修正。  
Fixed a bug that would read in greater than or equal to the length of overflow in the read method.  
* Channels Classes. setVolume,setPan,getVolume,getPan. if soundchannel == null.
* WaveSound.hx. on AIR. allowCodeImport SecurityError.
* OggDecoder.hx. buffer size multiplier samplerate fixed 44100.

__2013/5/22__  

* 一度Haxe3.0に対応したが、AS3で読み込んだ場合うまく動かないので、戻した。  
* OGG constructor. delete code -> new SoundLoaderContext.
* BaseSoundChannel,OGGVorbisChannel,MP3Channel,WAVChannel play method. pan initialize parameter -1 -> -2.

__2013/5/21__

* bugfix AS3に最適化。Float,Int等のbasictypeに対してnullの引数記号を使用していたので、使用しないように修正。  
Optimized for AS3. Because it was using the argument symbol of null for basictype Float, Int etc., modified so that it does not use.

version 1.0
-------------------
__2013/5/15__  

* update OggVorbisChannel. 再生中にplayメソッドを呼んだ場合、一度停止してから再生を開始するようにし修正。
* bugfix OGGVorbisChannel.
* OGG.playメソッドでインスタンスを生成した直後に、OggVorbisChannel.stopを呼ぶと、stopしたにもかかわらず、メソッド終了後、OggDecoderでTimer.deleyによりdecodeメソッドが呼び出される。  これにより、バッファが蓄積され、次回playメソッドを呼び出した時、音楽の再生が開始されない不具合。  
* OggDecoder.isDecodingプロパティとOggDecoder.processStopメソッドを追加した。  これにより、OggVorbisChannel.stopが呼び出されたら、デコードを停止するようにした。  
* OggVorbisChannelにてシーク処理の後、バッファが溜まっている場合でも、デコードを行なってしまう不具合。
* OggDecoder.isBufferOK,isBufferMaxプロパティを追加した。
* OGGVorbisChannel.playSoundメソッドを追加した。これにより、シーク完了後バッファの蓄積状態を確認して、蓄積していれば即座に再生を開始するように修正した。

__2013/5/11__  

update Comment. Fix v1.0

__2013/5/10__

* BaseSound Class.  
* コンストラクタにSoundLoaderContextを追加  
Add SoundLoaderContext constructor argument
* フィールドにpulic SoundLoaderContextを追加  
Add SoundLoaderContext in Field 
* フィールド名を変更　_id3 -> baseID3  
Change FieldName _id3 -> baseID3
* WAV,MP3,OGG Class.
* コンストラクタの引数にSoundLoaderContextを追加。  
Add SoundLoaderContext constructor argument
* OGGVorbisChannel Class.
* コンストラクタ引数のSoundLoaderContextをbuffertime:Intに変更  
Change SoundLoaderContext to buffertime:Int of constructor argument
* setBufferSizeメソッドを実装  
Add setBufferSize method.
* SoundFactory
* WAV,MP3,OGGのコンストラクタの変更に伴い、getInstanceメソッドに引数にSoundLoaderContextを追加。  
With the change of the constructor, MP3, OGG WAV, added to SoundLoaderContext argument to getInstance method.
* OggDecoder Class.
* setBufferSizeメソッドを追加  
Add setBufferSize method.
* decodeメソッドの処理をTimerを使用するように変更。  
Changed to use the Timer processing decode method.

__2013/5/9__  

* update RingBuffer.hx. bugFix= length setter func. In a state where data is stored, when the length is changed, some data loss.  
* update OggDecoder.hx, add setBufferSize function.
* update RingBuffer.hx, rename getter/setter GreenLine,RedLine -> greenLine,redLine.

__2013/5/8__

* update OGG,MP3,WAV  
bugfix. when loadComplete , removeEventListener.

__2013/5/6__  

* update OGGVorbisChannel.hx , WAVChannel.hx , MP3Channel.hx , BaseSoundChannel.hx
* add play method. dispose method.
* bugfix.  if flash.media.Sound.play return null.
* OggDecoder.hx  
add bufferClear method. dispose method.  
add dispose method.  

version 0.9
-------------------
__2013/5/2__  

* Fix 0.9　コメント整理。

__2013/5/1__  

* OggDecoderにRingBufferを実装。

__2013/4/30__  

* OggVorbisChannelを作成。OggDecoderを実装。シーク、ループを実装。
* OggDemuxerを調整。seekを実装。

__2013/4/25__  

* OggDecoderを作成。

__2013/4/21__  

* OggDemuxerを作成。

__2013/4/18__  

* SeekableSyncStateを作成。

__2013/4/5__  

* WAV,MP3,OGGの発行イベントをflashネイティブのものに変更。

__2013/4/3__  

* OGGChannel の s.playにSoundTransFormを渡すように修正。
* getPan,getVolume,getPosition,setPan,setVolumeが動作するように修正。

__2013/4/2__  

* Soundクラスのコンストラクタを追加
* add getURL() method to Sound,OGG,WAV,MP3. URL取得用メソッドを追加。
* rename EventListhners in OGG,WAV,MP3.　example: soundComplete -> onComplete. イベントリスナーの名前をonXXXに統一。
* change varables name in SoundEvent. LOADED -> LOAD_COMPLETE.　変数名の変更。
