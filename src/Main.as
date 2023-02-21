package
{
	import com.gs.ui.KCss;
	import com.gs.ui.KVisel;
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.system.Capabilities;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import com.gs.utils.EnterFrameSignal;

	public class Main extends Sprite
	{

		public function Main()
		{
			init(null);
		}

		private function init(e: Event): void
		{
			if (null === stage)
			{
				addEventListener(Event.ADDED_TO_STAGE, init);
				return;
			}
			if (e !== null)
				removeEventListener(Event.ADDED_TO_STAGE, init);

			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;

			// touch or gesture?
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;

			KCss.def_font_family_ = "Helvetica,Arial,_sans";
			var res_x: Number = Capabilities.screenResolutionX;
			var res_y: Number = Capabilities.screenResolutionY;
			if (Capabilities.os.indexOf("Windows") >= 0)
			{
				res_x = stage.stageWidth;
				res_y = stage.stageHeight;
				//trace("stage size: " + stage.stageWidth + "x" + stage.stageHeight);
			}
			KVisel.hi_res_factor_	= Math.floor(Math.min(res_x, res_y) / 1080) + 1;
			//trace("KVisel.hi_res_factor=" + KVisel.hi_res_factor_);

			EnterFrameSignal.instance.init(stage);


			new TestScene(this);
		}


	}

}