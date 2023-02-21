package com.gs.ui
{

	public class TLayoutData
	{
		public var visel_       : KVisel = null;
		public var perc_x_		: Number = 0;
		public var perc_y_		: Number = 0;
		public var perc_x2_		: Number = 0;
		public var perc_y2_		: Number = 0;
		public var pix_x_		: Number = 0;
		public var pix_y_		: Number = 0;
		public var pix_x2_		: Number = 0;
		public var pix_y2_		: Number = 0;
		public var clamp_mode_	: int = KLayout.CLAMP_X | KLayout.CLAMP_Y | KLayout.CLAMP_W | KLayout.CLAMP_H;

		public function TLayoutData()
		{}

	}

}