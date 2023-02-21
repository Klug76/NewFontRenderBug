package
{
	import com.gs.utils.IItemCollection;

	public class TestItemList implements IItemCollection
	{
		private static const data: String = "アルファ,アメジスト,エンジェル,アトラス,アキコ,バーニー,ブレイド,ブルース,バブルス,ベイビー,カルビン,キャロット,チャーリー,シャルロット,チヒロ,デイジー,ダニー,ダグラス,ドメニク,ダリル,エルヴィス,エドガー,エッジ,エマ,エミリー,フィシー,フランキー,フレッジ,フェンネル,フェイ,ジェネラル,ジョージ,ギルバート,グロリア,ガーベラ,ハリー,ヒーロー,ハイドラ,ヒルトン,ハルカ,アイリス,イオリ,ジョーズ,ジェリー,ジョン,ジュリー,ジン,キアーラ,キーノ,キョウ,ラリー,ルイ,リン,マーブル,マシュマロ,マックス,マミ,ニモ,ナポレオン,ナナ,ノーブル,オットー,オサム,パティ,ピエロ,パラシオ,キュビー,ルリ,ロザリオ,サルサ,セバスチャン,シリカ,タマ,タンゴ,テトラ,トゥインクル,テツヤ,ベルベット,ビクトリア,ウィーゼル,シア,ヤン"
		private var data_: Array;

		public function TestItemList()
		{
			data_ = data.split(",");
		}

		public function get_Data(index: int): String
		{
			return data_[index % data_.length];
		}


		public function get count():int
		{
			return 1000;
		}

	}

}