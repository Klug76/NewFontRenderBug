package com.gs.ui
{
	import com.gs.utils.EnterFrameSignal;
	import flash.display.Sprite;
	import flash.display.DisplayObjectContainer;
	import flash.system.Capabilities;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;
	import flash.events.Event;
	import com.gs.KTimer;
	import com.greensock.TweenLite;
	//import com.gs.AnimState;


	CONFIG::mouse
	{
		import flash.events.MouseEvent;
	}
	CONFIG::touch
	{
		import flash.events.TouchEvent;
	}

	[Event(name="BTN_CLICK", type="EventButtonClick")]

//:________________________________________________________________________________________________
	public class KButton extends KVisel
	{
		public static const ANIM_OVER_ON		: int = 0;
		public static const ANIM_OVER_OFF		: int = 1;
		public static const ANIM_PRESS_ON		: int = 2;
		public static const ANIM_PRESS_OFF		: int = 3;
		public static const ANIM_DISABLED		: int = 4;
		private static var click_threshold_: Number = 16;

		protected var label_					: KBaseLabel;
		protected var hit_area_					: KVisel;

		//protected var skin_						: AnimState = new AnimState();

		public    var pressed_color_			: uint = 0x00aaaa;
		public    var auto_repeat_				: Boolean = false;
		internal  var auto_repeat_on_			: Boolean = false;
		protected var auto_repeat_time_			: int;
		protected var auto_repeat_count_		: int;

		protected var hide_text_if_skin_		: Boolean = false;
		protected var text_						: String;
		protected var hi_text_					: String = null;
		protected var grayed_					: Boolean = false;

		public var text_margin_x_				: int = 2;
		public var text_margin_y_				: int = 2;
		public var text_margin_x2_				: int = 2;
		public var text_margin_y2_				: int = 2;
		public var content_down_offset_x_		: int = 1;
		public var content_down_offset_y_		: int = 1;
		public var content_disabled_offset_y_	: int = 0;
		public var detect_long_tap_				: Boolean = false;
		public var long_tap_elapse_				: int = 2000;
		protected var long_tap_detected_		: Boolean = false;
		protected var parent_drag_mode_			: Boolean = false;
		protected var drag_detected_			: Boolean = false;
		private var tap_time_					: int = 0;

		CONFIG::touch
		{
			private var first_touch_id_			: int = 0;
			private var touch_down_				: Boolean = false;
			private var tap_x_					: Number = 0;
			private var tap_y_					: Number = 0;
		}
//.............................................................................
		public function KButton(owner: DisplayObjectContainer,
								txt: String, on_Click: Function,
								label: KBaseLabel = null,
								fmt: TextFormat = null,
								nx: Number = 0, ny: Number = 0, nw: Number = 0, nh: Number = 0)
		{
			super(owner, nx, ny, nw, nh);
			init(txt, on_Click, label, fmt);
		}
//.............................................................................
		private function init(txt: String, on_Click: Function, label: KBaseLabel, fmt: TextFormat): void
		{
			buttonMode = true;
			//skin_.gc_ = graphics;
			text_ = txt;
			if (null == label)
			{
				label = new KLabel(this, txt, fmt, text_margin_x_, text_margin_y_);
			}
			else
			{
				label.move(text_margin_x_, text_margin_y_);
				addChild(label);
			}
			label_ = label;
			//?label_.mouseEnabled = false;
			//?useHandCursor = true;//?

			start_Anim(ANIM_OVER_OFF);

			if (null != on_Click)
				add_Listener(EventButtonClick.BUTTON_CLICK, on_Click);

			CONFIG::touch
			{
				add_Touch_Listeners();
			}
			CONFIG::mouse
			{
				add_Mouse_Listeners();
			}
		}
//.............................................................................
		override public function destroy(): void
		{
			if (auto_repeat_on_)
			{
				auto_repeat_on_ = false;
				//KUILayer.instance.on_Auto_Repeat_Off(this);
			}
			label_ = null;
			hit_area_ = null;
			//skin_.destroy();
			//skin_ = null;
			super.destroy();
		}
//.............................................................................
//.............................................................................
		public function get label(): KLabel
		{
			return label_ as KLabel;
		}
//.............................................................................
//.............................................................................
		public function set css(value: StyleSheet): void
		{
			(label_ as KLabel).css = value;
		}
//.............................................................................
//.............................................................................
		public function start_Anim(nAnimId : int) : void
		{
			//skin_anim_id_ = nAnimId;
			//skin_begin_time_ = KTimer.Get();
			//skin_.seq_id_ = nAnimId;
			//skin_.anim_begin_time_ = KTimer.Get();
		}
//.............................................................................
		override public function set enabled(value: Boolean): void
		{
			if (enabled_ != value)
			{
				enabled_ = value;
				mouseEnabled = mouseChildren = value;
				tabEnabled = value;
				start_Anim(enabled_ ? ANIM_OVER_OFF : ANIM_DISABLED);
				invalidate();
			}
		}
//.............................................................................
		public function is_pressed(): Boolean
		{
			var pressed: Boolean;
			CONFIG::touch
			{
				pressed = touch_down_;
			}
			CONFIG::mouse
			{
				pressed = mouse_down_;
				CONFIG::touch
				{//:windows-only pessimization
					if (is_touch_supported_)
					{
						pressed = touch_down_;
					}
				}
			}
			return pressed;
		}
//.............................................................................
		public function is_hilite(): Boolean
		{
			var hilite: Boolean;
			CONFIG::mouse
			{
				hilite = mouse_over_;
				CONFIG::touch
				{//:windows-only pessimization
					if (is_touch_supported_)
					{
						hilite = false;
					}
				}
			}
			return hilite;
		}
//.............................................................................
//.............................................................................
		override public function draw(): void
		{
			//if (1100101 == tag_)
				//trace("***");
			graphics.clear();
			if (skin_id >= 0)
			{
				//skin_.skin_id_ = skin_id;
				//if (skin_man_.draw_Anim(skin_, KTimer.Get(), 0, 0, width_, height_, this) >= 0)
				//{
					//invalidate();
				//}
			}
			else if (dummy_alpha_ >= 0)
			{
				var u: uint = dummy_color_;
				var d: int = 0;
				if (is_pressed())
					u = pressed_color_;
				if (is_hilite())
					d = 2;
				graphics.beginFill(u, dummy_alpha_);
				graphics.drawRect(-d, -d, width_ + 2 * d, height_ + 2 * d);
				graphics.endFill();
			}
			if (indicator_id_ >= 0)
			{
				//skin_man_.draw(indicator_id_, graphics, 0, 0, width_, height_, indicator_x_, 1, this);
			}

			//if (debug_draw_rect_)
			//{
				//graphics.beginFill(debug_draw_color_, 0.4);
				//graphics.drawRect(0, 0, width_, height_);
				//graphics.endFill();
				//debug_draw_color_ += 0x10;
				//debug_draw_color_ = 0x70c000 | (debug_draw_color_ & 0xFF);
			//}

			if (hide_text_if_skin_ && (skin_id >= 0))
			{
				//:label_.visible = false;
			}
			else
			{
				var txt: String = text_;
				if ((hi_text_ != null) && (is_hilite() || (content_disabled_offset_y_ != 0 && !enabled_)))
					txt = hi_text_;
				label_.update_Text(txt);
				if (!enabled_)
				{
					label_.movesize_(text_margin_x_ + content_down_offset_x_, text_margin_y_ + content_down_offset_y_,
						width_ - text_margin_x_ - text_margin_x2_,
						height_ - text_margin_y_ - text_margin_y2_ + content_disabled_offset_y_);
				}
				else
				if (is_pressed())
				{
					label_.movesize_(text_margin_x_ + content_down_offset_x_, text_margin_y_ + content_down_offset_y_,
						width_ - text_margin_x_ - text_margin_x2_ + content_down_offset_x_,
						height_ - text_margin_y_ - text_margin_y2_ + content_down_offset_y_);
				}
				else
				{
					label_.movesize_(text_margin_x_, text_margin_y_,
						width_ - text_margin_x_ - text_margin_x2_,
						height_ - text_margin_y_ - text_margin_y2_);
				}
				label_.draw();
			}
			if (hit_area_ != null)
				hit_area_.movesize(0, 0, width_, height_);
		}
//.............................................................................
		override public function set skin_id(value: int): void
		{
			if (hide_text_if_skin_)
			{
				label_.visible = value < 0;
			}
			super.skin_id = value;
		}
//.............................................................................
		public function get hide_text_if_skin(): Boolean { return hide_text_if_skin_; };
		public function set hide_text_if_skin(value: Boolean): void
		{
			if (hide_text_if_skin_ != value)
			{
				hide_text_if_skin_ = value;
				label_.visible = !hide_text_if_skin_ || (skin_id_ < 0);
			}
		}
//.............................................................................
//.............................................................................
		public function get text(): String { return text_; };
		public function set text(value: String): void
		{
			if (text_ != value)
			{
				text_ = value;
				invalidate();
			}
		}
		public function get hi_text(): String
		{
			return (hi_text_ != null) ? hi_text_ : "";
		}
		public function set hi_text(value: String): void
		{
			if (hi_text_ != value)
			{
				hi_text_ = value;
				invalidate();
			}
		}
//.............................................................................
//.............................................................................
//.............................................................................
		public function get grayed(): Boolean { return grayed_; }
		public function set grayed(value: Boolean):void
		{
			if (grayed_ != value)
			{
				grayed_ = value;
			}
		}
//.............................................................................
//.............................................................................
		CONFIG::mouse
		{
//.............................................................................
		private function add_Mouse_Listeners(): void
		{
			CONFIG::touch
			{
				if (is_touch_supported_)
					return;
			}
			add_Listener(MouseEvent.CLICK, on_Mouse_Click);
		}
//.............................................................................
		override protected function on_Mouse_Over(e: MouseEvent): void
		{
			if (parent_drag_mode_)
				return;
			super.on_Mouse_Over(e);
			//if (enabled_)
				//start_Anim(ANIM_OVER_ON);
			//invalidate();
		}
//.............................................................................
		override protected function on_Mouse_Leave(e: MouseEvent): void
		{
			if (parent_drag_mode_)
				return;
			super.on_Mouse_Leave(e);
			//if (enabled_)
				//start_Anim(ANIM_OVER_OFF);
			//invalidate();
		}
//.............................................................................
		override protected function on_Mouse_Down(e: MouseEvent): void
		{
			if (parent_drag_mode_)
				return;
			if (mouse_down_)
			{//:auto-repeat button? obsolete?
				e.stopPropagation();
				return;
			}
			super.on_Mouse_Down(e);
			e.stopPropagation();//????

			on_Press_Item();
		}
//.............................................................................
		override protected function on_Mouse_Up(e: MouseEvent): void
		{
			if (parent_drag_mode_)
				return;
			//Log("button::up '" + text + "'");
			if (!mouse_down_)
				return;
			super.on_Mouse_Up(e);
			e.stopPropagation();

			if (enabled_)
			{
				if (mouse_over_)
					start_Anim(ANIM_PRESS_OFF);
				else
					start_Anim(ANIM_OVER_OFF);
			}
			invalidate();
		}
//.............................................................................
//.............................................................................
		//private function on_Mouse_Click0(e: MouseEvent): void
		//{
			//Log("button::click phase0 '" + text + "'");
		//}
//.............................................................................
		private function on_Mouse_Click(e: MouseEvent): void
		{
			if (parent_drag_mode_)
			{
				//Log("** button::drag & click '" + text + "'");
				//Log("_______");
				return;
			}
			//Log("button::click '" + text + "', target=" + e.target);
			//Log("_______");
			e.stopPropagation();
			if (long_tap_detected_ || drag_detected_ || (auto_repeat_count_ > 0))
				return;
			var ev: EventButtonClick = new EventButtonClick();
			//ev.repeated_ = false;
			ev.x_ = e.stageX;
			ev.y_ = e.stageY;
			dispatchEvent(ev);
			//if (!auto_repeat_)
				//KUILayer.instance.play_Button_Click_Sound(TUISound.BUTTON_CLICK, tag_);
		}
//.............................................................................
		private function on_Mouse_Drag_Parent(): void
		{
			CONFIG::touch
			{
				if (is_touch_supported_)
					return;
			}
			if (mouse_down_ || mouse_over_)
			{
				super.on_Mouse_Up(null);
				mouse_over_ = false;
				invalidate();
				if (enabled_)
					start_Anim(ANIM_OVER_OFF);
			}
		}
//.............................................................................
		private function do_Mouse_Repeat(): void
		{
			CONFIG::touch
			{
				if (is_touch_supported_)
					return;
			}
			if (!mouse_over_)
				return;
			var ev: EventButtonClick = new EventButtonClick();
			ev.repeated_ = true;
			dispatchEvent(ev);
		}
//.............................................................................
		}//:CONFIG::mouse
//.............................................................................
		CONFIG::touch
		{
//.............................................................................
		private function add_Touch_Listeners():void
		{
			CONFIG::mouse
			{
				if (!is_touch_supported_)
					return;
			}
			add_Listener(TouchEvent.TOUCH_BEGIN, on_Touch_Begin);
		}
//.............................................................................
		private function on_Touch_Begin(e: TouchEvent): void
		{
			if (parent_drag_mode_)
				return;
			if (touch_down_)
				return;
			touch_down_ = true;

			first_touch_id_ = e.touchPointID;
			tap_x_ = e.stageX;
			tap_y_ = e.stageY;
			add_Listener(TouchEvent.TOUCH_END, on_Touch_End_Stage, stage, false, 1);

			on_Press_Item();
		}
//.............................................................................
		private function on_Touch_End_Stage(e: TouchEvent): void
		{
			if (!touch_down_)
				return;
			if (e.touchPointID != first_touch_id_)
				return;
			on_Untouch_Button();
			if (long_tap_detected_ || drag_detected_ || (auto_repeat_count_ > 0))
				return;
			if (!can_Click_By_Tap(e.stageX, e.stageY))
				return;
			var ev: EventButtonClick = new EventButtonClick();
			ev.x_ = e.stageX;
			ev.y_ = e.stageY;
			dispatchEvent(ev);
			//Log('button::CLICK!');
			//if (!auto_repeat_)
				//KUILayer.instance.play_Button_Click_Sound(TUISound.BUTTON_CLICK, tag_);
		}
//.............................................................................
		private function can_Click_By_Tap(nx: Number, ny: Number): Boolean
		{
			if (!hitTestPoint(nx, ny, false))
				return false;
			var dx: Number = Math.abs(nx - tap_x_);
			var dy: Number = Math.abs(ny - tap_y_);
			var threshold: Number = click_threshold_;
			return (dx <= threshold) && (dy < threshold);
		}
//.............................................................................
//.............................................................................
		private function on_Touch_Drag_Parent():void
		{
			CONFIG::mouse
			{
				if (!is_touch_supported_)
					return;
			}
			//on_Touch_Out(null);
			if (touch_down_)
			{
				on_Untouch_Button();
			}
		}
//.............................................................................
		private function on_Untouch_Button(): void
		{
			touch_down_ = false;
			remove_Listener(TouchEvent.TOUCH_END, on_Touch_End_Stage, stage);
			if (enabled_)
				start_Anim(ANIM_OVER_OFF);
			invalidate();
		}
//.............................................................................
		private function do_Touch_Repeat():void
		{
			CONFIG::mouse
			{
				if (!is_touch_supported_)
					return;
			}
			//:bug - touch over may arrive too late
			//?if (!touch_over_)
			//{
				//Log("** !touch_over_");
				//return;
			//}
			//Log("** click");
			var ev: EventButtonClick = new EventButtonClick();
			ev.repeated_ = true;
			dispatchEvent(ev);
		}
//.............................................................................
		}//:CONFIG::touch
//.............................................................................
		override public function broadcast_Event(s: String): void
		{
			switch(s)
			{
			case OWNER_START_DRAG:
				parent_drag_mode_ = true;
				drag_detected_ = true;
				CONFIG::touch
				{
					on_Touch_Drag_Parent();
				}
				CONFIG::mouse
				{
					on_Mouse_Drag_Parent();
				}
				break;
			case OWNER_STOP_DRAG:
				parent_drag_mode_ = false;
				break;
			}
			super.broadcast_Event(s);
		}
//.............................................................................
//.............................................................................
		private function on_Press_Item(): void
		{
			if (enabled_)
				start_Anim(ANIM_PRESS_ON);
			invalidate();
			tap_time_ = KTimer.Get();
			long_tap_detected_ = false;
			drag_detected_ = false;
		}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	}

}