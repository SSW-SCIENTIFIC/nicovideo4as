package org.mineap.nicovideo4as.model {
    public class Comment {

        private var _vpos: Number = 0;

        private var _text: String = "";

        private var _mail: String = "";

        private var _user_id: String = "";

        private var _no: Number = 0;

        private var _thread: String = "";

        private var _date: Number = 0;

        public function Comment(vpos: Number, text: String, mail: String, user_id: String, no: Number, thread: String, date: Number) {

            this._vpos = vpos;
            this._text = text;
            this._mail = mail;
            this._user_id = user_id;
            this._no = no;
            this._thread = thread;
            this._date = date;

        }

        public function get date(): Number {
            return _date;
        }

        public function get thread(): String {
            return _thread;
        }

        public function get no(): Number {
            return _no;
        }

        public function get user_id(): String {
            return _user_id;
        }

        public function get mail(): String {
            return _mail;
        }

        public function get text(): String {
            return _text;
        }

        public function set text(value: String): void {
            _text = value;
        }

        public function get vpos(): Number {
            return _vpos;
        }

    }
}