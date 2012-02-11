package org.mineap.nicovideo4as.loader
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	
	/**
	 * ユーザの投稿した動画の一覧を取得するクラスです。
	 * 
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public class UserVideoListLoader extends URLLoader
	{
		
		public static const USER_VIDEO_LIST_URL_PRE:String = "http://www.nicovideo.jp/user/";
		
		public static const USER_VIDEO_LIST_URL_SUF:String = "/video";
		
		/**
		 * 
		 * @param request
		 * 
		 */
		public function UserVideoListLoader(request:URLRequest=null)
		{
			super(request);
		}
		
		/**
		 * 
		 * @param userId
		 * @param page 
		 * 
		 */
		public function getVideoList(userId:String, page:int = 0):void
		{
			var url:String = USER_VIDEO_LIST_URL_PRE + userId + USER_VIDEO_LIST_URL_SUF;
			
			var variables:URLVariables = new URLVariables();
			if (page > 0)
			{
				variables.page = page;
			}
			variables.rss = "2.0";
			
			var request:URLRequest = new URLRequest(url);
			request.data = variables;
			
			this.load(request);
			
		}
	}
}