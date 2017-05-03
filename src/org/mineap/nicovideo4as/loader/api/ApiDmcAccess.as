package org.mineap.nicovideo4as.loader.api
{
import flash.events.Event;
import flash.net.URLLoader;
    import flash.net.URLRequest;
import flash.net.URLRequestHeader;
import flash.net.URLVariables;
import flash.utils.setInterval;

public class ApiDmcAccess extends URLLoader {
        private var movieId: String;
        private var apiUrl: String;

        public function ApiDmcAccess(request:URLRequest = null)
        {
            super(request);
        }

        public function createDmcSession(movieId: String, apiUrl: String, session: Object): void
        {
            var getAPIRequest:URLRequest;

            this.movieId = movieId;
            this.apiUrl = apiUrl;

            getAPIRequest = new URLRequest(apiUrl + "/?_format=json");
            getAPIRequest.method = "POST";
            getAPIRequest.data = JSON.stringify(session);
            getAPIRequest.requestHeaders = [
                new URLRequestHeader("Accept", "application/json"),
                new URLRequestHeader("Content-Type", "application/json"),
                new URLRequestHeader("Referer", "http://www.nicovideo.jp/watch/" + movieId),
                new URLRequestHeader("Origin", "http://www.nicovideo.jp")
            ];
            getAPIRequest.manageCookies

            this.load(getAPIRequest);
        }

        public function beatDmcSession(sessionId: String, session: Object): void
        {
            var getAPIRequest:URLRequest;

            getAPIRequest = new URLRequest(this.apiUrl + "/" + sessionId + "?_format=json&_method=PUT");
            getAPIRequest.method = "POST";
            getAPIRequest.data = JSON.stringify(session);
            getAPIRequest.requestHeaders = [
                new URLRequestHeader("Accept", "application/json"),
                new URLRequestHeader("Content-Type", "application/json"),
                new URLRequestHeader("Referer", "http://www.nicovideo.jp/watch/" + this.movieId),
                new URLRequestHeader("Origin", "http://www.nicovideo.jp")
            ];

            this.load(getAPIRequest);
        }
    }
}
