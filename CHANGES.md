# 追加したい機能 milestone

-OggDecoderのデコードスピードの向上
　現状のスピードでは約15チャンネルの多重再生までしか正常に再生できない。(動作スペックによる)
　それ以上のチャンネルを同時に再生すると、ブチブチになる。
  誰かやってくれないかな…。

-URL指定ではなくバイトデータから直接再生


# 変更履歴 Changes

---2013/11/29
-コンパイルコマンドをアップデート。
update compile command.

-コンパイルにメインメソッドを含まないように修正。include文を使用してコンパイルするように変更した。
remove main method. use macro include(package).

-不要なファイルを削除。
remove files.
 org.xiph.fogg
  SeekableSyncStateFast
  Page.old
 org.xiph.fvorbis
  AllocChain.hx
  ChainingExample.hx
  DecodeExample.hx
  JOrbisException.hx
  fvorbis.OggID3.hx
  VorbisFile.hx
 org.xiph.system
  AudioSink.hx
  VSound.hx
  VSoundDecoder.hx

-bugfix.
--Mdct
 static inlineで初期化している配列bitrevをHaxe3に対応。（メソッド化）

-change
--SoundFactory
 SoundFactory.initメソッドをinitOggメソッドにリネーム。
 rename init -> initOgg
 SoundFactoryからメインメソッドを削除。

