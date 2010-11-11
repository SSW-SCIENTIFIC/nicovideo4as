package org.mineap.nicovideo4as.loader
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;

	/**
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class PublicMyListLoader extends URLLoader
	{
		
		public static const MYLIST_PAGE_URL:String = "http://www.nicovideo.jp/mylist/";
		
		public function PublicMyListLoader(request:URLRequest = null)
		{
			if (request != null)
			{
				this.load(request);
			}
		}
		
		/**
		 * 
		 * @param myListId
		 * 
		 */
		public function getMyList(myListId:String):void{
			
			var url:String = MYLIST_PAGE_URL + myListId;
			
			var variables:URLVariables = new URLVariables();
			variables.rss = "2.0";
			
			var request:URLRequest = new URLRequest(url);
			request.data = variables;
			
			this.load(request);
			
		}
		
	}
}