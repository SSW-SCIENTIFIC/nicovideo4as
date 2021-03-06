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

            this._totalCount = jsonData.count;

            var list: Array = jsonData.list;

            for each(var obj: Object in list) {
                //　説明文
                var description: String = obj.description_short;

                // 投稿日 (yyyy-mm-dd hh:dd:ss)
                var first_retrieve: String = obj.first_retrieve;

                // 動画ID
                var videoId: String = obj.id;

                // 直近のコメント数件
                var lastResBody: String = obj.last_res_body;

                // 再生時間("6:28")
                var lengthStr: String = obj.length;

                // マイリスト数
                var myListCount: int = obj.mylist_counter;

                // コメント数
                var resCount: int = obj.num_res;

                // サムネイル画像URL
                var thumbUrl: String = obj.thumbnail_url;

                // タイトル
                var title: String = obj.title;

                // 再生数
                var view_counter: int = obj.view_counter;

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