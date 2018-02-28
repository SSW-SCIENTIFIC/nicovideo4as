package org.mineap.nicovideo4as
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.Socket;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.Timer;
	
	import org.mineap.nicovideo4as.loader.LoginChecker;
	import org.mineap.nicovideo4as.model.NicoAuthFlagType;

	[Event(name="login_success", type="org.mineap.nicovideo4as.Login")]
	[Event(name="login_fail", type="org.mineap.nicovideo4as.Login")]
	[Event(name="logout_complete", type="org.mineap.nicovideo4as.Login")]
	
	/**
	 * ニコニコ動画へのログインリクエストを格納するクラスです。
	 * 
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public class Login extends EventDispatcher
	{
		
		private var _loginLoader:URLLoader;
		private var _loginRequest:URLRequest;
		private var _logoutLoader:URLLoader;
		private var _loginChecker:LoginChecker;
		private var _isRetry:Boolean = false;
		private var _url:String = null;
		private var _user:String = null;
		private var _password:String = null;
		private var _otp: String = null;
		private var _deviceName: String = null;
		
		/**
		 * ニコニコ動画のログインURLです。
		 */
		public static const LOGIN_URL:String = "https://account.nicovideo.jp/api/v1/login";

        /**
		 * 多段階認証
         */
		public static const MULTI_FACTOR_AUTHENTICATION_URL: String = "https://account.nicovideo.jp/mfa";
		
		/**
		 * ニコニコ動画のログアウトURLです。
		 */
		public static const LOGOUT_URL:String = "https://account.nicovideo.jp/logout";
		
		/**
		 * ニコニコ動画へのログインに失敗した際に返されるメッセージです。
		 */
		public static const LOGIN_FAIL_MESSAGE:String = "cant_login";
		
		/**
		 * ニコニコ動画のトップページURLです。
		 */
		public static const TOP_PAGE_URL:String = "http://www.nicovideo.jp/";

		/**
		 * 
		 */
		public static const LOGIN_SUCCESS:String = "LoginSuccess";

		public static const MULTI_FACTOR_AUTHENTICATION_REQUIRED: String = "MultiFactorAuthenticationRequired";
		
		/**
		 * 
		 */
		public static const LOGIN_FAIL:String = "LoginFail";

		public static const NO_LOGIN: String = "NoLogin";
		
		/**
		 * 
		 */
		public static const LOGOUT_COMPLETE:String = "LogoutComplete";
		
		/**
		 * コンストラクタ<br>
		 * 
		 */
		public function Login()
		{
			
		}
		
		/**
		 * ニコニコ動画にログインします。
		 * 
		 * @param user ログイン名です。
		 * @param password ログインパスワードです。
		 * @param otp ワンタイムパッド
		 * @param deviceName デバイス名
		 * @param url ログインに使うURLです。
		 * @param isRetry このフラグがtrueで、かつIOエラーが発生したときに、ログアウト→ログインの順で一度だけ再試行します。
		 * @param preCheck ログイン前に、既にログイン済みかどうかのチェックを行い、ログイン済みの場合はログイン処理を行いません。
		 * @return 
		 * 
		 */
		public function login(user:String = null,
							  password:String = null,
							  otp: String = null,
							  deviceName: String = null,
							  url:String=LOGIN_URL, 
							  isRetry:Boolean = true,
							  preCheck:Boolean = true):void{
			
			this._isRetry = isRetry;
			this._url = url;
			this._user = user;
			this._password = password;
			this._otp = otp;
			this._deviceName = deviceName;

			if (!this._user && !this._password) {
				trace("ログインしない");
				dispatchEvent(new Event(NO_LOGIN));
				return;
			}

			if(preCheck){
				this._loginChecker = new LoginChecker();
				this._loginChecker.addEventListener(Event.COMPLETE, checkCompleteEventHandler);
				this._loginChecker.addEventListener(IOErrorEvent.IO_ERROR, checkErrorEventHandler);
				this._loginChecker.addEventListener(SecurityErrorEvent.SECURITY_ERROR, checkErrorEventHandler);
				this._loginChecker.check(TOP_PAGE_URL);
			}else{
				loginInner();
			}
		}
		
		/**
		 * 
		 * 
		 */
		private function loginInner():void{
			
			this._loginLoader = new URLLoader();
			
			var variables:URLVariables = new URLVariables();
			variables.mail_tel = this._user;
			variables.password = this._password;
			
			this._loginRequest = new URLRequest(this._url);
			this._loginRequest.method = URLRequestMethod.POST;
			this._loginRequest.data = variables;
			
			this._loginLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpCompleteHandler);
			this._loginLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			this._loginLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			this._loginLoader.load(this._loginRequest);
		}
		
		/**
		 * ニコニコ動画からログアウトします。
		 * 
		 */
		public function logout():void{
			if (!this._user && !this._password) {
				trace("ログインせず利用");
				dispatchEvent(new Event(LOGOUT_COMPLETE));
				return;
			}
			
			this._logoutLoader = new URLLoader();
			
			this._logoutLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, logoutCompleteHandler);
			this._logoutLoader.addEventListener(IOErrorEvent.IO_ERROR, logoutCompleteHandler);
			
			this._logoutLoader.load(new URLRequest(LOGOUT_URL));
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function logoutCompleteHandler(event:Event):void{
			trace(event);
			if(this._isRetry){
				trace("ログインリトライ");
				if(_loginRequest != null){
					var timer:Timer = new Timer(1000, 1);
					timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerEventHandler);
					timer.start();
				}else{
					dispatchEvent(new ErrorEvent(LOGIN_FAIL));
				}
			}else{
				dispatchEvent(new Event(LOGOUT_COMPLETE));
			}
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function timerEventHandler(event:Event):void{
			login(String(this._loginRequest.data.mail), String(this._loginRequest.data.password), this._otp, this._deviceName, this._url, false);
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function errorHandler(event:ErrorEvent):void{
			trace(event);
			if(this._isRetry){
				trace("ログアウト");
				logout();
			}else{
				dispatchEvent(new ErrorEvent(LOGIN_FAIL, false, false, event.toString()));
			}
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function httpCompleteHandler(event:HTTPStatusEvent):void{
			trace(event);
			
			dispatchEvent(event);
			
			if (event.status != 200 && event.status != 302) {
				dispatchEvent(new ErrorEvent(LOGIN_FAIL, false, false, "status:" + event.status));
				return;
			}
			
			var value:String;
			for each(var header:Object in event.responseHeaders) {
				if (header.name != null && header.name is String &&
					(header.name as String).toLowerCase() == "x-niconico-authflag") {
					value = header.value;
					break;
				}
			}
			
			trace("x_niconico_authflag=" + value);
			if (value == NicoAuthFlagType.NICO_AUTH_FLAG_FAILURE.Type)
			{
                if (event.responseURL.indexOf(MULTI_FACTOR_AUTHENTICATION_URL) == -1) {
                    dispatchEvent(new ErrorEvent(LOGIN_FAIL, false, false, LOGIN_FAIL_MESSAGE));
                    return;
                }

                trace("OTP: " + this._otp + ", DeviceName: " + this._deviceName);

                if (!this._otp || !this._deviceName) {
                    dispatchEvent(new Event(MULTI_FACTOR_AUTHENTICATION_REQUIRED));
                    return;
                }

                multiFactorAuthentication(event.responseURL, this._otp, true, this._deviceName);
                return;
			} else if (value == NicoAuthFlagType.NICO_AUTH_FLAG_SUCCESS.Type
						|| value == NicoAuthFlagType.NICO_AUTH_FLAG_PREMIUM_SUCCESS.Type)
			{
				// ログイン成功
			}
			else
			{
				dispatchEvent(new ErrorEvent(LOGIN_FAIL, false, false, "status:" + event.status));
				return;
			}
			
			dispatchEvent(new Event(LOGIN_SUCCESS));
		}
		
		public function multiFactorAuthentication(url: String, otp: String, trust: Boolean = false, deviceName: String = null): void {
			trace("MFA entering... " + url);
            var variables: URLVariables = new URLVariables();
            variables.otp = otp;
            variables.is_mfa_trusted_device = trust;
			variables.device_name = deviceName;

            this._loginRequest = new URLRequest(url);
            this._loginRequest.method = URLRequestMethod.POST;
            this._loginRequest.data = variables;

            this._loginLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpCompleteHandler);
            this._loginLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
            this._loginLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
            this._loginLoader.load(this._loginRequest);
		}
		
		/**
		 * 
		 * 
		 */
		public function close():void{
			try{
				if(this._loginLoader != null){
					this._loginLoader.close();
				}
			}catch(error:Error){
				trace(error.getStackTrace());
			}
			try{
				if(this._logoutLoader != null){
					this._logoutLoader.close();
				}
			}catch(error:Error){
				trace(error.getStackTrace());
			}
			try{
				if(this._loginChecker != null){
					this._loginChecker.close();
				}
			}catch(error:Error){
				trace(error.getStackTrace());
			}
			
			this._loginLoader = null;
//			this._loginRequest = null;
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		protected function checkCompleteEventHandler(event:Event):void
		{
			if(this._loginChecker.isAlreadyLogin){
				// 既にログイン済み
				dispatchEvent(new Event(LOGIN_SUCCESS));
			}else{
				// 未ログイン。ログイン試行。
				loginInner();
			}
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		protected function checkErrorEventHandler(event:IOErrorEvent):void
		{
			// 通信路異常
			dispatchEvent(new ErrorEvent(LOGIN_FAIL, false, false, event.toString()));
			close();
		}
		
		
	}
}