package org.mineap.nicovideo4as.stream {
    import flash.net.URLRequest;
    import flash.net.URLRequestHeader;
    import flash.net.URLStream;
    import flash.net.URLVariables;

    import org.mineap.nicovideo4as.model.VideoType;

    /**
     * ニコニコ動画から動画をストリームするためのクラスです。
     *
     * @author shiraminekeisuke(MineAP)
     *
     */
    public class VideoStream extends URLStream {

        private var _videoType: VideoType = null;

        public function VideoStream() {
            super();
        }

        public function get videoType(): VideoType {
            return _videoType;
        }

        /**
         * 指定されたURLから動画をロードします。
         *
         * @param url
         * @param start
         * @param end
         * @see URLStream#load(URLRequest)
         */
        public function getVideoStart(url: String, start: Number = 0, end: Number = 0): void {

            this._videoType = checkVideoType(url);

            var request: URLRequest = new URLRequest(url);
            if (start !== 0 || end !== 0) {
                request.requestHeaders = [new URLRequestHeader("Range", "bytes=" + start + "-" + (end > 0 ? end : ""))];
            }

            super.load(request);
        }

        /**
         * 指定されたURLリクエストを使って動画をロードします。
         *
         * @param request
         * @see URLStream#load(URLRequest)
         */
        public function getVideoStartByRequest(request: URLRequest): void {
            this._videoType = checkVideoType(request.url);

            super.load(request);
        }

        /**
         *
         * @param url
         * @return
         *
         */
        public static function checkVideoType(url: String): VideoType {
            if (url.indexOf("smile?m=") != -1) {
                return VideoType.VIDEO_TYPE_MP4;
            } else if (url.indexOf("smile?v=") != -1) {
                return VideoType.VIDEO_TYPE_FLV;
            } else if (url.indexOf("smile?s=") != -1) {
                return VideoType.VIDEO_TYPE_SWF;
            }

            return null;
        }

    }
}