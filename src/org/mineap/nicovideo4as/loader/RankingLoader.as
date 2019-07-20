package org.mineap.nicovideo4as.loader {
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.HTTPStatusEvent;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.net.URLRequest;
    import flash.net.URLVariables;

    import org.mineap.nicovideo4as.model.NicoRankingUrl;

    /**
     * ニコニコ動画のランキングRSSへのアクセスを担当するクラスです。
     *
     * @author shiraminekeisuke(MineAP)
     */
    public class RankingLoader extends URLLoader {

        /**
         *
         * @param request
         *
         */
        public function RankingLoader(request: URLRequest = null) {
            if (request != null) {
                this.load(request);
            }
        }

        /**
         * 指定された期間、種別からURLを生成し、ランキングにアクセスします。
         * 期間、種別は{@link NicoRankingUrl}を参照してください。
         *
         * @param term NicoRankingUrlクラスの期間に関するプロパティを参照してください。
         * @param genre カテゴリを表す文字列を指定します。例えば"all"や"music"です。デフォルトではall（総合）です。
         * @param tag
         * @param pageCount ページ番号 「?page=」の後に付ける数字を指定します。0および1の場合は1ページ目です。デフォルトでは1です。
         *
         */
        public function getRanking(term: String, genre: String = "all", tag: String = null, pageCount: int = 1): void {
            var request: URLRequest = new URLRequest(NicoRankingUrl.getNicoRankingUrl(genre, term, tag, true));

            var variables: URLVariables = new URLVariables();
            if (pageCount > 1) {
                variables.page = pageCount;
            }

            request.data = variables;
            this.load(request);
        }
    }
}