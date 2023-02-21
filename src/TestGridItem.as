package
{
	import com.gs.ui.EventButtonClick;
	import com.gs.ui.KCss;
	import com.gs.ui.IGridItemView;
	import com.gs.ui.KButton;
	import com.gs.ui.KLabel;
	import com.gs.ui.KVisel;
	import com.gs.ui.TAlign;
	import com.gs.utils.IItemCollection;
	import flash.display.BlendMode;
	import flash.display.DisplayObjectContainer;

	public class TestGridItem extends KVisel implements IGridItemView
	{
		private var label_aux_: KLabel;
		private var label_name_: KLabel;
		private var button_buy_: KButton;
		static private var css_: KCss;

		public function TestGridItem(owner: DisplayObjectContainer)
		{
			super(owner);
			dummy_color = 0x4Ab2cE;
			blendMode = BlendMode.NORMAL;

			var factor : Number = KVisel.hi_res_factor_;
			if (null == css_)
			{
				css_ = new KCss(factor, false);
				css_.setStyle("h1", { fontSize:12, color:'#88FF88', textAlign:'center', fontWeight:"bold" } );
				css_.setStyle("h2", { fontSize:16, color:'#ffff00', fontWeight:"bold" } );
				css_.setStyle("h3", { fontSize:16, color:'#00ffff', fontWeight:"bold" } );
				css_.setStyle("h4", { fontSize:14, color:'#ffffff', textAlign:'center', fontWeight:"bold" } );
				css_.setStyle("h6", { fontSize:18, color:'#ffffff', textAlign:'center', fontWeight:"bold" } );
				css_.setStyle("h8", { fontSize:12, color:'#FF6600', textAlign:'center', fontWeight:"bold" } );
				css_.setStyle("h9", { fontSize:16, color:'#00ff00', fontWeight:"bold" } );
				css_.setStyle("hd", { fontSize:16, color:'#ffffff', textAlign:'center', fontWeight:"bold" } );
			}


			label_name_ = new KLabel(this);
			label_name_.text_Field.multiline = true;
			label_name_.text_Field.wordWrap = true;
			label_name_.text_Field.condenseWhite = false;
			label_name_.css = css_;
			label_name_.h_align = TAlign.NEAR;
			label_name_.v_align = TAlign.NEAR;
			//label_name_.text = "<h4>Foo<br>購入</h4>";

			label_aux_ = new KLabel(this);
			label_aux_.h_align = TAlign.NEAR;
			label_aux_.v_align = TAlign.NEAR;
			label_aux_.css = css_;
			label_aux_.text_Field.condenseWhite = false;
			label_aux_.auto_size = true;
			label_aux_.visible = false;


			button_buy_ = new KButton(this, "", on_Buy_Item_Click);
			button_buy_.css = css_;
			with (button_buy_.label.text_Field)
			{
				condenseWhite = false;
				multiline = true;
				wordWrap = true;
			}

			cacheAsBitmap = true;
		}
//.............................................................................
		private function on_Buy_Item_Click(e: EventButtonClick): void
		{
		}
//.............................................................................
		public function resize_Item(nx: Number, ny: Number, w: Number, h: Number): void
		{
			movesize(nx, ny, w, h);
			var factor : Number = KVisel.hi_res_factor_;
			label_name_.movesize(10 * factor, 20 * factor, w - 20 * factor, 120 * factor);
			button_buy_.movesize((w - 128 * factor) * .5, h - 46 * factor, 128 * factor, 42 * factor);
		}
//.............................................................................
		public function update_Item(v: IItemCollection, id: int): void
		{
			if (null != v)
			{
				if (id < 0)
				{
					return;
				}
				if (id < v.count)
				{
					var list: TestItemList = v as TestItemList;
					label_name_.text = "<h4>" + list.get_Data(id) + "</h4>";
					button_buy_.text = "<h6>" + id + "</h6>";
					button_buy_.dummy_color = 0xFF2e7d32;
					visible = true;
					return;
				}
			}
			visible = false;
		}
	}

}