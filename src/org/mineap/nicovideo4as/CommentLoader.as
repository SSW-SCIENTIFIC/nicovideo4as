package org.mineap.nicovideo4as {
    import flash.errors.IOError;
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.HTTPStatusEvent;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.net.URLRequest;
    import flash.net.URLRequestHeader;

    import org.mineap.nicovideo4as.analyzer.CommentAnalyzer;
    import org.mineap.nicovideo4as.analyzer.GetFlvResultAnalyzer;
    import org.mineap.nicovideo4as.analyzer.GetThreadKeyResultAnalyzer;
    import org.mineap.nicovideo4as.loader.api.ApiGetFlvAccess;
    import org.mineap.nicovideo4as.loader.api.ApiGetThreadkeyAccess;
    import org.mineap.nicovideo4as.loader.api.ApiGetWaybackkeyAccess;
    import org.mineap.nicovideo4as.model.NgUp;

    [Event(name="commentGetSuccess", type="CommentLoader")]
    [Event(name="commentGetFail", type="CommentLoader")]
    [Event(name="httpResponseStatus", type="HTTPStatusEvent")]

    /**
     * ニコニコ動画からコメントを取得します。<br>
     *
     * @author shiraminekeisuke(MineAP)
     * @eventType CommentLoader.COMMENT_GET_SUCCESS
     * @eventType CommentLoader.COMMENT_GET_FAIL
     * @eventType HTTPStatusEvent.HTTP_RESPONSE_STATUS
     */ public class CommentLoader extends EventDispatcher {

        private var _commentLoader: URLLoader;

        private var _messageServerUrl: String;

        private var _apiAccess: ApiGetFlvAccess;

        private var _apiGetThreadkeyAccess: ApiGetThreadkeyAccess;

        private var _getflvAnalyzer: GetFlvResultAnalyzer;

        private var _commentAnalyzer: CommentAnalyzer;

        private var _isOwnerComment: Boolean;

        private var _when: Date;

        private var _waybackkey: String;

        private var _count: int = 0;

        private var _xml: XML;

        private var _useOldType: Boolean = false;

        public static const COMMENT_GET_SUCCESS: String = "CommentGetSuccess";

        public static const COMMENT_GET_FAIL: String = "CommentGetFail";

        /**
         * コンストラクタ
         *
         */
        public function CommentLoader() {
            this._commentLoader = new URLLoader();
            this._apiGetThreadkeyAccess = new ApiGetThreadkeyAccess();
        }

        /**
         * ニコニコ動画にアクセスしてコメントを取得します。
         *
         * @param videoId コメントを取得したい動画の動画ID。
         * @param count 取得するコメントの数。
         * @param isOwnerComment 投稿者コメントかどうか
         * @param apiAccess getFlvにアクセスするApiGetFlvAccessオブジェクト
         * @param when 過去ログを取得する際の取得開始時刻
         * @param waybackkey 過去ログを取得する際に必要なwaybackkey
         * @param useOldType 通常コメント取得時に古い形式のコメント取得方法を使うかどうか(過去ログ、投稿者コメントでは無効)
         */
        public function getComment(videoId: String, count: int, isOwnerComment: Boolean, apiAccess: ApiGetFlvAccess, when: Date = null, waybackkey: String = null, useOldType: Boolean = false): void {
            this._count = count;

            this._apiAccess = apiAccess;

            this._getflvAnalyzer = new GetFlvResultAnalyzer();

            this._isOwnerComment = isOwnerComment;

            this._when = when;

            this._waybackkey = waybackkey;

            this._useOldType = useOldType;

            var isSucess: Boolean = _getflvAnalyzer.analyze(apiAccess.data);

            if (!isSucess) {
                dispatchEvent(new IOErrorEvent(COMMENT_GET_FAIL, false, false, _getflvAnalyzer.result));
                close();
                return;
            }

            //コメントを投稿する際に使う
            this._messageServerUrl = _getflvAnalyzer.ms;

            // getthreadkeyにアクセス
            this._apiGetThreadkeyAccess.addEventListener(Event.COMPLETE, _getComment);
            this._apiGetThreadkeyAccess.addEventListener(IOErrorEvent.IO_ERROR, function (event: IOErrorEvent): void {
                trace(event);
                dispatchEvent(new IOErrorEvent(COMMENT_GET_FAIL, false, false, _getflvAnalyzer.result));
                close();
            });
            this._apiGetThreadkeyAccess.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, function (event: HTTPStatusEvent): void {
                trace(event);
            });
            this._apiGetThreadkeyAccess.getThreadkey(this._getflvAnalyzer.threadId);

        }

        /**
         *
         */
        private function _getComment(event: Event): void {

            //POSTリクエストを生成
            var getComment: URLRequest = new URLRequest(unescape(this._getflvAnalyzer.ms));
            getComment.method = "POST";
            getComment.requestHeaders = new Array(new URLRequestHeader("Content-Type", "text/html"));

            _apiGetThreadkeyAccess.close();

            //XMLを生成
            //var xml:String = "<thread fork=\"1\" user_id=\"" + user_id + "\" res_from=\"1000\" version=\"20061206\" thread=\"" + threadId + "\" />";
            var xml: XML = null;

            // 古い形式のコメント取得
            if (this._getflvAnalyzer.needs_key == 1 && !this._isOwnerComment) { // 投コメは取りに行かないよ

                var getThreadKeyResultAnalyzer: GetThreadKeyResultAnalyzer = new GetThreadKeyResultAnalyzer();
                getThreadKeyResultAnalyzer.analyze((event.currentTarget as ApiGetThreadkeyAccess).data);

                if (_useOldType) {
                    // 公式動画のコメント

                    /*
                      <thread
                    　thread="******" ← getflv で返ってくる thread_id を使用
                    　version="20061206"
                    　res_from="-1000"
                    　user_id="******" ← getflv で返ってくる user_id を使用
                    　threadkey="******" ← これ以降の属性は getthreadkey で返ってくる内容
                    　force_184="1"
                        　/>
                    */
                    xml = new XML("<thread />");
                    xml.@thread = this._getflvAnalyzer.threadId;
                    xml.@version = "20061206";
                    xml.@res_from = (this._count * -1);
                    xml.@user_id = this._getflvAnalyzer.userId;

                    for each(var key: String in getThreadKeyResultAnalyzer.getKeys()) {
                        xml.@[key] = getThreadKeyResultAnalyzer.getValue(key);
                    }

                    xml = new XML("<packet />").appendChild(xml);

                } else {
                    // 公式動画のコメント(新形式)

                    /*
                    <packet>
                        <thread thread="1313044774" version="20090904" user_id="nnn" threadkey="xxx" force_184="n"/>
                        <thread_leaves thread="1313044774" user_id="nnn" threadkey="xxx" force_184="n">0-24:100,1000</thread_leaves>
                    </packet>
                    */

                    xml = new XML("<packet />");

                    var thread: XML = new XML("<thread />");
                    thread.@thread = this._getflvAnalyzer.threadId;
                    thread.@version = "20090904";
                    thread.@user_id = this._getflvAnalyzer.userId;
                    for each(var key: String in getThreadKeyResultAnalyzer.getKeys()) {
                        thread.@[key] = getThreadKeyResultAnalyzer.getValue(key);
                    }

                    var thread_leaves: XML = new XML("<thread_leaves />");
                    thread_leaves.@thread = this._getflvAnalyzer.threadId;
                    thread_leaves.@user_id = this._getflvAnalyzer.userId;
                    for each(var key: String in getThreadKeyResultAnalyzer.getKeys()) {
                        thread_leaves.@[key] = getThreadKeyResultAnalyzer.getValue(key);
                    }
                    var l: int = int(this._getflvAnalyzer.l / 60) + 1;
                    thread_leaves.appendChild("0-" + l + ":100");

                    xml.appendChild(thread);
                    xml.appendChild(thread_leaves);
                }


            } else {

                if (_useOldType || this._when != null || this._isOwnerComment) {
                    // 古い形式、もしくは、過去コメント、投稿者コメントを取得したい時

                    // 普通のコメント

                    xml = new XML("<thread />");
                    xml.@res_from = (this._count * -1);
                    if (this._isOwnerComment) {
                        xml.@fork = 1;
                    }
                    xml.@version = "20061206";
                    xml.@thread = this._getflvAnalyzer.threadId;
                    xml.@user_id = this._getflvAnalyzer.userId;
                    if (this._when != null) {
                        //unix timeで指定
                        xml.@when = int(this._when.time / 1000);
                    }
                    if (this._waybackkey != null) {
                        xml.@waybackkey = this._waybackkey;
                    }

                    xml = new XML("<packet />").appendChild(xml);

                } else {

                    // 普通のコメント(新形式)

                    /*
                    <packet>
                    <thread thread="1313100893" version="20090904" user_id="nnn"/>
                    <thread_leaves thread="1313100893" user_id="nnn">0-8:100,500</thread_leaves>
                    </packet>
                    */


                    xml = new XML("<packet />");

                    var thread: XML = new XML("<thread />");
                    thread.@thread = this._getflvAnalyzer.threadId;
                    thread.@version = "20090904";
                    thread.@user_id = this._getflvAnalyzer.userId;

                    var thread_leaves: XML = new XML("<thread_leaves />");
                    thread_leaves.@thread = this._getflvAnalyzer.threadId;
                    thread_leaves.@user_id = this._getflvAnalyzer.userId;

                    var l: int = int(this._getflvAnalyzer.l / 60) + 1;
                    thread_leaves.appendChild("0-" + l + ":100");

                    xml.appendChild(thread);
                    xml.appendChild(thread_leaves);

                }
            }

            trace(xml);

            getComment.data = xml;

            this._commentLoader.dataFormat = URLLoaderDataFormat.TEXT;

            this._commentLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, function (event: HTTPStatusEvent): void {
                trace("Error: " + event.toString());
            });
            this._commentLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpResponseStatusEventHandler);
            this._commentLoader.addEventListener(Event.COMPLETE, commentGetSuccess);
            this._commentLoader.addEventListener(IOErrorEvent.IO_ERROR, errorEventHandler);
            this._commentLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorEventHandler);

            //読み込み開始
            this._commentLoader.load(getComment);

        }

        /**
         *
         * @param event
         *
         */
        private function httpResponseStatusEventHandler(event: HTTPStatusEvent): void {
            dispatchEvent(event);
        }

        /**
         *
         * @param event
         *
         */
        private function commentGetSuccess(event: Event): void {
            try {
                this._xml = new XML((event.currentTarget as URLLoader).data);

                var analyzer: CommentAnalyzer = new CommentAnalyzer();
                if (analyzer.analyze(xml, this._count)) {
                    this._commentAnalyzer = analyzer;

                    dispatchEvent(new Event(COMMENT_GET_SUCCESS));
                    return;
                }

            } catch (error: Error) {
                trace(error.getStackTrace());
            }
            dispatchEvent(new ErrorEvent(COMMENT_GET_FAIL, false, false, "fail:analyze"));

        }

        /**
         *
         * @param event
         *
         */
        private function errorEventHandler(event: ErrorEvent): void {
            dispatchEvent(new ErrorEvent(COMMENT_GET_FAIL, false, false, event.text));
            close();
        }

        /**
         * APIの結果から取得したメッセージサーバーのURLを返します。
         * @return
         *
         */
        public function get messageServerUrl(): String {
            return this._messageServerUrl;
        }

        /**
         * APIの結果から取得したuserIDを返します。
         * @return
         *
         */
        public function get userID(): String {
            return this._getflvAnalyzer.userId;
        }

        /**
         * APIの結果から取得したthreadIdを返します。
         * @return
         *
         */
        public function get threadId(): String {
            return this._getflvAnalyzer.threadId;
        }

        /**
         * APIアクセスの結果から現在エコノミーモードかどうかを返します。
         * @return エコノミーモードのときtrue
         *
         */
        public function get economyMode(): Boolean {
            if (this._getflvAnalyzer == null) {
                return false;
            }
            return this._getflvAnalyzer.economyMode;
        }

        /**
         *
         * @return
         *
         */
        public function get ngWords(): Vector.<NgUp> {
            return this._getflvAnalyzer.ng_ups;
        }

        /**
         * APIの結果から取得したプレミアム会員かどうかの情報を返します。
         * @return プレミアム会員の時はtrueを返す
         *
         */
        public function get isPremium(): Boolean {
            return this._getflvAnalyzer.isPremium;
        }

        /**
         *
         * @return
         *
         */
        public function close(): void {
            try {
                this._commentLoader.close();
            } catch (error: Error) {
            }
            try {
                this._apiGetThreadkeyAccess.close();
            } catch (error: Error) {
            }
            try {
                this._apiAccess.close();
            } catch (error: Error) {

            }
        }

        /**
         * このローダが取得したコメントの解析結果を返します
         * @return
         *
         */
        public function get commentAnalzyer(): CommentAnalyzer {
            return _commentAnalyzer;
        }

        /**
         * このローダーが取得したコメント(xml)を返します
         * @return
         *
         */
        public function get xml(): XML {
            return _xml;
        }

        /**
         * スレッドキー取得するAPIのURLを設定します
         * @param url
         *
         */
        public function set threadKeyAccessApiUrl(url: String): void {
            this._apiGetThreadkeyAccess.url = url;
        }

    }
}