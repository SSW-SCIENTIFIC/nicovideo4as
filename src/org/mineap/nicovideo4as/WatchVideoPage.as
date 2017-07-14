package org.mineap.nicovideo4as
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.utils.unescapeMultiByte;
	
	import mx.messaging.SubscriptionInfo;
	
	import org.mineap.nicovideo4as.util.HtmlUtil;
	
	[Event(name="watchSuccess", type="org.mineap.nicovideo4as.WatchVideoPage")]
	[Event(name="watchFail", type="org.mineap.nicovideo4as.WatchVideoPage")]
	[Event(name="httpResponseStatus", type="HTTPStatusEvent")]
	
	/**
	 * 
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public class WatchVideoPage extends EventDispatcher
	{
		
		private var _watchLoader:URLLoader;
		
		//so.addVariable("videoId", "so8174126");
		private static const videoIdPattern:RegExp = new RegExp("addVariable.\"videoId\", \"([^\"]+)\".");
		
		/*
		<tr>
		<td style="background:#CCCFCF;"><img src="http://res.nimg.jp/img/watch/ftit_description.png" alt="動画の説明文"></td>
		<td width="100%" class="font12" style="background:#FFF;">
			(.*</p>)
		</td>
		</tr>
		*/
		/**
		 * 
		 */
		private var descriptionPattern:RegExp = new RegExp("description:[^']*'(.*)'");
		
		//"<img src=\"http://res.nimg.jp/img/_.gif\" alt=\"動画の説明文\" class=\"video_des_tit\"></td>[^<]*<td width=\"100%\" style=\"background:#F9F9F9;\">(.*</p>)</td>[^<]*</tr>[^<]*</table>"
		
		/**
		 * 
		 */
		private static const fontSizePattern:RegExp = new RegExp("size=\"([1-7])\"", "ig");
		
		/**
		 * 
		 */
		private static const prefix:String = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">" +
			"<html>" +
			"<head>" +
			"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">" +
			"</head>" +
			"<body>";
		
		/**
		 * 
		 */
		private static const suffix:String = "</body>" +
			"</html>";
		
		/**
		 * 投稿者が普通のユーザの時
		 */
		private static const pubUser:String = "<a href=\"user/([^\"]+)\"><img src=\"([^\"]+)\" alt=\"([^\"]+)\" class=\".+\"></a>";
		
		/**
		 * 投稿者がチャンネルの時
		 * <a href="http://ch.nicovideo.jp/channel/ch639"><img src="http://icon.nimg.jp/channel/ch639.jpg?1303983084" alt="「俺の妹がこんなに可愛いわけがない」動画配信チャンネル" class="img_sq48"></a>
		 */
		private static const channel:String = "<a href=\"http://ch.nicovideo.jp/channel/([^\"]+)\"><img src=\"([^\"]+)\" alt=\"([^\"]+)\" class=\".+\"></a>";
		
		/**
		 * 動画に未成年者向け警告がある時
		 */
		private static const harmful:String = "watch_harmful=1";
		
		/**
		 * "http://www.nicovideo.jp/watch/"を表す定数です
		 */
		public static const WATCH_VIDEO_PAGE_URL:String = "http://www.nicovideo.jp/watch/";
		
		/**
		 * 
		 */
		public static const WATCH_SUCCESS:String = "WatchSuccess";
		
		/**
		 * 
		 */
		public static const WATCH_FAIL:String = "WatchFail";
		
		/**
		 * 
		 */
		private var _videoId:String = "";
		
		/**
		 * 
		 */
		private var _data:Object = "";
		
		/**
		 * 
		 */
		private var _jsonObj:Object = null;

		private var _isHTML5: Boolean = false;
		private var _isFlash: Boolean = false;
		
		/**
		 * 
		 * 
		 */
		public function WatchVideoPage()
		{
			this._watchLoader = new URLLoader();
		}
		
		/**
		 * 
		 * @param videoId 開く動画のID(スレッドIDでも可能)
		 * @param watchHarmful 有害動画に指定されている動画を強制的に開くかどうか
		 * 
		 */
		public function watchVideo(videoId:String, watchHarmful:Boolean):void{
			
			this._videoId = videoId;
			
			var mUrl:String = WATCH_VIDEO_PAGE_URL + videoId;
			
			var watchURL:URLRequest = new URLRequest(mUrl);
			watchURL.method = "GET";
			watchURL.followRedirects = true;
			watchURL.userAgent = "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.99 Safari/537.36";
			
			if(watchHarmful){
				var variables:URLVariables = new URLVariables();
				variables.watch_harmful = 1;
				watchURL.data = variables;
			}
			
			this._watchLoader.addEventListener(Event.COMPLETE, completeEventHandler);
			this._watchLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			this._watchLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			this._watchLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpResponseHandler);
			this._watchLoader.load(watchURL);
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function getVideoId():String{
			
			// json形式でとれた場合はそれで返す (zero対応)
			if (this._isHTML5) {
                return this._jsonObj.video.id;
            }
			if (this._isFlash) {
				return this._jsonObj.videoDetail.id;
			}
			
			if(this._watchLoader.data != null){
				
				var result:Array = videoIdPattern.exec(this._watchLoader.data);
				if(result != null && result.length > 1){
					return result[1];
				}else{
					return this._videoId;
				}
				
			}else{
				return this._videoId;
			}
			
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function getDescription():String{
			
			// json形式でとれた場合はそれで返す (zero対応)
			if (this._isHTML5) {
				return this._jsonObj.video.description || "";
			}
			if (this._isFlash) {
				return this._jsonObj.videoDetail.description || "";
			}
			
			if (this._watchLoader.data != null) {
				
				var result:Array = descriptionPattern.exec(this._watchLoader.data);
				if(result != null && result.length > 1){
					var html:String = prefix + HtmlUtil.convertCharacterCodeToCharacter(result[1]) + suffix;
					
					html = html.replace(fontSizePattern, replFN);
					
					function replFN():String{
						var value:int = new int(arguments[1]);
						if(arguments[1] != ""){
							value = value-3;
							if(value > 0){
								return (arguments[0] as String).replace(arguments[1], "+" + value);
							}
							return (arguments[0] as String).replace(arguments[1], value);
							
						}
						return arguments[0];
					}
					
					trace(html);
					return html;
				}else{
					return "";
				}
				
			} else {
				return "";
			}
			
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function getPubUserId():String{
			
			if (this._isHTML5) {
				if (this._jsonObj.owner != null) {
					return this._jsonObj.owner.id;
				}
			}
			if (this._isFlash) {
				if (this._jsonObj.uploaderInfo != null) {
					return this._jsonObj.uploaderInfo.id;
				}
			}
			
			if(this._watchLoader != null && this._watchLoader.data != null){
				var pubUserPattern:RegExp = new RegExp(pubUser);
				var result:Array = pubUserPattern.exec(this._watchLoader.data);
				if(result != null && result.length > 1){
					return result[1];
				}else{
					return null;
				}
			}else{
				return null;
			}
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function getPubUserIconUrl():String{

            if (this._isHTML5) {
                if (this._jsonObj.owner != null) {
                    return this._jsonObj.owner.iconURL;
                }
            }
            if (this._isFlash) {
                if (this._jsonObj.uploaderInfo != null) {
                    return this._jsonObj.uploaderInfo.icon_url;
                }
            }
			
			if(this._watchLoader != null && this._watchLoader.data != null){
				var pubUserPattern:RegExp = new RegExp(pubUser);
				var result:Array = pubUserPattern.exec(this._watchLoader.data);
				if(result != null && result.length > 1){
					return result[2];
				}else{
					return null;
				}
			}else{
				return null;
			}
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function getPubUserName():String{

            if (this._isHTML5) {
                if (this._jsonObj.owner != null) {
                    return this._jsonObj.owner.nickname;
                }
            }
            if (this._isFlash) {
                if (this._jsonObj.uploaderInfo != null) {
                    return this._jsonObj.uploaderInfo.nickname;
                }
            }
			
			if(this._watchLoader != null && this._watchLoader.data != null){
				var pubUserPattern:RegExp = new RegExp(pubUser);
				var result:Array = pubUserPattern.exec(this._watchLoader.data);
				if(result != null && result.length > 1){
					return result[3];
				}else{
					return null;
				}
			}else{
				return null;
			}
		}
		
		/**
		 * チャンネルを返す。
		 * @return "ch639"など
		 * 
		 */
		public function getChannel():String{

            if (this._isHTML5) {
                if (this._jsonObj.channel != null) {
                    return this._jsonObj.channel.id;
                }
            }
            if (this._isFlash) {
                if (this._jsonObj.channelInfo != null) {
                    return this._jsonObj.channelInfo.id;
                }
            }
			
			if (this._watchLoader != null && this._watchLoader.data != null)
			{
				var channelPattern:RegExp = new RegExp(channel);
				var result:Array = channelPattern.exec(this._watchLoader.data);
				if (result != null && result.length > 1)
				{
					return result[1];
				}
			}
			return null;
		}
		
		/**
		 * チャンネルのアイコンURLを返す
		 * @return 
		 * 
		 */
		public function getChannelIconUrl():String{

            if (this._isHTML5) {
                if (this._jsonObj.channel != null) {
                    return this._jsonObj.channel.iconURL;
                }
            }
            if (this._isFlash) {
                if (this._jsonObj.channelInfo != null) {
                    return this._jsonObj.channelInfo.icon_url;
                }
            }
			
			if (this._watchLoader != null && this._watchLoader.data != null)
			{
				var channelPattern:RegExp = new RegExp(channel);
				var result:Array = channelPattern.exec(this._watchLoader.data);
				if (result != null && result.length > 1)
				{
					return result[2];
				}
			}
			return null;
		}
		
		/**
		 * チャンネルの名前を返す
		 * @return 
		 * 
		 */
		public function getChannelName():String{

            if (this._isHTML5) {
                if (this._jsonObj.channel != null) {
                    return this._jsonObj.channel.name;
                }
            }
            if (this._isFlash) {
                if (this._jsonObj.channelInfo != null) {
                    return this._jsonObj.channelInfo.name;
                }
            }
			
			if (this._watchLoader != null && this._watchLoader.data != null)
			{
				var channelPattern:RegExp = new RegExp(channel);
				var result:Array = channelPattern.exec(this._watchLoader.data);
				if (result != null && result.length > 1)
				{
					return result[3];
				}
			}
			return null;
		}
		
		/**
		 * この動画が有害であると判定されている場合にtrueを返します。
		 * @return 
		 * 
		 */
		public function checkHarmful():Boolean
		{
            if (this._isHTML5) {
                return this._jsonObj.video.isR18;
            }
            if (this._isFlash) {
                return this._jsonObj.videoDetail.isR18;
            }
			
			if (this._watchLoader != null && this._watchLoader.data != null)
			{
				var str:String = getVideoId() + "?" + harmful;
				
				if ((this._watchLoader.data as String).indexOf(str) > -1)
				{
					return true;
				}
			}
			return false;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get audioDownloadUrl():String
		{
			return null;
		}
		
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function completeEventHandler(event:Event):void{
			
			// TODO テスト
//			trace(this.getDescription());
			this._data = this._watchLoader.data;
			
			// 可能であればjsonオブジェクトを作る
			this._jsonObj = createJsonObject(String(this._data));

			if (this._jsonObj != null) {
                if (this._jsonObj.hasOwnProperty("video")) {
                    this._isHTML5 = true;
                }

                if (this._jsonObj.hasOwnProperty("flashvars")) {
                    this._isFlash = true;
                }
            }
			
			dispatchEvent(new Event(WATCH_SUCCESS));
		}
		
		/**
		 * 
		 * @param str
		 * @return 
		 * 
		 */
		private function createJsonObject(str:String):Object
		{
			if (str == null)
			{
				return null;
			}
			
			var jsonObj:Object = null;

            var regexp:RegExp = new RegExp("<div id=\"watchAPIDataContainer\" style=\"display:none\">(.+?)</div>");
            var regexp2:RegExp = new RegExp("<div id=\"js-initial-watch-data\" data-api-data=\"([^\"]+)\"[^>]*>");

            var obj:Object = regexp.exec(str);
            var obj2:Object = regexp2.exec(str);

			if (obj != null && obj[1] != null) {
				var jsonStr:String = obj[1];
				jsonObj = JSON.parse(HtmlUtil.convertSpecialCharacterNotIncludedString(jsonStr));
			} else if (obj2 != null && obj2[1] != null) {
				var jsonStr2:String = obj2[1]
						.replace(/&quot;/g, "\"")
						.replace(/&lt;/g, "<")
						.replace(/&gt;/g, ">")
						.replace(/&amp;/g, "&");
				jsonObj = JSON.parse(jsonStr2);
			} else {
				return null;
			}
			
			return jsonObj;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get data():Object{
			return this._data;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get jsonData():Object
		{
			return this._jsonObj;
		}

		public function get isDmc(): Boolean
		{
			if (this._jsonObj == null) {
				return false;
			}

			if (this._isFlash) {
				return (this._jsonObj.flashvars.isDmc == 1);
			}

			if (this._isHTML5) {
				return (this._jsonObj.video.dmcInfo != null);
			}

			return false;
		}

		public function get dmcInfo(): Object
		{
			if (!this.isDmc) {
				return null;
			}

            if (this._isFlash) {
                return JSON.parse(decodeURIComponent(this._jsonObj.flashvars.dmcInfo));
            }

            if (this._isHTML5) {
                return this._jsonObj.video.dmcInfo;
            }

			return null;
		}

		public function get smileInfo(): Object
		{
			if (this._isHTML5) {
				return this._jsonObj.video.smileInfo;
			}

			return null;
		}

		public function get isPremium(): Boolean
		{
			if (this._isHTML5) {
				return this._jsonObj.viewer.isPremium;
			}
			if (this._isFlash) {
				return this._jsonObj.viewerInfo.isPremium;
			}

			return false;
		}

		public function get isHTML5 (): Boolean
		{
			return this._isHTML5;
		}

		public function get isFlash(): Boolean
		{
			return this._isFlash;
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function errorHandler(event:ErrorEvent):void{
			dispatchEvent(new ErrorEvent(WATCH_FAIL, false, false, event.text));
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function httpResponseHandler(event:HTTPStatusEvent):void{
			dispatchEvent(event);
		}
		
		/**
		 * 
		 * 
		 */
		public function close():void{
			try{
				this._watchLoader.close();
			}catch(error:Error){
//				trace(error.getStackTrace());
			}
//			this._watchLoader = null;
			
		}

	}
}