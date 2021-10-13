package org.mineap.nicovideo4as.analyzer {
    import org.mineap.nicovideo4as.model.search.SearchResultItem;

    /**
     *
     * @author shiraminekeisuke
     *
     */
    public class SearchResultAnalyzer {

        private var _totalCount: int;
        private var _itemList: Vector.<SearchResultItem> = new Vector.<SearchResultItem>();
        private var _status: String;

        public function SearchResultAnalyzer(data: String) {

            var jsonData: Object = JSON.parse(data);

            this._totalCount = jsonData.meta.totalCount;

            var list: Array = jsonData.data;

            for each(var obj: Object in list) {
                //　説明文
                var description: String = obj.description;

                // 投稿日 (yyyy-mm-dd hh:dd:ss)
                var first_retrieve: String = obj.startTime.replace(/^(\d{4})-(\d{2})-(\d{2})T(\d{2}:\d{2}:\d{2})[-+].+/, "$1年$2月$3日 $4");

                // 動画ID
                var videoId: String = obj.contentId;

                // 直近のコメント数件
                var lastResBody: String = obj.lastResBody;

                // 再生時間("6:28")
                var lengthStr: String = Math.floor(obj.lengthSeconds / 60) + ":" + ("0" + obj.lengthSeconds % 60).slice(-2);

                // マイリスト数
                var myListCount: int = obj.mylistCounter;

                // コメント数
                var resCount: int = obj.commentCounter;

                // サムネイル画像URL
                var thumbUrl: String = obj.thumbnailUrl;

                // タイトル
                var title: String = obj.title;

                // 再生数
                var view_counter: int = obj.viewCounter;

                var item: SearchResultItem = new SearchResultItem(title, videoId, thumbUrl, first_retrieve, view_counter, myListCount, resCount, lengthStr, lastResBody);

                this._itemList.push(item);
            }

            this._status = jsonData.status;

        }


        public function get status(): String {
            return _status;
        }

        public function get itemList(): Vector.<SearchResultItem> {
            return _itemList;
        }

        public function get totalCount(): int {
            return _totalCount;
        }

    }
}