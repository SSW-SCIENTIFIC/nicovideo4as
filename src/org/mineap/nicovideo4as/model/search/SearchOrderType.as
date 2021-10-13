package org.mineap.nicovideo4as.model.search {
    public class SearchOrderType {
        /**
         * 昇順
         */
        public static const ASCENDING: SearchOrderType = new SearchOrderType("+");

        /**
         * 降順
         */
        public static const DESCENDING: SearchOrderType = new SearchOrderType("-");

        private var _orderString: String;

        public function SearchOrderType(value: String) {
            _orderString = value;
        }

        public function get orderStr(): String {
            return _orderString;
        }
    }
}