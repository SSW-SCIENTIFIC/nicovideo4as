package org.mineap.nicovideo4as.loader.api
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;

	/**
	 * 
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public class ApiGetWaybackkeyAccess extends URLLoader
	{
		
		public static const NICO_API_GET_WAYBACKKEY:String = "http://flapi.nicovideo.jp/api/getwaybackkey";
		
		/**
		 * 
		 * @param request
		 * 
		 */
		public function ApiGetWaybackkeyAccess(request:URLRequest = null)
		{
			if(request != null){
				this.load(request);
			}
		}
		
		/**
		 * 
		 * @param threadId
		 * 
		 */
		public function getAPIResult(threadId:String):void{
			
			var variables:URLVariables = new URLVariables();
			variables.thread = threadId;
			
			var request:URLRequest = new URLRequest(NICO_API_GET_WAYBACKKEY);
			request.data = variables;
			request.method = "GET";
			
			this.load(request);
			
		}
	}
}