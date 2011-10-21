package org.mineap.nicovideo4as
{
	import flash.net.URLRequestDefaults;

	public class UserAgentManager
	{
		
		private static const userAgentManager:UserAgentManager = new UserAgentManager();
		
		public static function get instance():UserAgentManager
		{
			return userAgentManager;
		}
		
		public function UserAgentManager()
		{
		}
		
		public function set userAgent(userAgent:String):void
		{
			URLRequestDefaults.userAgent = userAgent;
		}
		
		public function get userAgent():String
		{
			return URLRequestDefaults.userAgent;
		}
		
	}
}