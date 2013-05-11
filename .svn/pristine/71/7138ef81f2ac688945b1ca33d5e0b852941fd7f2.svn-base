//===========================//
//            仕様           //
//===========================//
・change main method (entry point) in SoundFactory Class.　メインメソッドは、SoundFactory クラスに実装されている。
  ※SWFを読み込んだクラスで、ApplicationDomain.currentDomain配下に属する場合、クラス名がMainクラスであると、メインメソッドが読み込まれた時点で自動的に実行されてしまう。それを回避するため、クラス名をMainから変更した。
・OGG,MP3,WAVクラスを使用して音楽を操作する。
・ファクトリメソッドはSoundFactoryに実装。
・OGG、OGGChannelクラスはFVorbisライブラリを使用している。リビジョン58を使用。
 The class was created using the existing implementation found here:
     https://launchpad.net/fogg  
  Revision 58 of the FOgg repo hosted at the link above was used as a base.

//===========================//
//    追加したい機能(milestone)　//
//===========================//
・AAC(m4a)に対応。 support AAC.
 NetStreamクラスを使用すればできるはず。@see flash.net.NetStream
・OggDecoderのデコードスピードの向上
　現状のスピードでは約15チャンネルの多重再生までしか正常に再生できない。(動作スペックによる)
　それ以上のチャンネルを同時に再生すると、ブチブチになる。

//===========================//
//    変更履歴　覚書(Changes) 　//
//===========================//
2013/5/8---
update OGG,MP3,WAV. bugfix = when loadComplete , removeEventListener.
2013/5/6---
update OGGVorbisChannel.hx , WAVChannel.hx , MP3Channel.hx , BaseSoundChannel.hx
 add play method. dispose method.
 bugfix = if flash.media.Sound.play return null.
update OggDecoder.hx = add bufferClear method. dispose method.
update OggDemuxer.hx = add dispose method.
2013/5/2---
Fix 0.9　コメント整理。
2013/5/1---
OggDecoderにRingBufferを実装。
2013/4/30---
OggVorbisChannelを作成。OggDecoderを実装。シーク、ループを実装。
OggDemuxerを調整。seekを実装。
2013/4/25---
OggDecoderを作成。
2013/4/21---
OggDemuxerを作成。
2013/4/18---
SeekableSyncStateを作成。
2013/4/5---
・WAV,MP3,OGGの発行イベントをflashネイティブのものに変更。
2013/4/3---
・OGGChannel の s.playにSoundTransFormを渡すように修正。
・getPan,getVolume,getPosition,setPan,setVolumeが動作するように修正。
2013/4/2---
・Soundクラスのコンストラクタを追加
・add getURL() method to Sound,OGG,WAV,MP3. URL取得用メソッドを追加。
・rename EventListhners in OGG,WAV,MP3.　example: soundComplete -> onComplete. イベントリスナーの名前をon???に統一。
・change varables name in SoundEvent. LOADED -> LOAD_COMPLETE.　変数名の変更。
