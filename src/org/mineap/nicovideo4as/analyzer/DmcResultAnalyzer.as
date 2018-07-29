package org.mineap.nicovideo4as.analyzer {
    public class DmcResultAnalyzer {
        private var _result: Object;

        public function DmcResultAnalyzer() {
            /** do nothing */
        }

        /**
         * Analyze result from Dmc Session
         * @param result
         */
        public function analyze(result: String): void {
            this._result = JSON.parse(result);
        }

        public function get isValid(): Boolean {
            return this._result != null;
        }

        public function get sessionId(): String {
            return this._result.data.session.id;
        }

        public function get session(): Object {
            return this._result.data;
        }

        public function get contentUri(): String {
            return this._result.data.session.content_uri;
        }
    }
}