---2013/11/25
-Haxe3.0.1 migration bug fix.
-update getter/setter.
読み取り専用(getter)のプロパティについては、getterを使用せず、パブリックメソッドに修正した。
getterのみのアクセス権を付与すると、アクセッサの実体を持ってしまうため不要なデータが増えてしまっていた。
For read-only property (getter), do not use getter, was modified to public method.
because unnecessary real variable of read-only accessor had increased.(since Haxe2... I didn't found it.)

--OggDecoder
 samples -> getSamples()
 isHeaderProcessed -> isHeaderProcessed()
 isDecoding -> isDecoding()
 isBufferOK -> isBufferOK()
 isBufferMAX -> isBufferMAX()

--RingBuffer
 bytesAvailable -> getBytesAvailable()
 position -> getPosition()

--PCMRingBuffer
 samples -> getSamples()

--BaseSoundChannel
 isPlayed -> isPlayed()

--BaseSound
 baseID3 -> delete. use getID3()

-bug fix.
--OggID3.convertメソッドで、Oggタグが小文字の場合、正しく判定が行われていなかった問題を修正。
toUpperCaseメソッドで大文字に変換して判定するようにした。
In OggID3.convert method, lower case letters, Ogg tags Fixed a problem that decision has not been performed correctly.

---2013/11/23
Migration to Haxe3.
before test...

---2013/6/4
Fixed an issue where playback speed is faster in the case of less than 44100 sampling rate.
サンプリングレートが44100未満の場合に再生速度が速くなる問題を修正。

-OggDecoder.
change Supports SampleMultiplier of PCMRingBuffer.write _proc_packet_body, in _proc_packet_seekPCM method.
_proc_packet_body,_proc_packet_seekPCMメソッドでPCMRingBuffer.writeのSampleMultiplierに対応。

-PCMRingBuffer.
add writePCMbyMultiplier method.
change writePCM method. add argments inSampleMultiplier. and use writePCMbyMultiplier.

-RingBuffer.
Fixed a bug that would read in greater than or equal to the length of overflow in the read method.
read メソッドでオーバーフローの長さ以上に読み込んでしまう不具合を修正。

Channels. setVolume,setPan,getVolume,getPan. if soundchannel == null.

WaveSound.hx. on AIR. allowCodeImport SecurityError.

OggDecoder.hx. buffer size multiplier samplerate fixed 44100.

---2013/5/22
一度Haxe3.0に対応したが、AS3で読み込んだ場合うまく動かないので、戻した。
bugfix. 
OGG constructor. delete code -> new SoundLoaderContext.
BaseSoundChannel,OGGVorbisChannel,MP3Channel,WAVChannel play method. pan initialize parameter -1 -> -2.

---2013/5/21
bugfix AS3に最適化。Float,Int等のbasictypeに対してnullの引数記号を使用していたので、使用しないように修正。
Optimized for AS3. Because it was using the argument symbol of null for basictype Float, Int etc., modified so that it does not use.

---2013/5/15
update OggVorbisChannel. 再生中にplayメソッドを呼んだ場合、一度停止してから再生を開始するようにし修正。
bugfix OGGVorbisChannel.
 OGG.playメソッドでインスタンスを生成した直後に、OggVorbisChannel.stopを呼ぶと、
 stopしたにもかかわらず、メソッド終了後、OggDecoderでTimer.deleyによりdecodeメソッドが呼び出される。
 これにより、バッファが蓄積され、次回playメソッドを呼び出した時、音楽の再生が開始されない不具合。
 OggDecoder.isDecodingプロパティとOggDecoder.processStopメソッドを追加した。
 これにより、OggVorbisChannel.stopが呼び出されたら、デコードを停止するようにした。
 OggVorbisChannelにてシーク処理の後、バッファが溜まっている場合でも、デコードを行なってしまう不具合。
 OggDecoder.isBufferOK,isBufferMaxプロパティを追加した。
 OGGVorbisChannel.playSoundメソッドを追加した。
 これにより、シーク完了後バッファの蓄積状態を確認して、蓄積していれば即座に再生を開始するように修正した。

---2013/5/11
update Comment. Fix v1.0

---2013/5/10
-BaseSound Class.
コンストラクタにSoundLoaderContextを追加
Add SoundLoaderContext constructor argument
フィールドにpulic SoundLoaderContextを追加
Add SoundLoaderContext in Field 
フィールド名を変更　_id3 -> baseID3
Change FieldName _id3 -> baseID3

-WAV,MP3,OGG Class.
コンストラクタの引数にSoundLoaderContextを追加。
Add SoundLoaderContext constructor argument

-OGGVorbisChannel Class.
コンストラクタ引数のSoundLoaderContextをbuffertime:Intに変更
Change SoundLoaderContext to buffertime:Int of constructor argument
setBufferSizeメソッドを実装
Add setBufferSize method.

-SoundFactory
WAV,MP3,OGGのコンストラクタの変更に伴い、getInstanceメソッドに引数にSoundLoaderContextを追加。
With the change of the constructor, MP3, OGG WAV, added to SoundLoaderContext argument to getInstance method.

-OggDecoder Class.
setBufferSizeメソッドを追加
Add setBufferSize method.
decodeメソッドの処理をTimerを使用するように変更。
Changed to use the Timer processing decode method.

-EnneaSoundManager Class.
getID3メソッドを実装
Add getID3 method.
setBufferTimeOfOGGを実装
Add setBufferTimeOfOGG method.
playingChannelsゲッターを実装
Add playingChannels getter.

---2013/5/9
update RingBuffer.hx. bugFix= length setter func. In a state where data is stored, when the length is changed, some data loss.
update OggDecoder.hx, add setBufferSize function.
update RingBuffer.hx, rename getter/setter GreenLine,RedLine -> greenLine,redLine.

---2013/5/8
update OGG,MP3,WAV. bugfix = when loadComplete , removeEventListener.

---2013/5/6
update OGGVorbisChannel.hx , WAVChannel.hx , MP3Channel.hx , BaseSoundChannel.hx
 add play method. dispose method.
 bugfix = if flash.media.Sound.play return null.
update OggDecoder.hx = add bufferClear method. dispose method.
update OggDemuxer.hx = add dispose method.

---2013/5/2
Fix 0.9　コメント整理。

----2013/5/1
OggDecoderにRingBufferを実装。

---2013/4/30
OggVorbisChannelを作成。OggDecoderを実装。シーク、ループを実装。
OggDemuxerを調整。seekを実装。

---2013/4/25
OggDecoderを作成。

---2013/4/21
OggDemuxerを作成。

---2013/4/18
SeekableSyncStateを作成。

---2013/4/5
-WAV,MP3,OGGの発行イベントをflashネイティブのものに変更。

---2013/4/3
-OGGChannel の s.playにSoundTransFormを渡すように修正。
-getPan,getVolume,getPosition,setPan,setVolumeが動作するように修正。

---2013/4/2
-Soundクラスのコンストラクタを追加
-add getURL() method to Sound,OGG,WAV,MP3. URL取得用メソッドを追加。
-rename EventListhners in OGG,WAV,MP3.　example: soundComplete -> onComplete. イベントリスナーの名前をon???に統一。
-change varables name in SoundEvent. LOADED -> LOAD_COMPLETE.　変数名の変更。
