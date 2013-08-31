package org.mineap.nicovideo4as.loader
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	/**
	 * サムネイル情報を取得します。
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class ThumbInfoLoader extends URLLoader
	{
		
		public static const NICO_VIDEO_THUMB_INFO_GET_API:String = "http://ext.nicovideo.jp/api/getthumbinfo/";
		
		public function ThumbInfoLoader(urlRequest:URLRequest = null)
		{
			if (urlRequest != null) { 
				this.load(urlRequest);
			}
		}
		
		/**
		 * 指定した動画IDの動画のサムネイル情報を取得します。
		 * 
		 * @param videoId
		 * @return 
		 * 
		 */
		public function getThumbInfo(videoId:String):void{
			//http://www.nicovideo.jp/api/getthumbinfo/動画ID
//			this._thumbInfoLoader.load(new URLRequest("http://www.nicovideo.jp/api/getthumbinfo/" + videoId));
			
			var request:URLRequest = new URLRequest(NICO_VIDEO_THUMB_INFO_GET_API + videoId);
			
			this.load(request);
		}
	}
}