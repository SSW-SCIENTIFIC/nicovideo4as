package org.mineap.nicovideo4as.model
{
	/**
	 * ニコニコ動画へのログイン状態を表す列挙型です。
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class NicoAuthFlagType
	{
		
		/**
		 * ニコニコ動画にログインしていません
		 */
		public static const NICO_AUTH_FLAG_FAILURE:NicoAuthFlagType = new NicoAuthFlagType("0");
		
		/**
		 * ニコニコ動画に一般会員でログインしています
		 */
		public static const NICO_AUTH_FLAG_SUCCESS:NicoAuthFlagType = new NicoAuthFlagType("1");
		
		/**
		 * ニコニコ動画にプレミアム会員でログインしています
		 */
		public static const NICO_AUTH_FLAG_PREMIUM_SUCCESS:NicoAuthFlagType = new NicoAuthFlagType("3");
		
		private var _type:String;
		
		public function NicoAuthFlagType(flag:String)
		{
			this._type = flag;
		}
		
		public function get Type():String
		{
			return this._type;
		}
	}
}