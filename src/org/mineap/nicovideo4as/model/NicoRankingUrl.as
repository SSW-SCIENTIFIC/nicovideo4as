package org.mineap.nicovideo4as.model {
    /**
     * ランキングのURLに関する定数を保持するクラスです。
     *
     * @author shiraminekeisuke
     *
     */
    public class NicoRankingUrl {

        /**
         * 毎日(期間)
         */
        public static const DAILY: String = "24h";

        /**
         * 週間(期間)
         */
        public static const WEEKLEY: String = "week";

        /**
         * 月間(期間)
         */
        public static const MONTHLY: String = "month";

        /**
         * 毎時(期間)
         */
        public static const HOURLY: String = "hour";

        /**
         * 合計(期間)
         */
        public static const TOTAL: String = "total";

        /**
         * 新着(期間)
         */
        public static const NEW_ARRIVAL: String = "new_arrival";

        /**
         * ニコニコ動画ランキングのURL取得メソッド.
         * @see https://dwango.github.io/niconico/genre_ranking/ranking_rss/
         * @param genre ランキングを取得するジャンル名, 旧ランキング(-2019/06)のカテゴリ名に相当すると思われる
         * @param term 集計期間の定数
         * @param tag 集計対象のタグ名, 選択可能なタグ名を取得する方法が分からない(2019/07/20)
         * @param is_rss RSSとして取得するかどうか
         * @return 指定された条件のランキングRSSのURL
         */
        public static function getNicoRankingUrl(genre: String, term: String, tag: String = null, is_rss: Boolean = true): String
        {
            if (genre === null || genre === "") {
                return "https://www.nicovideo.jp/ranking/";
            }

            var options: Array = is_rss ? ["rss=2.0", "lang=ja-jp"] : [];
            if (tag !== null) {
                options.push("tag=" + tag);
            }
            if (term !== null && term !== NEW_ARRIVAL) {
                options.push("term=" + term);
            }

            switch (term) {
                case NEW_ARRIVAL:
                    return "https://www.nicovideo.jp/newarrival/?" + options.join("&");
                default:
                    return "https://www.nicovideo.jp/ranking/genre/" + genre + "?" + options.join("&");
            }
        }
    }
}