package org.mineap.nicovideo4as.analyzer {
    import org.mineap.nicovideo4as.WatchVideoPage;

    public class WatchDataAnalyzer {
        private var _result: Object;
        private var _isHTML5: Boolean = true;
        private var _done: Boolean = false;

        public function WatchDataAnalyzer() {
            /** do nothing */
        }

        /**
         * Analyze WatchAPI Data Container JSON
         * @param result WatchVideoPage
         */
        public function analyze(result: WatchVideoPage): void {
            this._result = result.jsonData;
            this._isHTML5 = result.isHTML5;
            this._done = true;
        }

        public function get data(): Object {
            return this._result;
        }
    }
}
