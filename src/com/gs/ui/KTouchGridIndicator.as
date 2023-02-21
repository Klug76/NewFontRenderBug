package com.gs.ui
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.events.Event;
	import com.greensock.TweenLite;

	public class KTouchGridIndicator extends KVisel
	{
		public var skin_x_: int;
		public var skin_y_: int;
		public var skin_w_: int;
		public var skin_h_: int;

		public function KTouchGridIndicator(owner: DisplayObjectContainer)
		{
			super(owner);
			mouseEnabled = mouseChildren = false;
			alpha = 0;
			close_anim_ = true;
		}
//.............................................................................
//.............................................................................
		override public function draw(): void
		{
			graphics.clear();
			if (skin_id_ >= 0)
			{
				skin_man_.draw(skin_id_, graphics, skin_x_, skin_y_, skin_x_ + skin_w_, skin_y_ + skin_h_, 1, 1, this);
			}
			else if (dummy_alpha_ >= 0)
			{
				graphics.beginFill(dummy_color_, dummy_alpha_);
				graphics.drawRect(skin_x_, skin_y_, skin_w_, skin_h_);
				graphics.endFill();
			}
		}
//.............................................................................
//.............................................................................
		public function anim_Show(dt: Number, a: Number): void
		{
			close_anim_ = false;
			TweenLite.to(this, dt, { 'alpha': a } );
		}
//.............................................................................
		public function anim_Hide(dt: Number, a: Number): void
		{
			if (close_anim_)
				return;
			close_anim_ = true;
			TweenLite.to(this, dt, { 'alpha': a } );
		}
//.............................................................................
	}
}
