package com.gs
{

	import flash.utils.getTimer;

/*
https://github.com/airsdk/Adobe-Runtime-Support/issues/2293
bug:
Call to flash.utils.getTimer() generates (at least) one MethodClosure per frame (~18KB / second).
workaround:
*/

	public class KTimer
	{
		private static var get_timer_ : Function;
		{
			get_timer_ = flash.utils.getTimer;
		}

		public static function Get(): int
		{
			return get_timer_();
		}
	}

}