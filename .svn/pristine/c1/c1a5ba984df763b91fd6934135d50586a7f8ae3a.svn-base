package org.xiph.system;

import flash.Vector;
import org.xiph.fogg.Packet;
import org.xiph.fvorbis.Block;
import org.xiph.fvorbis.Comment;
import org.xiph.fvorbis.DspState;
import org.xiph.fvorbis.Info;


class VSoundDecoder {
    var _packets : Int;
    var vi : Info;
    var vc : Comment;
    var vd : DspState;
    var vb : Block;

    var _pcm : Array<Array<Vector<Float>>>;
    var _index : Vector<Int>;

    public var dmx(default, null) : TheRightWayDemuxer;

    public var decoded_cb(null, default) :
        Array<Vector<Float>> -> Vector<Int> -> Int -> Void;

    function _proc_packet_head(p : Packet, sn : Int) : DemuxerStatus {
		trace("[VSoundDecoder] <_proc_packet_head> Packet No." + Std.string(p.packetno));
		switch( p.packetno )
		{
			case 0:
				vi.init();
				vc.init();
				if (vi.synthesis_headerin(vc, p) < 0) {
					// not vorbis - clean up and ignore
					vc.clear();
					vi.clear();
					return dmx_stop;
				} else {
					// vorbis - detach this cb and attach the main decoding cb
					// to the specific serialno
				}
	        case 1:            vi.synthesis_headerin(vc, p);
			case 2:
				vi.synthesis_headerin(vc, p);
				vd.synthesis_init(vi);
				vb.init(vd);
				_pcm = [null];
				_index = new Vector(vi.channels, true);
				
				dmx.remove_packet_cb(sn);
				dmx.set_packet_cb(sn, _proc_packet_body);
		}

        //_packets++;
        return dmx_ok;
    }
	
	function _proc_packet_body(p : Packet, sn : Int) : DemuxerStatus 
	{
		var samples : Int;

		if (vb.synthesis(p) == 0) {
			vd.synthesis_blockin(vb);
		}
		
		//samples = vd.synthesis_pcmout(_pcm, _index);
		//if (decoded_cb != null && samples > 0 ) 
		//{
			//decoded_cb(_pcm[0], _index, samples);
			//vd.synthesis_read(samples);
		//}
		
		while ((samples = vd.synthesis_pcmout(_pcm, _index)) > 0) 
		{
			trace( samples );
			if (decoded_cb != null) {	decoded_cb(_pcm[0], _index, samples);		}
			vd.synthesis_read(samples);
		}
		
        _packets++;
		
        return dmx_ok;
	}

    public function new() {
        dmx = new TheRightWayDemuxer();

        vi = new Info();
        vc = new Comment();
        vd = new DspState();
        vb = new Block(vd);
        _packets = 0;
        dmx.set_packet_cb(-1, _proc_packet_head);
    }
}
