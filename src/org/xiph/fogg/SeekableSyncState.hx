package org.xiph.fogg;

import org.xiph.common.System;

/**
 * SyncState with seek function...
 * @author tudurao jin
 */

class SeekableSyncState extends SyncState
{
	/**
	 * Constructor
	 */
	public function new() 
	{
		super();
	}
	
	/**
	 * move to head.
	 */
	public function pageseek_head():Void
	{
		this.returned = 0;
	}
	
	/**
	 * move to tail.(to fill)
	 */
	public function pageseek_tail():Void
	{
		this.returned = fill;
	}
	
	/**
	 * seek to body page top. ボディの先頭ページに移動する。
	 * @return Position moved. 1 = success. 0 = no move. -1 = failed.
	 */
	public function pageseek_body_top():Int
	{
		var og:Page = new Page();
		var result:Int = 0;
		var prev_returned:Int = 0;
		
		this.returned = 0; //move top
		this.unsynced = 0;
		this.headerbytes = 0;
		this.bodybytes = 0;
		
		while (true)
		{
            result = pageout(og);
            if (result > 0) {
				if ( og.granulepos() > 0 )
				{
					//found body top.
					this.returned = prev_returned;
					return 1;
				}
            }else if (result == 0) {
				if ( prev_returned == this.returned ) {
					return 0;
				}
            }else if (unsynced == 0) {
                unsynced = 1;
                return -1;
            }
			prev_returned = this.returned;
        };
	}
	
	/**
	 * seek to body page end. 末尾ページに移動
	 * @return Value greater than 0 = success. 
	 */
	public function pageseek_body_end():Int
	{
		var og:Page = new Page();
		var result:Int = 0;
		
		this.pageseek_tail(); //末尾に移動
		result = this.pageseek_back( og );
		return -1 * result;
	}
	
	
	
	/**
	 * page out body top page. 先頭ボディページを得る。
	 * @param	og
	 * @return Value greater than 0 = success. -1 = failed.
	 */
	public function pageout_body_top( og:Page ):Int
	{
		var result:Int = 0;
		result = this.pageseek_body_top();
        if ( result <= 0 )
		{
			return -1;
		}
		result = pageout(og);
		if ( result < 0 )
		{
			return -1;
		}
		return result;
	}
	
	
	/**
	 * page out body end page. 
	 * @param	og
	 * @return Value greater than 0 = success. -1 = failed.
	 */
	public function pageout_body_end( og:Page ):Int
	{
		var result:Int = 0;
		result = this.pageseek_body_end();
		if ( result < 0 )
		{
			return -1;
		}
		result = this.pageout( og );
		if ( result <= 0 )
		{
			return -1;
		}
		return result;
	}
	
	
	/**
	 * page seek go prev page. 後ろ向きにシークする。現在位置のページを取り出した後に移動する。
	 * check: If, when outputting the first page, the return value is 0. もし、先頭ページを取り出し、データの先頭まで移動した場合、0を返す。
	 * @param	og　Parameters for data storage.
	 * @return position moved. Value Greater than 0 = success output pagedata. 0 = no moved. didn't output pagedata. Value less than 0 = failed, didn't output pagedata
	 */
	public function pageseek_back( og:Page ):Int
	{
        var page : Int = returned;
        var next : Int;
        var bytes : Int = fill - returned;

        if (headerbytes == 0) {
            var _headerbytes : Int;
            var i : Int;
            if ((((data[page] != 'O'.charCodeAt(0)) || (data[page + 1] != 'g'.charCodeAt(0))) || (data[page + 2] != 'g'.charCodeAt(0))) || (data[page + 3] != 'S'.charCodeAt(0))) {
                headerbytes = 0;
                bodybytes = 0;
				return this.pageseek_back_helper();
            };
            _headerbytes = ((data[page + 26] & 0xff) + 27);
            if (bytes < _headerbytes) {
                return 0;
            };

            i = 0;
            while (i < (data[page + 26] & 0xff)) {
                bodybytes += (data[(page + 27) + i] & 0xff);
                i++;
            };
            headerbytes = _headerbytes;
        };

        if ((bodybytes + headerbytes) > bytes) {
            return 0;
        };

        // synchronized (chksum) ...;
        {
            System.bytescopy(data, page + 22, chksum, 0, 4);
            data[page + 22] = 0;
            data[page + 23] = 0;
            data[page + 24] = 0;
            data[page + 25] = 0;
            var log : Page = _pageseek;
            log.header_base = data;
            log.header = page;
            log.header_len = headerbytes;
            log.body_base = data;
            log.body = (page + headerbytes);
            log.body_len = bodybytes;
            log.checksum();
            if ((((chksum[0] != data[page + 22]) || (chksum[1] != data[page + 23])) || (chksum[2] != data[page + 24])) || (chksum[3] != data[page + 25])) {
                System.bytescopy(chksum, 0, data, page + 22, 4);
                headerbytes = 0;
                bodybytes = 0;
				return this.pageseek_back_helper();
            };
        };
        page = returned;
        if (og != null) {
            og.header_base = data;
            og.header = page;
            og.header_len = headerbytes;
            og.body_base = data;
            og.body = (page + headerbytes);
            og.body_len = bodybytes;
        };
        unsynced = 0;
        bytes = (headerbytes + bodybytes);
        headerbytes = 0;
        bodybytes = 0;
		
		var ret:Int = this.pageseek_back_helper();
		if ( ret == 0 )
		{
			trace("[SeekableSyncState] <pageseek_back> reach to head.");
			return 0;
		}
        return bytes;
	}
	
