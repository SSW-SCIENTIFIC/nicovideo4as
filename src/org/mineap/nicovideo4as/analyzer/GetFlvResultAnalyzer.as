package org.mineap.nicovideo4as.analyzer {
    import flash.net.URLVariables;

    import org.mineap.nicovideo4as.model.NgUp;
    import org.mineap.nicovideo4as.util.HtmlUtil;

    /**
     * getFlvの応答を解析するためのクラスです。
     *
     * @author shiraminekeisuke(MineAP)
     *
     */
    public class GetFlvResultAnalyzer {

        /**
         * スレッドID
         */
        public static const THREAD_ID_KEY: String = "thread_id";

        /**
         * 長さ
         */
        public static const L_KEY: String = "l";

        /**
         * 動画へのURL
         */
        public static const VIDEO_URL_KEY: String = "url";

        /**
         * 当該動画のSmileVideoへのリンク
         */
        public static const SMILE_VIDEO_LINK_KEY: String = "link";

        /**
         * メッセージサーバのURL
         */
        public static const MESSAGE_SERVER_URL_KEY: String = "ms";

        /**
         * ユーザーID
         */
        public static const USER_ID_KEY: String = "user_id";

        /**
         * プレミアム会員かどうか
         */
        public static const IS_PREMIUM_KEY: String = "is_premium";

        /**
         * ニックネーム
         */
        public static const NICK_NAME_KEY: String = "nickname";

        /**
         * 時刻
         */
        public static const TIME_KEY: String = "time";

        /**
         * done
         */
        public static const DONE_KEY: String = "done";

        /**
         * needs_key
         */
        public static const NEEDS_KEY_KEY: String = "needs_key";

        /**
         * optional_thread_id
         */
        public static const OPTIONAL_THREAD_ID_KEY: String = "optional_thread_id";

        /**
         * feedrev
         */
        public static const FEED_REV_KEY: String = "feedrev";

        /**
         * ng_up
         */
        public static const NG_UP_KEY: String = "ng_up";

        /**
         * エコノミーモード(低画質モード)の検出
         */
        public static const LOW_MODE: String = "low";


        /**
         * FMSに接続するためのトークン
         */
        public static const FMS_TOKEN: String = "fmst";

        private var _threadId: String = null;

        private var _l: Number = 0;

        private var _url: String = null;

        private var _link: String = null;

        private var _ms: String = null;

        private var _userId: String = null;

        private var _isPremium: Boolean = false;

        private var _nickName: String = null;

        private var _time: Number = 0;

        protected var _done: Boolean = false;

        private var _needs_key: int = 0;

        private var _optional_thread_id: String = null;

        private var _feedrev: String = null;

        private var _ng_ups: Vector.<NgUp> = new Vector.<NgUp>();

        private var _economyMode: Boolean = false;

        private var _result: String = null;

        private var _fmsToken: String = null;

        /**
         * コンストラクタ
         *
         */
        public function GetFlvResultAnalyzer() {
            /* nothing */
        }

        /**
         * 渡されたString表現をgetflvの応答として解析します。
         *
         * @param result getflvの応答
         * @return 解析に成功した場合はtrue、失敗した場合はfalse。
         *
         */
        public function analyze(result: String): Boolean {

            try {

                if (result.indexOf("%") != -1) {
                    // "%"が含まれていればデコード
                    result = decodeURIComponent(unescape(result));
                }
                if (result.indexOf("\\u") != -1) {
                    result = HtmlUtil.convertCharacterCodeToCharacter(result);
                }

                trace(result);

                this._result = result;
                var variables: URLVariables = new URLVariables(result);

                /*
                thread_id=1173206704
                &l=111
                &url=http://smile-pcm31.nicovideo.jp/smile?v=8702.9279
                &link=http://www.smilevideo.jp/view/8702/573999
                &ms=http://msg.nicovideo.jp/7/api/
                &user_id=*****
                &is_premium=1
                &nickname=*****
                &time=1281958264
                &done=true
                &needs_key=1	//公式の時のみ？
                &optional_thread_id=1254473671	//公式の時のみ？
                &feedrev=b852b	//公式の時のみというわけではない？
                &ng_up=*はー=はあああああああああああああああああああああああああああああ
                &*どー=どおおおおおおおおおおおおおおおおおおおおおおおおおおおおお
                &*らっちー=らっち～☆ミ　らっち～☆ミ
                &*つー=つううううううううううううううううううううううううううううううううううううううううう
                &hms=hiroba04.nicovideo.jp
                &hmsp=2527
                &hmst=1000000063
                &hmstk=1281958324.YAVXxEJhyWLGc5RvDqju57Gtwec
                &rpu={"count":924888,
                    "users":["\u30d2\u30c0\u30de\u30eaX",
                        "hifumy1",
                        "\u30d7\u30b8\u30e7\u30eb",
                        "ryu",
                        "\uff26\uff41\uff4e\uff54\uff41\uff53\uff49\uff45",
                        "\u66b4\u8d70",
                        "shutter-speeds72",
                        "\u305f\u308d",
                        "\u30ea\u30b9\u30c8",
                        "\u3086\u3048\u3053",
                        "Cocoon",
                        "\u59d0\u5fa1",
                        "\uff08\u00b0\u2200\uff9f\uff09",
                        "\u30ed\u30c3\u30af",
                        "\u30ca\u30eb\u30ab\u30ca\u69d8",
                        "Ash",
                        "\u307e\u308a\u3079\u3047",
                        "\u60e3\u6d41\u30a2\u30b9\u30ab",
                        "\u3057\u3087\u3046\u305f\u308b",
                        "ginzuisyoufox"],
                        "extra":13}
                */

                this._threadId = variables[THREAD_ID_KEY];
                this._l = variables[L_KEY];
                this._url = variables[VIDEO_URL_KEY];
                if (url != null && this._url.indexOf(LOW_MODE) != -1) {
                    this._economyMode = true;
                }
                this._link = variables[SMILE_VIDEO_LINK_KEY];
                this._ms = variables[MESSAGE_SERVER_URL_KEY];
                this._userId = variables[USER_ID_KEY];
                var isPremiumStr: String = variables[IS_PREMIUM_KEY];
                if (isPremiumStr != null && (isPremiumStr == "1" || isPremiumStr.toLowerCase() == "true")) {
                    this._isPremium = true;
                } else {
                    this._isPremium = false;
                }
                this._nickName = variables[NICK_NAME_KEY];
                this._time = Number(variables[TIME_KEY]);
                var doneStr: String = variables[DONE_KEY];
                if (doneStr != null && doneStr.toLowerCase() == "true") {
                    this._done = true;
                } else {
                    this._done = false;
                }
                this._needs_key = int(variables[NEEDS_KEY_KEY]);
                this._optional_thread_id = variables[OPTIONAL_THREAD_ID_KEY];
                this._feedrev = variables[FEED_REV_KEY];

                for (var key: String in variables) {
                    var ngword: String = null;
                    var changedStr: String = null;

                    if (NG_UP_KEY == key) {
                        ngword = variables[key];
                        // ngword="*はー=はあああああああああああああああああああああああああああああ"
                        var index: int = ngword.indexOf("=");
                        if (index < 0) {
                            continue;
                        }
                        changedStr = ngword.substr(index + 1);
                        ngword = ngword.substring(1, index);
                    } else if (key.charAt(0) == "*") {
                        ngword = key.substr(1);
                        changedStr = variables[key];
                        // key = "*らっちー"
                        // changedStr = "らっち～☆ミ　らっち～☆ミ"

                    }

                    if (ngword != null && changedStr != null) {
                        this._ng_ups.push(new NgUp(ngword, changedStr));
                    }
                }

                this._fmsToken = variables[FMS_TOKEN];

                return true;

            } catch (error: Error) {
                trace(error.getStackTrace());
            }
            return false;
        }

        public function get done(): Boolean {
            return _done;
        }

        public function get time(): Number {
            return _time;
        }

        public function get nickName(): String {
            return _nickName;
        }

        public function get isPremium(): Boolean {
            return _isPremium;
        }

        public function get userId(): String {
            return _userId;
        }

        public function get ms(): String {
            return _ms;
        }

        public function get link(): String {
            return _link;
        }

        public function get url(): String {
            return _url;
        }

        public function get l(): Number {
            return _l;
        }

        public function get threadId(): String {
            return _threadId;
        }

        public function get result(): String {
            return _result;
        }

        public function get needs_key(): int {
            return _needs_key;
        }

        public function get optional_thread_id(): String {
            return _optional_thread_id;
        }

        public function get feedrev(): String {
            return _feedrev;
        }

        public function get ng_ups(): Vector.<NgUp> {
            return _ng_ups;
        }

        public function get economyMode(): Boolean {
            return _economyMode;
        }

        public function get fmsToken(): String {
            return _fmsToken;
        }


    }
}