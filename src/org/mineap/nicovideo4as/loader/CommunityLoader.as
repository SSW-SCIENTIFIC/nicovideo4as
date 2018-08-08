package org.mineap.nicovideo4as.loader {
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.net.URLVariables;

    /**
     * コミュニティ動画一覧の取得を行うクラス
     *
     * @author SSW-SCIENTIFIC <S-sword@s-sword.net>
     *
     */
    public class CommunityLoader extends URLLoader {

        public static const COMMUNITY_PAGE_URL: String = "https://ch.nicovideo.jp/video/";

        /**
         *
         * @param request
         *
         */
        public function CommunityLoader(request: URLRequest = null) {
            super(request);
        }

        /**
         *
         * @param communityId
         * @param page
         *
         */
        public function getCommunity(communityId: String, page: int = 0): void {

            var url: String = COMMUNITY_PAGE_URL + communityId;

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