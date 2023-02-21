package com.gs.ui
{

	public interface ILayout
	{
		function dispose(): void;
		function on_Resize(owner: KVisel, owner_w: Number, owner_h: Number, tween_time: Number, tween_style: Object): void;
		function set_Pixel_Rect(visel: KVisel, nX: Number, nY: Number, nX2: Number, nY2: Number): void;
		function set_Percent_Rect(visel: KVisel, nX: Number, nY: Number, nX2: Number, nY2: Number): void;
		function set_Clamp_Mode(visel: KVisel, mode: int): void;
		function set_Layout_Clamp_Mode(mode: int): void;
	}

}