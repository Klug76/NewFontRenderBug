package com.gs.utils
{

	import flash.display.Stage;
	import flash.events.Event;

	public class EnterFrameSignal extends KSignal
	{
		private var stage_: Stage = null;
		public var frame_: int = 0;
		private static var instance_: EnterFrameSignal = null;

		public function EnterFrameSignal()
		{
			super();
		}

		static public function get instance(): EnterFrameSignal
		{
			if (null == instance_)
				instance_ = new EnterFrameSignal();
			return instance_;
		}


		public function init(stg: Stage): void
		{
			stage_ = stg;
			stg.addEventListener(Event.ENTER_FRAME, on_Enter_Frame);
		}


		private function on_Enter_Frame(_): void
		{
			++frame_;
			fire();
		}

	}

}