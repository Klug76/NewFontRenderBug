package com.gs.skin
{
	import com.gs.anim.AnimState;
	import com.gs.ui.KVisel;
	import com.gs.utils.KSignal;
	import flash.display.Graphics;

//:________________________________________________________________________________________________
	public interface ISkinMan
	{
//.............................................................................
		function get_Skin_By_Style	(style_name : String) : int;
		function draw				(nSkinId : int, gc : Graphics, nX : Number, nY : Number, nX2 : Number, nY2 : Number, nPercW : Number, nPercH : Number, param: Object) : void;
		function draw_Anim			(anmState: AnimState, time: int, nX : Number, nY : Number, nX2 : Number, nY2 : Number, param: Object) : int;
		function get_Signal			(): KSignal;
//.............................................................................
	}
//:________________________________________________________________________________________________
}