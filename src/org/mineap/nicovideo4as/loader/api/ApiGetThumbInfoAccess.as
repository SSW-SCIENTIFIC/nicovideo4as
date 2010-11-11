package org.mineap.nicovideo4as.loader.api
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	/**
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class ApiGetThumbInfoAccess extends URLLoader
	{
		
		public static const GET_THUMB_INFO_API_URL:String = "http://ext.nicovideo.jp/api/getthumbinfo/";
		
		public function ApiGetThumbInfoAccess(request:URLRequest = null)
		{
			if (request != null)
			{
				this.load(request);
			}
		}
		
		public function getThumbInfo(videoId:String):void
		{
			
			var url:String = GET_THUMB_INFO_API_URL + videoId;
			
			var request:URLRequest = new URLRequest(url);
			
			this.load(request);
			
		}
		
		
	}
}