package org.mineap.nicovideo4as.analyzer {
    public class WatchDataAnalyzer {
        private var _result: Object;

        public function WatchDataAnalyzer() {
            /** do nothing */
        }

        /**
         * Analyze WatchAPI Data Container JSON
         * @param result WatchAPIDataContainer Stringified JSON
         */
        public function analyze(result: Object): void {
//        this._result = JSON.parse(result);
            this._result = Object;
        }

        /**
         * @return Boolean is dmc enabled or not
         */
        public function isDmc(): Boolean {
            return this._result.flashvars.isDmc;
        }

        public function getDmcInfo(): String {
            return this._result.flashvars.dmcInfo;
        }
    }
}
