package com.gs.ui
{
	import com.gs.utils.KSignal;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import com.greensock.easing.Quart;
	import com.greensock.TweenLite;
	import com.gs.skin.ISkinMan;
	import com.gs.utils.EnterFrameSignal;

	CONFIG::mouse
	{
		import flash.events.MouseEvent;
	}
	CONFIG::local_test
	{
		import com.gs.Log;
	}
	/*
	 * 	Sprite -> DisplayObjectContainer -> InteractiveObject -> DisplayObject -> EventDispatcher -> Object
	*/

//.............................................................................
	public class KVisel extends Sprite
	{
		public static var skin_man_: ISkinMan = null;
		public static var hi_res_factor_: Number = 1;

		protected var width_			: Number = 0;
		protected var height_			: Number = 0;
		protected var enabled_			: Boolean = true;
		protected var listener_			: Vector.<TEventListener> = new Vector.<TEventListener>();

		protected var skin_id_			: int = -1;
		protected var indicator_id_		: int = -1;
		protected var indicator_x_		: Number = .5;
		protected var close_anim_		: Boolean = false;
		protected var img_load_signal_	: KSignal = null;
		protected var dummy_color_		: uint = 0;
		public var dummy_alpha_			: Number = -1;
		public var tag_					: int = 0;

		CONFIG::local_test
		{
			static public var visel_counter_: int = 0;
			protected var unique_id_: int;
			//static public var debug_draw_rect_: Boolean = true;
			//static public var debug_draw_rect_: Boolean = false;
			//static public var debug_draw_color_: uint = 0xc0c0c0;
		}

		CONFIG::mouse
		{
			protected var mouse_over_: Boolean = false;
			protected var mouse_down_: Boolean = false;

			protected var hint_: String;
			public var hint_callback_: Function;
			public var hint_exclude_: KVisel;

			CONFIG::touch
			{
				public static var is_touch_supported_: Boolean;//:Windows only, init in KUILayer
			}
		}
		public static const OWNER_START_DRAG: String	= "OWNER_START_DRAG";
		public static const OWNER_STOP_DRAG: String		= "OWNER_STOP_DRAG";
		public static const UNSELECT_OTHERS: String		= "UNSELECT_OTHERS";
		static public const EVENT_ENABLE_ANIM: String	= "START_ANIM";
		static public const EVENT_DISABLE_ANIM: String	= "STOP_ANIM";

		public function KVisel(owner: DisplayObjectContainer = null, nx: Number = 0, ny: Number = 0, nw: Number = 0, nh: Number = 0)
		{
			super();
			width_ = nw;
			height_ = nh;
			x = nx;
			y = ny;
			init(owner);
		}
//.............................................................................
		private function init(owner: DisplayObjectContainer): void
		{
			CONFIG::local_test
			{
				unique_id_ = ++visel_counter_;
				name = "visel #" + unique_id_;
			}
			if (owner != null)
			{
				owner.addChild(this);
				invalidate();
			}
			CONFIG::mouse
			{
				CONFIG::touch
				{
					if (is_touch_supported_)
						return;
				}
				add_Listener(MouseEvent.ROLL_OVER, on_Mouse_Over);
				add_Listener(MouseEvent.MOUSE_DOWN, on_Mouse_Down);
			}
		}
//.............................................................................
		public function destroy_Children(): void
		{
			for (var i: int = numChildren - 1; i >= 0; --i)
			{
				var od: DisplayObject = getChildAt(i);
				if (null == od)
					continue;
				var child: KVisel = od as KVisel;
				if (child != null)
					child.destroy();
				else
					removeChildAt(i);
			}
		}
//.............................................................................
		public function broadcast_Event(s: String): void
		{
			var count: int = numChildren;
			for (var i: int = 0; i < count; ++i)
			{
				var child: KVisel = getChildAt(i) as KVisel;
				if (child != null)
					child.broadcast_Event(s);
			}
		}
//.............................................................................
		[Inline]
		public final function get disposed(): Boolean
		{
			return null == listener_;
		}
//.............................................................................
		public function destroy(): void
		{
			if (disposed)
				return;
			remove_All_Listeners();
			if (img_load_signal_)
			{
				img_load_signal_.remove(on_Image_Loaded);
				img_load_signal_ = null;
			}
			TweenLite.killTweensOf(this);
			destroy_Children();
			if (parent != null)
				parent.removeChild(this);
			CONFIG::mouse
			{
				CONFIG::touch
				{
					if (is_touch_supported_)
						return;
				}
				mouse_over_ = false;
				mouse_down_ = false;

				hint_callback_ = null;
				hint_exclude_ = null;
			}
		}
//.............................................................................
		override public function set x(value: Number): void
		{
			super.x = Math.round(value);
		}
//.............................................................................
		override public function set y(value: Number): void
		{
			super.y = Math.round(value);
		}
//.............................................................................
		public function invalidate(): void
		{
			//?if (null == listener_)
			//?	return;
			EnterFrameSignal.instance.add(on_Invalidate/*, "KVisel[" + unique_id_ + ":" + name + "]::invalidate"*/);
		}
//.............................................................................
		protected function on_Invalidate(): void
		{
			EnterFrameSignal.instance.remove(on_Invalidate);
			if (disposed)
				return;
			draw();
		}
//.............................................................................
		public function draw(): void
		{
			graphics.clear();
			if (skin_id_ >= 0)
			{
				//if (100000 + 4 == tag_)
				//if(104 == skin_id_)
					//trace("skin draw " + skin_id_ + ", w=" +  width_ + ", h=" + height_);
				skin_man_.draw(skin_id_, graphics, 0, 0, width_, height_, 1, 1, this);
			}
			else if (dummy_alpha_ >= 0)
			{
				graphics.beginFill(dummy_color_, dummy_alpha_);
				graphics.drawRect(0, 0, width_, height_);
				graphics.endFill();
			}

			if (indicator_id_ >= 0)
			{
				skin_man_.draw(indicator_id_, graphics, 0, 0, width_, height_, indicator_x_, 1, this);
			}
			//if (debug_draw_rect_ && (this is KLabel))
			//{
				//graphics.beginFill(debug_draw_color_, 0.4);
				//graphics.drawRect(0, 0, width_, height_);
				//graphics.endFill();
				//debug_draw_color_ += 0x30;
				//debug_draw_color_ = 0x70c000 | (debug_draw_color_ & 0xFF);
			//}
		}
//.............................................................................
		//public function draw_3d(ui3d: KUILayer3d, owner_x : int, owner_y : int): void
		//{
			//ui3d.draw_Skin(skin_id_, owner_x, owner_y, width_, height_);
			////:dummy color ???
			////:indicator   ???
		//}
//.............................................................................
		public function move(nx: Number, ny: Number): void
		{
			x = nx;
			y = ny;
		}
//.............................................................................
		public function resize(w: Number, h: Number): void
		{
			if (w < 0)
				w = 0;
			if (h < 0)
				h = 0;
			if ((width_ != w) || (height_ != h))
			{
				width_ = w;
				height_ = h;
				invalidate();
				dispatchEvent(new Event(Event.RESIZE, false));
			}
		}
//.............................................................................
		public function resize_(w: Number, h: Number): void
		{
			width_ = (w > 0) ? w : 0;
			height_ = (h > 0) ? h : 0;
		}
//.............................................................................
		public function movesize(nx: Number, ny: Number, w: Number, h: Number): void
		{
			x = nx;
			y = ny;
			resize(w, h);
		}
//.............................................................................
		public function movesize_(nx: Number, ny: Number, w: Number, h: Number): void
		{
			x = nx;
			y = ny;
			resize_(w, h);
		}
//.............................................................................
		public function tween(nx: Number, ny: Number, w: Number, h: Number, tween_time: Number, tween_style: Object): void
		{
			//?if (close_anim_)
				//?return;
			TweenLite.to(this, tween_time, { x: nx, y: ny, width: w, height: h, ease: tween_style } );
		}
//.............................................................................
		override public function get width(): Number { return width_; }
		override public function set width(w: Number): void
		{
			if (w < 0)
				w = 0;
			if (width_ != w)
			{
				width_ = w;
				invalidate();
				dispatchEvent(new Event(Event.RESIZE, false));
			}
		}
//.............................................................................
		override public function get height(): Number { return height_; }
		override public function set height(h: Number): void
		{
			if (h < 0)
				h = 0;
			if (height_ != h)
			{
				height_ = h;
				invalidate();
				dispatchEvent(new Event(Event.RESIZE, false));
			}
		}
//.............................................................................
//.............................................................................
		public function get enabled(): Boolean { return enabled_; }
		public function set enabled(value: Boolean): void
		{
			if (enabled_ != value)
			{
				enabled_ = value;
				mouseEnabled = mouseChildren = value;
//?				tabEnabled = value;
//				if (skin_id_ >= 0)
					//alpha = value ? 1.0 : 0.5;
			}
		}
//.............................................................................
		public function set skin_style(name: String): void
		{
			skin_id = skin_man_.get_Skin_By_Style(name);
			CONFIG::local_test
			{
				if ((skin_id < 0) && (name != null) && (name.length > 0))
					Log("WARNING: skin_style not found: '" + name + "'");
			}
		}
//.............................................................................
		public function get skin_id(): int { return skin_id_; }
		public function set skin_id(value: int): void
		{
			if (skin_id_ != value)
			{
				skin_id_ = value;
				if (skin_id_ >= 0)
					add_Image_Load_Listener();
				invalidate();
			}
		}
//.............................................................................
		public function set indicator_style(name: String): void
		{
			indicator_id = skin_man_.get_Skin_By_Style(name);
		}
//.............................................................................
		public function get indicator_id(): int { return indicator_id_; }
		public function set indicator_id(value: int): void
		{
			if (indicator_id_ != value)
			{
				indicator_id_ = value;
				if (indicator_id_ >= 0)
					add_Image_Load_Listener();
				invalidate();
			}
		}
//.............................................................................
		public function get indicator_val(): Number { return indicator_x_; }
		public function set indicator_val(value: Number): void
		{
			if (value < 0)
				value = 0;
			if (value > 1)
				value = 1;
			if (indicator_x_ != value)
			{
				indicator_x_ = value;
				invalidate();
			}
		}
//.............................................................................
		public function add_Image_Load_Listener(): void
		{
			if (null == img_load_signal_)
			{
				img_load_signal_ = skin_man_.get_Signal();
				img_load_signal_.add(on_Image_Loaded/*, "KVisel::on_Image_Loaded"*/);
			}
		}
//.............................................................................
		protected function on_Image_Loaded(): void
		{
			//if (1100101 == tag_)
				//trace("************");
			invalidate();
		}
//.............................................................................
//.............................................................................
		public function get dummy_color(): uint { return dummy_color_; }
		public function set dummy_color(value: uint): void
		{
			if (dummy_color_ != value)
			{
				dummy_color_ = value & 0xffffff;
				value >>>= 24;
				if (0 == value)
					dummy_alpha_ = 1;
				else
					dummy_alpha_ = value / 255;
				invalidate();
			}
		}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
		/* doesn't changed Z-order if parent == owner
		 */
		/*
		 * may produce artefacts!!
		 */
/*
		public function set_Parent(owner: DisplayObjectContainer): void
		{
			if (null == listener_)
			{
				CONFIG::local_test
				{
					Log("ERROR: set_Parent(...) to zombie object");
				}
				return;
			}
			if (null == owner)
			{
				CONFIG::local_test
				{
					Log("ERROR: set_Parent(null)");
				}
				return;
			}
			if (owner != parent)
				owner.addChild(this);
		}
*/
//.............................................................................
		public function bring_To_Top(): void
		{
			if (null != parent)
				parent.addChild(this);
		}
//.............................................................................
//.............................................................................
//.............................................................................
		public function add_Listener(type: String, listener: Function, target: IEventDispatcher = null, phase0: Boolean = false, priority: int = 0): void
		{
			if (null == listener_)
			{
				CONFIG::local_test
				{
					Log("ERROR: add_Listener() to zombie object");
					throw new Error("ERROR: add_Listener() to zombie object");
				}
				return;
			}
			if (null == target)
				target = this;
			var el: TEventListener = null;
			var len: int = listener_.length;
			for (var i: int = 0; i < len; ++i)
			{
				var tmp: TEventListener = listener_[i];
				if (tmp.type_ == type && tmp.callback_ == listener && tmp.target_ == target && tmp.phase0_ == phase0)
				{
					el = tmp;
					break;
				}
			}
			if (null == el)
			{
				el = new TEventListener(type, listener, target, phase0);
				listener_.push(el);
				target.addEventListener(type, listener, phase0, priority,
					false/*useWeakReference*/);
			}
		}
//.............................................................................
		public function remove_Listener(type: String, listener: Function, target: IEventDispatcher = null, phase0: Boolean = false): void
		{
			if (null == listener_)
				return;
			if (null == target)
				target = this;
			for (var i: int = listener_.length - 1; i >= 0; --i)
			{
				var tmp: TEventListener = listener_[i];
				if (tmp.type_ == type && tmp.callback_ == listener && tmp.target_ == target && tmp.phase0_ == phase0)
				{
					target.removeEventListener(type, listener, phase0);
					if (CONFIG::air)
					{
						listener_.removeAt(i);
					}
					else
					{
						listener_.splice(i, 1);
					}
					break;
				}
			}
		}
//.............................................................................
		protected function remove_All_Listeners(): void
		{
			if (null == listener_)
				return;
			for (var i: int = 0; i < listener_.length; ++i)
			{
				var tmp: TEventListener = listener_[i];
				tmp.target_.removeEventListener(tmp.type_, tmp.callback_, tmp.phase0_);
			}
			listener_.length = 0;
			listener_ = null;
		}
//.............................................................................
//.............................................................................
		public function set_Pixel_Rect(nX: Number, nY: Number, nX2: Number, nY2: Number): void
		{
			var panel: ILayoutContainer = parent as ILayoutContainer;
			if (panel != null)//:the as operator returns a null value.
			{
				panel.layout.set_Pixel_Rect(this, nX, nY, nX2, nY2);
			}
			else
			{
				CONFIG::local_test
				{
					Log("WARNING: layout not found");
				}
			}
		}
//.............................................................................
		public function set_Percent_Rect(nX: Number, nY: Number, nX2: Number, nY2: Number): void
		{
			var panel: ILayoutContainer = parent as ILayoutContainer;
			if (panel != null)//:the as operator returns a null value.
			{
				panel.layout.set_Percent_Rect(this, nX, nY, nX2, nY2);
			}
			else
			{
				CONFIG::local_test
				{
					Log("WARNING: layout not found");
				}
			}
		}
//.............................................................................
		public function set_Clamp_Mode(mode: int): void
		{
			var panel: ILayoutContainer = parent as ILayoutContainer;
			if (panel != null)//:the as operator returns a null value.
			{
				panel.layout.set_Clamp_Mode(this, mode);
			}
			else
			{
				CONFIG::local_test
				{
					Log("WARNING: layout not found");
				}
			}
		}
//.............................................................................
/*
		public function move_Size(nX: Number, nY: Number, nW: Number, nH: Number): void
		{
			var panel: ILayoutContainer = parent as ILayoutContainer;
			if (panel != null)//:the as operator returns a null value.
			{
				panel.layout.set_Pixel_Rect_(this, nX, nY, nX + nW, nY + nH);
				//panel.layout.set_Pixel_Rect_(this, nX * pix_factor_, nY * pix_factor_, (nX + nW) * pix_factor_, (nY + nH) * pix_factor_);
			}
			else
			{
				CONFIG::local_test
				{
					Log("WARNING: layout not found");
				}
			}
		}
*/
//.............................................................................
		//public function get pix_factor(): Number { return pix_factor_; }
		//public function set pix_factor(value: Number): void
		//{
			//pix_factor_ = value;
			//var panel: ILayoutContainer = this as ILayoutContainer;
			//if (panel != null)
				//panel.layout.pix_factor_ = value;
		//}
//.............................................................................
//.............................................................................
		public function get close_anim(): Boolean { return close_anim_; }
		public function set close_anim(value: Boolean): void
		{
			close_anim_ = value;
		}
//.............................................................................
		static public function Is_Opened(...args): Boolean
		{
			var len: int = args.length;
			for (var i: int = 0; i < len; ++i)
			{
				var v: KVisel = args[i] as KVisel;
				if ((v != null) && !v.close_anim)
					return true;
			}
			return false;
		}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
		CONFIG::mouse
		{
//.............................................................................
		protected function on_Mouse_Over(e: MouseEvent): void
		{
			if (mouse_over_)
				return;
			//if (tag_ == 1100101)
			//trace("mouse over " + name + ", tag=" + tag_);
			mouse_over_ = true;
			add_Listener(MouseEvent.ROLL_OUT, on_Mouse_Leave);
		}
//.............................................................................
		protected function on_Mouse_Leave(e: MouseEvent): void
		{
			mouse_over_ = false;
			remove_Listener(MouseEvent.ROLL_OUT, on_Mouse_Leave);
		}
//.............................................................................
		protected function on_Mouse_Down(e: MouseEvent): void
		{
			if (mouse_down_)
				return;
			mouse_down_ = true;
			//???mouse_over_ = true;
			//Log("visel::mouse down " + getQualifiedClassName(this));
			//:set capture
			add_Listener(MouseEvent.MOUSE_UP, on_Mouse_Up, stage, false, 1);
		}
//.............................................................................
		protected function on_Mouse_Up(e: MouseEvent): void
		{
			if (!mouse_down_)
				return;
			mouse_down_ = false;
			//:release capture
			remove_Listener(MouseEvent.MOUSE_UP, on_Mouse_Up, stage);
		}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
		public function get hold_tooltip(): Boolean
		{
			return mouse_over_;
		}
//.............................................................................
		public function get hint(): String
		{
			if (hint_callback_ != null)
				return hint_callback_(this);
			return (hint_ !== null) ? hint_ : "";
		}
//.............................................................................
		public function set hint(value: String): void
		{
			hint_ = value;
			//?mouseEnabled = true;
		}
//.............................................................................
		public function refresh_Hint(): void
		{
		}
//.............................................................................
		}//:CONFIG::mouse
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
		public static function Clamp(val: Number, min: Number, max: Number): Number
		{
			return Math.max(min, Math.min(max, val));
		}
//.............................................................................
		public static function random_Color(base: uint, delta: uint): uint
		{
			return base | (Math.round(Math.random() * 0xFFFFFF) & delta);
		}
//.............................................................................
//.............................................................................
	}
}