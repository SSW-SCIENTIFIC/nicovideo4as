package org.mineap.nicovideo4as.loader.api
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	
	import org.mineap.nicovideo4as.model.search.SearchOrderType;
	import org.mineap.nicovideo4as.model.search.SearchSortType;
	import org.mineap.nicovideo4as.model.search.SearchType;

	public class ApiSearchAccess extends URLLoader
	{	
		public static const SEARCH_API_ACCESS_URL:String = "http://ext.nicovideo.jp/api/search/";
		
		public function ApiSearchAccess(request:URLRequest = null)
		{
			super(request);
		}
		
		public function search(type:SearchType, 
							   target:String, 
							   page:int, 
							   sort:SearchSortType, 
							   order:SearchOrderType, 
							   mode:String="watch"):void
		{
			
			var url:String = SEARCH_API_ACCESS_URL + type.typeString + "/" + target;
			
			var variables:URLVariables = new URLVariables();
			variables.mode = mode;
			variables.page = page;
			variables.sort = sort.sortTypeString;
			variables.order = order.orderStr;
			
			var req:URLRequest = new URLRequest(url);
			req.data = variables;
			req.method = "GET";
			
			this.load(req);
			
		}
		
	}
}