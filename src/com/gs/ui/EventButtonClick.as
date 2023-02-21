package com.gs.ui
{
	import flash.events.Event;

	public class EventButtonClick extends Event
	{
		public static const BUTTON_CLICK: String = "BTN_CLICK";
		
		public var repeated_: Boolean;
		public var x_: Number;
		public var y_: Number;
//.............................................................................
		public function EventButtonClick()
		{
			super(BUTTON_CLICK);
		}
//.............................................................................
		public override function clone(): Event
		{
			var right: EventButtonClick = new EventButtonClick();
			right.repeated_	= this.repeated_;
			right.x_		= this.x_;
			right.y_		= this.y_;
			return right;
		}
//.............................................................................
	}

}