	/**
	 * Process of moving back seek.
	 * @return position moved.
	 */
	private function pageseek_back_helper():Int
	{
		if ( returned == 0 ) {
			return 0;
		}
		var next:Int = returned;
		var page:Int = returned;
		
		// for-while;
		var ii : Int = 0;
		while ( 0 < (page - 1) - ii ) {
			if (data[(page - 1) - ii] == 'O'.charCodeAt(0) && (data[page - ii] == 'g'.charCodeAt(0)) && (data[page - ii + 1] == 'g'.charCodeAt(0)) && (data[page - ii + 2] == 'S'.charCodeAt(0))) {
				next = ((page - 1) - ii);
				break;
			};
			ii++;
		};
		if (next == returned) {
			next = 0;
		};
		returned = next;
		return -( page - next );
	}
	
	/**
	 * pageout and back seek.
	 * @param	og　Parameters for data storage.
	 * @return 1 = success output pagedata. 0 = no moved. didn't output pagedata. -1 = failed, didn't output pagedata
	 */
	public function pageout_back( og:Page ):Int
	{
		while (true) {
            var ret : Int = pageseek_back(og);
            if (ret > 0) {
                return 1;
            };
            if (ret == 0) {
				if ( 0 < unsynced )
				{
					trace("[SeekableSyncState] <pageout_back> no move. unsynced.");
					return -1;
				}
                return 0;
            };
            if (unsynced == 0) {
                unsynced = 1;
				trace("[SeekableSyncState] <pageout_back> unsynced. more seek back.");
                //return -1;
            };
        };
	}
	
	//targetPage_seek mode
	private static inline var PAGESEEK_TOP_FORWARD:Int 		= 0;
	private static inline var PAGESEEK_END_BACKWARD:Int 	= 1;
	private static inline var PAGESEEK_NOWPOS_FORWARD:Int	= 2;
	private static inline var PAGESEEK_NOWPOS_BACKWARD:Int 	= 3;
	private static inline var BACKSEEK_COEFFICIENT:Int = 8; //Seek back about 8 times slower than usual seek. The coefficients used for the determination of the seek direction.　バックシークが通常シークより約8倍遅い。シーク方向の判断のため係数を用いる。
															//Boundary seek back and seek the same speed can be calculated as follows. バックシークとシークが同じ速度になる境界は以下の式で求められる。
															//　( eos_page(pageNo) - targetpage(pageNo) ) * BACKSEEK_COEFFICIENT <= targetpage(pageNo)
	//private static inline var BACKSEEK_COEFFICIENT:Float = 7.8; //Exact value.厳密な係数

	/**
	 * Seek to any page. 任意のページに移動する。
	 * @param	t_PageNo target Page Number.
	 * @return 1 = success. -1 = failed.
	 */
	public function pageseek_targetPage( t_PageNo:Int ):Int
	{
		var og:Page = new Page();
		var eosPageNo:Int = 0;
		var result:Int = 0;
		var now_returned:Int = returned;
		//get end page number. 末尾ページのページ番号を求める
		result = this.pageout_body_end( og );
		if ( result < 0 ){			return -1;		}
		eosPageNo = og.pageno();
		
		//Page number of specified greater than the last page. 指定のページ番号が末尾ページより大きいか
		if ( eosPageNo < t_PageNo )
		{
			trace("[SeekableSyncState] <pageseek_targetPage> out of page number. pageNo=" + Std.string(t_PageNo) );
			return -1;
		}
		
		//get now page number. 現在のページ位置
		this.returned = now_returned;
		var nowPageNo:Int = -1;
		result = this.pageout(og);
		if (result < 0)
		{
			return -1;
		}
		nowPageNo = og.pageno();
		this.returned = now_returned;
		
		//Calculate the difference between the page number. ページナンバーから各位置に対する差を求める。
		var distTop:Int = t_PageNo;
		var distEnd:Int = (eosPageNo - t_PageNo) * BACKSEEK_COEFFICIENT;
		//var distEnd:Int = Std.int( cast((eosPageNo - targetPageNo),Float) * BACKSEEK_COEFFICIENT ); // for Coefficient = 7.8
		var distNow:Int = nowPageNo - t_PageNo;
		if ( distNow < 0 ) {	distNow *= -1;	}
		
		//I determine the seek method from the difference between the page number..ページの差からシーク方法を決定する。
		var seekmode:Int = PAGESEEK_TOP_FORWARD;
		if ( distTop <= distNow && distNow < distEnd ) {
			//top is fast
			seekmode = PAGESEEK_TOP_FORWARD;
		}else if ( distEnd < distNow && distNow <= distTop ) {
			//end is fast
			seekmode = PAGESEEK_END_BACKWARD;
		}else {
			//now is fast
			seekmode = PAGESEEK_NOWPOS_FORWARD; //seek forward
			if ( t_PageNo < nowPageNo )
			{
				seekmode = PAGESEEK_NOWPOS_BACKWARD; //seek back
			}
		}
		
		//do seek. シークする。
		result = this.pageseek_targetPage_helper( t_PageNo , seekmode );
		if ( result < 0 ){	 return -1;		}
		
		return 1;
	}
	
