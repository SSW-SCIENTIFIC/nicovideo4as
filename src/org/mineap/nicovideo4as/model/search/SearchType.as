package org.mineap.nicovideo4as.model.search {
    /**
     * SearchType.as<br>
     * SearchTypeクラスは、検索種別を表す定数を保持するクラスです。<br>
     * <br>
     * Copyright (c) 2009 MAP - MineApplicationProject. All Rights Reserved.<br>
     *
     * @author shiraminekeisuke
     *
     */
    public class SearchType {
        /**
         * 検索種別がキーワードによる検索である事を表す定数です
         */
        public static const SEARCH: SearchType = new SearchType("title,description,tags");
        /**
         * 検索種別がタグによる検索である事を表す定数です
         */
        public static const TAG: SearchType = new SearchType("tagsExact");

        private var _type: String;

        public function SearchType(value: String) {
            this._type = value;
        }

        public function get typeString(): String {
            return this._type;
        }


    }
}