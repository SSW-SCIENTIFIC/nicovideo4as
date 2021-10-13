package org.mineap.nicovideo4as.loader.api {
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.net.URLVariables;

    import org.mineap.nicovideo4as.model.search.SearchOrderType;
    import org.mineap.nicovideo4as.model.search.SearchSortType;
    import org.mineap.nicovideo4as.model.search.SearchType;

    public class ApiSearchAccess extends URLLoader {
        public static const SEARCH_API_ACCESS_URL: String = "https://api.search.nicovideo.jp/api/v2/snapshot/video/contents/search";

        public function ApiSearchAccess(request: URLRequest = null) {
            super(request);
        }

        public function search(type: SearchType, target: String, page: int, sort: SearchSortType, order: SearchOrderType): void {

            var variables: URLVariables = new URLVariables();
            variables.q = target;
            variables.targets = type.typeString;
            variables.fields = "description,startTime,contentId,lastResBody,lengthSeconds,mylistCounter,commentCounter,thumbnailUrl,title,viewCounter";
            variables._sort = order.orderStr + sort.sortTypeString;
            variables._offset = page;
            variables._limit = 100;
            variables._context = "niconico-lib";

            var req: URLRequest = new URLRequest(SEARCH_API_ACCESS_URL);
            req.data = variables;
            req.method = "GET";

            this.load(req);

        }

    }
}