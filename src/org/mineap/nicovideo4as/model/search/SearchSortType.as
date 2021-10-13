package org.mineap.nicovideo4as.model.search {
    /**
     * SearchSortType.as<br>
     * SearchSortTypeクラスは、検索結果のソート順に関する定数を保持するクラスです。<br>
     * <br>
     * Copyright (c) 2013 MAP - MineApplicationProject. All Rights Reserved.<br>
     *
     * @author shiraminekeisuke(MineAP)
     *
     */
    public class SearchSortType {

        /**
         * 最新のコメント
         */
        public static const NEW_COMMENT: SearchSortType = new SearchSortType("lastCommentTime");

        /**
         * 再生数
         */
        public static const VIEW_COUNTER: SearchSortType = new SearchSortType("viewCounter");

        /**
         * マイリスト数
         */
        public static const MYLIST_COUNTER: SearchSortType = new SearchSortType("mylistCounter");

        /**
         * コメント数
         */
        public static const NUM_RES: SearchSortType = new SearchSortType("commentCounter");

        /**
         * 投稿日
         */
        public static const FIRST_RETRIVE: SearchSortType = new SearchSortType("startTime");

        /**
         * 動画の再生時間
         */
        public static const LENGTH: SearchSortType = new SearchSortType("lengthSeconds");

        private var _sort: String;

        /**
         *
         * @param sort
         *
         */
        public function SearchSortType(sort: String) {
            this._sort = sort;
        }

        public function get sortTypeString(): String {
            return this._sort;
        }
    }
}