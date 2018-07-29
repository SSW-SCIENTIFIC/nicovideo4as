package org.mineap.nicovideo4as.loader {
    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.net.URLRequest;

    /**
     * サムネイル画像を取得するクラスです。
     * 取得結果は、addEventListener()で登録したリスナから取得します。
     *
     * @author shiraminekeisuke
     *
     */
    public class ThumbImgLoader extends URLLoader {

        public function ThumbImgLoader(urlRequest: URLRequest = null) {
            if (urlRequest != null) {
                this.load(urlRequest);
            }
        }

        /**
         * 指定されたThumbImgUrlにバイナリモードでアクセスします。
         * @param thumbImgUrl
         *
         */
        public function getThumbImgByUrl(thumbImgUrl: String): void {
            var request: URLRequest = new URLRequest(thumbImgUrl);

            this.dataFormat = URLLoaderDataFormat.BINARY;

            this.load(request);
        }

    }
}