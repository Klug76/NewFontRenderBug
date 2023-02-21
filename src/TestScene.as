package
{
	import com.gs.ui.KTouchGrid;
	import com.gs.ui.KVisel;
	import flash.display.BlendMode;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;

	public class TestScene extends KVisel
	{
		private var grid_: KTouchGrid;

		public function TestScene(owner: DisplayObjectContainer)
		{
			super(owner);
			var shop_factor: Number = KVisel.hi_res_factor_;

			var item_list: TestItemList = new TestItemList();

			grid_ = new KTouchGrid(this);

			grid_.dummy_color = 0x6AD2EE;
			grid_.blendMode = BlendMode.NORMAL;

			//grid_.set_Pixel_Rect(0, 80, 0, -80);
			//grid_.set_Percent_Rect(0, 0, 100, 100);
			grid_.user_rows_ = KTouchGrid.AUTO_FIT;
			grid_.user_cols_ = KTouchGrid.AUTO_FIT;
			grid_.user_item_width_  = 170 * shop_factor;
//?			grid_.user_item_height_ = 265 * factor;
			grid_.user_item_height_ = 275 * shop_factor;
			grid_.item_view_ = TestGridItem;
			grid_.item_list_ = item_list;
			grid_.layout.set_Layout_Clamp_Mode(0);
			grid_.track_.skin_h_ = 4;
			grid_.track_.set_Percent_Rect(0, 0, 100, 0);
			grid_.track_.set_Pixel_Rect(8, -12, -8, -12);
			grid_.arrow_near_.set_Percent_Rect(0, 50, 0, 50);
			grid_.arrow_near_.set_Pixel_Rect(24, 0, 24, 0);
			grid_.arrow_far_.set_Percent_Rect(100, 50, 100, 50);
			grid_.arrow_far_.set_Pixel_Rect( -24, 0, -24, 0);

			on_Resize(null);
			stage.addEventListener(Event.RESIZE, on_Resize);
		}

		private function on_Resize(ev: Event): void
		{
			grid_.movesize(0, 40, stage.stageWidth, stage.stageHeight - 80);
			movesize(0, 0, stage.stageWidth, stage.stageHeight);
		}

	}

}