	/**
	 * Process of moving seek any page. Seek in the way that you selected. 任意のページへ移動する処理。指定した方法でシークする。
	 * @param	t_PageNo
	 * @param	seekmode
	 * @return 1 = success. -1 = failed.
	 */
	private function pageseek_targetPage_helper( t_PageNo:Int , seekmode:Int ):Int
	{
		trace("[SeekableSyncState] <pageseek_targetPage_helper> targetPgNo=" + Std.string(t_PageNo) + " seekmode="+ Std.string(seekmode) );
		var og:Page = new Page();
		var result:Int = 0;
		var prev_returned:Int = 0;
		
		switch( seekmode )
		{
			case PAGESEEK_TOP_FORWARD:	//seek top to end
				this.pageseek_head();
				prev_returned = 0;
				while (true) {
					result = pageout( og );
					if ( result <= 0 )
					{
						return -1;
					}else {
						if ( og.pageno() == t_PageNo )
						{
							this.returned = prev_returned;
							break;
						}
					}
					prev_returned = returned;
				}
			case PAGESEEK_END_BACKWARD: //seek end to top
				this.pageseek_tail();
				prev_returned = fill;
				while (true) {
					result = pageout_back( og );
					if ( result <= 0 )
					{
						return -1;
					}else {
						if ( og.pageno() == t_PageNo )
						{
							this.returned = prev_returned;
							break;
						}
					}
					prev_returned = returned;
				}
				
			case PAGESEEK_NOWPOS_FORWARD: //seek now to end
				prev_returned = returned;
				while (true) {
					result = pageout( og );
					if ( result <= 0 )
					{
						return -1;
					}else {
						if ( og.pageno() == t_PageNo )
						{
							this.returned = prev_returned;
							break;
						}
					}
					prev_returned = returned;
				}
			case PAGESEEK_NOWPOS_BACKWARD: //seek now to top
				prev_returned = returned;
				while (true) {
					result = pageout_back( og );
					if ( result <= 0 )
					{
						return -1;
					}else {
						if ( og.pageno() == t_PageNo )
						{
							this.returned = prev_returned;
							break;
						}
					}
					prev_returned = returned;
				}
			default:
				trace("[SeekableSyncState] <pageseek_targetPage_helper> invalid seekmode." );
				return -1;
		}
		return 1;
	}
	
	/**
	 * page out targetPage.
	 * @param	og
	 * @param	t_PageNo
	 * @return 1 = success. -1 = failed.
	 */
	public function pageout_targetPage( og:Page , t_PageNo:Int ):Int
	{
		var result:Int = 0;
		result = this.pageseek_targetPage( t_PageNo );
		if ( result < 0 )	{			return -1;		}
		result = this.pageout( og );
		if ( result < 0 ) {			return -1;		}
		return result;
	}
	
	/**
	 * seek to granulposition page of the specified. 指定のgranul positionのページへシークする。
	 * @param	t_gpos
	 * @return 1 = success. 0 = no moved. -1 = failed.
	 */
	public function pageseek_targetGpos( t_gpos:Int ):Int
	{
		var og:Page = new Page();
		var result:Int = 0;
		var prev_returned:Int = 0;
		
		this.pageseek_body_top();
		prev_returned = 0;
		while (true) {
			result = pageout( og );
			if ( result <= 0 )
			{
				return -1;
			}else{
				//trace( og.granulepos() );
				if ( t_gpos < og.granulepos() )
				{
					this.returned = prev_returned;
					break;
				}
			}
			prev_returned = returned;
		}
		
		return result;
	}
	
	/**
	 * page out granulposition page of the specified. 指定のgranul positionのページを取得する。
	 * @param	og
	 * @param	t_gpos
	 * @return 1 = success. -1 = failed.
	 */
	public function pageout_targetGpos( og:Page , t_gpos:Int ):Int
	{
		var result:Int = 0;
		result = this.pageseek_targetGpos( t_gpos );
		if ( result < 0 )	{			return -1;		}
		result = this.pageout( og );
		if ( result < 0 ) {			return -1;		}
		return result;
	}
}