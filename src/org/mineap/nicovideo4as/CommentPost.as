package org.mineap.nicovideo4as
{
	import flash.errors.IOError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	
	import org.mineap.nicovideo4as.loader.api.ApiGetFlvAccess;
	
	[Event(name="commentPostSuccess", type="CommentPost")]
	[Event(name="commentPostFail", type="CommentPost")]
	[Event(name="httpResponseStatus", type="HTTPStatusEvent")]
	
	/**
	 * ニコニコ動画の指定された動画に対してコメントの投稿を行います。
	 * コメント投稿の手順
	 * 1. ログイン
	 * 2. getflvにアクセスして[メッセージサーバのURL]と[スレッドID]と[ユーザーID]を取得
	 * 3. [メッセージサーバ]に[スレッドID]と[ユーザーID]をPOSTして[現在のレス数]と[ticket]を取得
	 * 4. getpostkeyに[現在のレス数]割る100（ブロックナンバー）と[スレッドID]をPOSTして[postkey]を取得
	 * 5. [メッセージサーバ]に[スレッドID]と[ticket]と[ユーザーID]と[postkey]とコメント等々をPOSTして[no]（レス番号）を取得
	 *  
	 * @author shiraminekeisuke
	 * @author edvakf
	 * 
	 */
	public class CommentPost extends EventDispatcher
	{
		private var _commentLoader:CommentLoader;
		private var _postLoader:URLLoader;
		private var _login:Login;
		private var _getflvAccess:ApiGetFlvAccess;
		private var _watchLoader:WatchVideoPage;
		
		private var _videoId:String;
		private var _comment:String;
		private var _vpos:int;
		private var _no:String;
		private var _user_id:String;
		private var _premium:String;
		private var _ticket:String;
		private var _mail:String;
		private var _thread:String;
		private var _resultCode:String;
		private var _is184:Boolean;
		private var _isRedirected:Boolean = false;
		private var _redirectedVideoId:String;
		
		private var _chat:XML;
		
		private static const GETPOSTKEY_URL:String = "http://flapi.nicovideo.jp/api/getpostkey";
		
		public static const COMMENT_POST_SUCCESS:String = "CommentPostSuccess";
		public static const COMMENT_POST_FAIL:String = "CommentPostFail";
		
		/**
		 * コンストラクタです。
		 * 
		 */
		public function CommentPost()
		{
			this._commentLoader = new CommentLoader();
			this._postLoader = new URLLoader();
			this._login = new Login();
			this._getflvAccess = new ApiGetFlvAccess();
			this._watchLoader = new WatchVideoPage();
			this._chat = null;
		}
		
		/**
		 * ログインし、指定された動画にコメントを投稿します。<br>
		 * 
		 * @param mailAddress ログイン用メールアドレス
		 * @param password ログイン用パスワード
		 * @param videoId 投稿する動画
		 * @param comment 投稿するコメント
		 * @param mail コメントのコマンド
		 * @param vpos 動画を投稿するvpos
		 * @param is184 匿名でコメントするかどうか
		 * @author edvakf
		 */
		public function postCommentWithLogin(mailAddress:String,
											 password:String,
											 videoId:String, 
											 comment:String, 
											 mail:String, 
											 vpos:int,
											 is184:Boolean):void{
			
			this._videoId = videoId;
			this._comment = comment;
			this._mail = mail;
			this._vpos = vpos;
			this._is184 = is184;
			
			this._login.addEventListener(Login.LOGIN_SUCCESS, loginSuccessHandler);
			this._login.addEventListener(Login.LOGIN_FAIL, networkErrorHandler);
			this._login.login(mailAddress, password);
		}
		
		/**
		 * ログイン完了後に呼ばれます。
		 */
		protected function loginSuccessHandler(event:Event):void
		{
			this._watchLoader.addEventListener(IOErrorEvent.IO_ERROR, networkErrorHandler);
			this._watchLoader.addEventListener(WatchVideoPage.WATCH_FAIL, networkErrorHandler);
			this._watchLoader.addEventListener(WatchVideoPage.WATCH_SUCCESS, getflvSuccessHandler);
			this._watchLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, function(event:HTTPStatusEvent):void{
				trace(event);
				
				var url:String = event.responseURL;
				var index:int = url.lastIndexOf("/");
				var threadId:String = url.substr(index + 1);
				
				index = threadId.indexOf("?");
				if (index != -1)
				{
					threadId = threadId.substring(0, index);
				}
				
				// リダイレクトされた。
				if(threadId != _videoId){
					trace("リダイレクト: " + _videoId + " -> " + threadId);
					_isRedirected = true;
					_redirectedVideoId = threadId;
				}
					
				httpResponseStatusEventHandler(event);
			});
			// チャンネル動画はリダイレクト先のURLに含まれる動画IDを使う必要があるので、リダイレクトがあるかどうかチェック。
			this._watchLoader.watchVideo(this._videoId, true);
		}
		
		/**
		 * 動画ページを見に行った後に呼ばれます
		 * 
		 */
		protected function getflvSuccessHandler(event:Event):void
		{
			this._getflvAccess.addEventListener(IOErrorEvent.IO_ERROR, networkErrorHandler);
			this._getflvAccess.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpResponseStatusEventHandler);
			this._getflvAccess.addEventListener(Event.COMPLETE, getflvLoadedHandler);
			// alwaysEconomy フラグを false にしていますが、動画 URL を取得するわけではないので関係ないはず。
			
			if (_isRedirected)
			{
				// チャンネル動画
				this._getflvAccess.getAPIResult(this._redirectedVideoId, false);
			}
			else
			{
				this._getflvAccess.getAPIResult(this._videoId, false);
			}
		}
		
		/**
		 * getflv の API アクセス完了後に呼ばれます。
		 * @author edvakf
		 */
		protected function getflvLoadedHandler(event:Event):void{
			this.postComment(this._videoId, this._mail, this._comment, this._vpos, this._getflvAccess, this._is184);
		}
		
		/**
		 * 指定された動画にコメントを投稿します。<br>
		 * 
		 * @param videoId 投稿する動画
		 * @param mail コメントのコマンド
		 * @param comment 投稿するコメント
		 * @param vpos 動画を投稿するvpos
		 * @param is184 匿名でコメントするかどうか
		 * @return 
		 * 
		 */
		public function postComment(videoId:String, 
									mail:String, 
									comment:String, 
									vpos:int, 
									apiAccess:ApiGetFlvAccess,
									is184:Boolean):void{
			
			this._comment = comment;
			this._mail = mail;
			this._vpos = vpos;
			this._is184 = is184;
			
			this._commentLoader.addEventListener(CommentLoader.COMMENT_GET_SUCCESS, commentGetSuccess);
			this._commentLoader.addEventListener(CommentLoader.COMMENT_GET_FAIL, networkErrorHandler);
			this._commentLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpResponseStatusEventHandler);
			//TODO コメントローダーにAPIアクセサを渡さないと行けない。
			this._commentLoader.getComment(videoId, 1, false, apiAccess);
		}
		
		/**
		 * コメントの取得が完了したら呼ばれます。
		 * 
		 * @param event
		 * 
		 */
		private function commentGetSuccess(event:Event):void{
			var xml:XML = (event.target as CommentLoader).xml;
			var thread:XML = xml.thread[0];
			var ticket:String = thread.@ticket;
			var threadId:String = thread.@thread;
			var commentCount:int = thread.@last_res;
			var resultCode:String = thread.@resultcode
			
			var comments:XMLList = xml.chat;
			
			this._thread = threadId;
			this._ticket = ticket;
			this._resultCode = resultCode;
			
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(IOErrorEvent.IO_ERROR, networkErrorHandler);
			loader.addEventListener(Event.COMPLETE, getPostKeySuccess);
			loader.load(new URLRequest(GETPOSTKEY_URL + "?version=1&yugi=&device=1&version_sub=2&thread=" + threadId + "&block_no=" + int((commentCount+1)/100)));
		}
		
		/**
		 * APIからPostkeyを取得したときに呼ばれます。
		 * @param event
		 * 
		 */
		private function getPostKeySuccess(event:Event):void{
			var postKey:String = (event.target.data as String).substring(event.target.data.indexOf("=")+1);
			post(postKey, 
				this._commentLoader.userID, 
				this._ticket, 
				this._mail, 
				this._comment, 
				this._vpos, 
				this._thread, 
				this._commentLoader.isPremium, 
				this._commentLoader.messageServerUrl,
				this._resultCode, 
				this._is184);
		}
		
		/**
		 * コメントを投稿します。
		 * 
		 * @param postKey ポストキーです。コメントXMLのスレッドIDを元にAPIから取得します。
		 * @param user_id ユーザーIDです。コメントXMLから取得します。
		 * @param ticket チケットです。コメントXMLから取得します。
		 * @param mail コマンドです。
		 * @param comment コメント本体です。
		 * @param vpos 動画のどの時間に投稿したかを表すミリ秒です。
		 * @param thread スレッドIDです。コメントXMLから取得します。
		 * @param isPremium プレミアムかどうかを表すフラグです。1のときにプレミアムです。APIから取得します。
		 * @param messageServerUrl メッセージサーバーのURLです。コメントXMLから取得します。
		 * @param resultCode コメントXML内のthread要素に格納されるresutcode属性の値です。
		 * @param is184 匿名でコメントするかどうかを指定します。
		 * 
		 */
		public function post(postKey:String, 
							 user_id:String, 
							 ticket:String, 
							 mail:String, 
							 comment:String, 
							 vpos:int, 
							 thread:String, 
							 isPremium:Boolean, 
							 messageServerUrl:String, 
							 resultCode:String,
							 is184:Boolean):void{
			
			var getComment:URLRequest = new URLRequest(unescape(messageServerUrl));
			getComment.method = "POST";
			getComment.requestHeaders = new Array(new URLRequestHeader("Content-Type", "text/html"));
			
			//<chat thread="" vpos="" mail="184 " ticket="" user_id="" postkey="" premium="">test</chat>
			var chat:XML = <chat />;
			chat.@thread = thread;
			chat.@vpos = String(vpos);
			
			if (mail == null)
			{
				mail = "";
			}
			
			if (resultCode != null && resultCode == "1")
			{
				// "1"のときは 184 しない
			}
			else
			{
				if (is184)
				{
					if (mail.indexOf("184") == -1)
					{
						if (mail.length > 0)
						{
							// mailに内容がある
							mail = "184 " + mail;
						}
						else
						{
							// mailが空
							mail = "184";
						}
					}
				}
			}
			chat.@mail = mail;
			chat.@ticket = ticket;
			chat.@user_id = user_id;
			chat.@postkey = postKey;
			if (isPremium)
			{
				chat.@premium = "1";
			}
			chat.appendChild(comment);
			
			getComment.data = chat;
			
			this._thread = thread;
			this._vpos = chat.@vpos;
			this._mail = mail;
			
			this._user_id = user_id;
			this._premium = chat.@premium;
			this._comment = comment;
			
			this._postLoader.addEventListener(Event.COMPLETE, commentPostCompleteHandler);
			this._postLoader.addEventListener(IOErrorEvent.IO_ERROR, networkErrorHandler);
			this._postLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpResponseStatusEventHandler);
			this._postLoader.dataFormat=URLLoaderDataFormat.TEXT;
			this._postLoader.load(getComment);
			
		}
		
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function httpResponseStatusEventHandler(event:HTTPStatusEvent):void{
			trace(event + ":" + event.status);
			dispatchEvent(event);
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function commentPostCompleteHandler(event:Event):void{
			trace(event);
			try{
				var resXml:XML = new XML((event.target as URLLoader).data);
				trace(resXml);
				if (resXml.chat_result.@status != "0")
				{
					if (resXml.chat_result.@status == "1")
					{
						throw new Error("同じ内容のコメントを二回連続で投稿できません(status=" + resXml.chat_result.@status + ")");
					}
					else
					{
						throw new Error("コメントの投稿に失敗:chat_result.@status=" + resXml.chat_result.@status);	
					}
				}
				
				if (resXml.chat_result.@no != null)
				{
					this._no = resXml.chat_result.@no;
				}
				else
				{
					throw new Error("コメントの投稿に失敗:no is null.");
				}
			}catch(error:Error){
				trace(error.getStackTrace());
				var ioError:IOErrorEvent = new IOErrorEvent(COMMENT_POST_FAIL, false, false, error.toString());
				dispatchEvent(ioError);
				return;
			}
			dispatchEvent(new Event(COMMENT_POST_SUCCESS));
		}
		
		/**
		 * ログイン・スレッド ID 取得・コメント取得・ポストキー取得のいずれかでエラーが起こると IOErrorEvent を発行します。
		 * @param event
		 * 
		 */
		private function networkErrorHandler(event:ErrorEvent):void{
			trace(event);
			dispatchEvent(new IOErrorEvent(COMMENT_POST_FAIL, false, false, event.text));
		}
		
		/**
		 * コメントの結果を返します。
		 * @author edvakf
		 */
		public function getPostComment():XML{
			// 送信前の chat とほとんど同じですが、いくつか属性が消え、"no" 属性がつきます。
			var chat:XML = <chat />;
			chat.@thread = this._thread;
			chat.@no = this._no;
			chat.@vpos = this._vpos;
			chat.@date = Math.floor((new Date()).getTime() / 1000);
			chat.@mail = "184 " + this._mail;
			chat.@user_id = this._user_id;
			chat.@premium = this._premium;
			chat.@anonymity = '1';
			chat.appendChild(this._comment);
			return chat;
		}
		
		/**
		 * 
		 * 
		 */
		public function close():void{
			try{
				this._login.close();
			}catch(error:Error){
//				trace(error.getStackTrace());
			}
			try{
				this._getflvAccess.close();
			}catch(error:Error){
//				trace(error.getStackTrace());
			}
			try{
				this._commentLoader.close();
			}catch(error:Error){
//				trace(error.getStackTrace());
			}
//			this._commentLoader = null;
			try{
				this._postLoader.close();
			}catch(error:Error){
//				trace(error.getStackTrace());
			}
//			this._postLoader = null;
		}
		
	}
}