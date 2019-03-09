package org.mineap.nicovideo4as.analyzer {
    import mx.controls.DateField;

    import org.mineap.nicovideo4as.model.NgUp;

    public class WatchDataAnalyzerGetFlvAdapter extends GetFlvResultAnalyzer {
        private var watchDataAnalyzer: WatchDataAnalyzer;
        private var getflvResultAnalyzer: GetFlvResultAnalyzer;

        public function WatchDataAnalyzerGetFlvAdapter() {
            // do nothing
        }

        public function wrap(watch: WatchDataAnalyzer, getflv: GetFlvResultAnalyzer = null): void {
            this.watchDataAnalyzer = watch;
            this.getflvResultAnalyzer = getflv;
            this._done = true;
        }

        override public function analyze(result: String): Boolean {
            super.analyze(result);
            this.watchDataAnalyzer = null;
            this.getflvResultAnalyzer = this;
            return true;
        }

        override public function get time(): Number {
            if (this.watchDataAnalyzer) {
                return Date.parse(this.watchDataAnalyzer.data.video.postedDateTime) / 1000;
            }

            if (this.getflvResultAnalyzer) {
                return this.getflvResultAnalyzer.time;
            }

            return 0;
        }

        override public function get nickName(): String {
            if (this.watchDataAnalyzer) {
                if (this.watchDataAnalyzer.data.owner) {
                    return this.watchDataAnalyzer.data.owner.nickname;
                }
                if (this.watchDataAnalyzer.data.channel) {
                    return this.watchDataAnalyzer.data.channel.name;
                }
                if (this.watchDataAnalyzer.data.community) {
                    return this.watchDataAnalyzer.data.community.name;
                }
            }

            if (this.getflvResultAnalyzer) {
                return this.getflvResultAnalyzer.nickName;
            }

            return "";
        }

        override public function get isPremium(): Boolean {
            if (this.watchDataAnalyzer) {
                return this.watchDataAnalyzer.data.viewer.isPremium;
            }

            if (this.getflvResultAnalyzer) {
                return this.getflvResultAnalyzer.isPremium;
            }

            return false;
        }

        override public function get userId(): String {
            if (this.watchDataAnalyzer) {
                var target: Object = this.watchDataAnalyzer.data.owner || this.watchDataAnalyzer.data.channel || this.watchDataAnalyzer.data.community;
                return target.id;
            }

            if (this.getflvResultAnalyzer) {
                return this.getflvResultAnalyzer.userId;
            }

            return "";
        }

        override public function get ms(): String {
            if (this.watchDataAnalyzer) {
                return this.watchDataAnalyzer.data.thread.serverUrl;
            }

            if (this.getflvResultAnalyzer) {
                return this.getflvResultAnalyzer.ms;
            }

            return "";
        }

        override public function get link(): String {
            return "";
        }

        override public function get url(): String {
            if (this.watchDataAnalyzer) {
                return this.watchDataAnalyzer.data.video.smileInfo.url;
            }

            if (this.getflvResultAnalyzer) {
                return this.getflvResultAnalyzer.url;
            }
            return "";
        }

        override public function get l(): Number {
            if (this.watchDataAnalyzer) {
                return this.watchDataAnalyzer.data.video.duration;
            }

            if (this.getflvResultAnalyzer) {
                return this.getflvResultAnalyzer.l;
            }

            return -1;
        }

        override public function get threadId(): String {
            if (this.watchDataAnalyzer) {
                return this.watchDataAnalyzer.data.thread.ids.community ||
                       this.watchDataAnalyzer.data.thread.ids["default"] ||
                       this.watchDataAnalyzer.data.thread.ids.nicos;
            }

            if (this.getflvResultAnalyzer) {
                return this.getflvResultAnalyzer.threadId;
            }

            return "";
        }

        override public function get needs_key(): int {
            if (this.watchDataAnalyzer) {
                return this.watchDataAnalyzer.data.commentComposite.threads.some(function (element: Object, index:int, arr:Array): Boolean {
                    return element.isDefaultPostTarget === true && element.isThreadkeyRequired === true;
                }) ? 1 : 0;
            }

            if (this.getflvResultAnalyzer) {
                return this.getflvResultAnalyzer.needs_key;
            }

            return 0;
        }

        override public function get optional_thread_id(): String {
            if (this.watchDataAnalyzer) {
                return this.watchDataAnalyzer.data.thread.ids["default"];
            }

            if (this.getflvResultAnalyzer) {
                return this.getflvResultAnalyzer.optional_thread_id;
            }

            return "";
        }

        override public function get feedrev(): String {
            return "";
        }

        override public function get ng_ups(): Vector.<NgUp> {
            return new Vector.<NgUp>();
        }

        override public function get economyMode(): Boolean {
            return false;
        }

        override public function get fmsToken(): String {
            return "";
        }
    }
}
