package org.mineap.nicovideo4as.loader {
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.net.URLVariables;

    /**
     * チャンネルの取得を行うクラスです。
     *
     * @author shiraminekeisuke(MineAP)
     *
     */
    public class ChannelLoader extends URLLoader {

        public static const CHANNEL_PAGE_URL: String = "https://ch.nicovideo.jp/video/";

        /**
         *
         * @param request
         *
         */
        public function ChannelLoader(request: URLRequest = null) {
            super(request);
        }

        /**
         *
         * @param channelId
         *
         */
        public function getChannel(channelId: String, page: int = 0): void {

            var url: String = CHANNEL_PAGE_URL + channelId;

            var variables: URLVariables = new URLVariables();
            variables.rss = "2.0";
            if (page > 0) {
                variables.page = page;
            }

            var request: URLRequest = new URLRequest(url);
            request.data = variables;

            this.load(request);

        }


    }
}