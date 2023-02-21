package com.gs.ui
{
	import com.gs.utils.EnterFrameSignal;
	import com.gs.utils.IItemCollection;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.EventPhase;
	import flash.geom.Rectangle;
	import com.gs.KTimer;

	CONFIG::mouse
	{
		import flash.events.MouseEvent;
	}
	CONFIG::touch
	{
		import flash.events.TouchEvent;
	}

//:________________________________________________________________________________________________
	public class KTouchGrid extends KVisel implements ILayoutContainer
	{
		public var x_spacing_					: int = 0;
		public var y_spacing_					: int = 0;
		public var x_border_					: int = 0;
		public var y_border_					: int = 0;
		public var user_item_width_				: int = 128;//:may be AUTO_FIT
		public var user_item_height_			: int = 128;//:may be AUTO_FIT
		public var user_cols_					: int = AUTO_FIT;//:may be set exactly
		public var user_rows_					: int = AUTO_FIT;//:may be set exactly
		public var item_x_align_				: String = TAlign.CENTER;
		public var item_y_align_				: String = TAlign.CENTER;
		public var dummy_item_count_			: int = 0;//:e.g. 'add friend' item
		public var drag_disabled_				: Boolean;

		public var mode_						: int = MODE_HORZ;
		public var align_						: String = TAlign.CENTER;

		public var item_view_					: Class = null;
		public var item_list_					: IItemCollection = null;

		public static const AUTO_FIT			: int = 0;

		public static const MODE_HORZ			: int = 0;
		public static const MODE_VERT			: int = 1;

		//:calculated
		private var cols_						: int = 0;
		private var rows_						: int = 0;
		private var num_cells_					: int = 0;
		private var item_width_					: Number = 0;
		private var item_height_				: Number = 0;
		private var total_pix_size_				: Number = 0;
		private var overdrag_limit_				: Number = 0;
		private var speed_limit_				: Number = 0;


		private var cam_rect_					: Rectangle = new Rectangle();
		private var layout_						: KLayout = new KLayout();

		public var camera_						: KVisel;
		public var track_						: KTouchGridIndicator;
		public var arrow_near_					: KTouchGridIndicator;
		public var arrow_far_					: KTouchGridIndicator;

		private var is_dragged_					: Boolean = false;

		private var first_touch_id_				: int = 0;
		private var capture_set_				: Boolean = false;
		private var diff_pos_					: Number;
		private var prev_pos_					: Number;
		private var diff_time_					: Number;
		private var prev_time_					: Number;
		private var v0_							: Number;
		private var sign_v0_					: Number;
		private var a0_							: Number;
		private var anim_time_					: Number;
		private var anim_pos_					: Number;
		private var return_mode_				: Boolean = false;
		private var tap_list_					: Vector.<TapPoint> = new Vector.<TapPoint>();

		//: alternate pull-out drag-drop
		public  var alt_drag_enable_			: Boolean = false;
		public  var alt_dir_					: int = 0;	//:pull dir [-1, 0, +1]
		private var alt_item_					: KVisel;
		private var alt_ofs_					: Number;
		private var alt_pos_					: Number;
		private var pending_update_ 			: Boolean;

		private const drag_threshold_: Number = 16;

//.............................................................................
		public function KTouchGrid(owner: DisplayObjectContainer, nx: Number = 0, ny: Number = 0, nw: Number = 0, nh: Number = 0)
		{
			super(owner, nx, ny, nw, nh);
			add_Listener(Event.RESIZE, on_Resize);

			//:cam_rect_.left = 0;
			//:cam_rect_.top = 0;
			cam_rect_.right = nw;
			cam_rect_.bottom = nh;

			camera_ = new KVisel(this);

			track_ = new KTouchGridIndicator(this);
			arrow_near_ = new KTouchGridIndicator(this);
			arrow_far_ = new KTouchGridIndicator(this);

			CONFIG::debug
			{
				camera_.name		= "grid::camera";
				track_.name			= "grid::track";
				arrow_near_.name	= "grid::left arror";
				arrow_far_.name		= "grid::right arrow";
			}

			speed_limit_ = drag_threshold_ * 2;
			//?speed_limit_ = KUILayer.instance.drag_threshold_ * 2.5;

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
//.............................................................................
		override public function destroy(): void
		{
			super.destroy();
			layout_.dispose();
			layout_ = null;
			camera_ = null;
			track_ = null;
			tap_list_.length = 0;
			tap_list_ = null;
			arrow_near_ = null;
			arrow_far_ = null;
			EnterFrameSignal.instance.remove(on_Enter_Frame);
		}
//.............................................................................
//.............................................................................
		/* INTERFACE com.gs.ui.ILayoutContainer */
		public function get layout(): ILayout
		{
			return layout_;
		}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
		private function on_Resize(e: Event): void
		{
			//if (1100101 == tag_)
				//Log("grid::resize " + width_ + "x" + height_);
			cam_rect_.width = width_;
			cam_rect_.height = height_;

			update_Layout();
		}
//.............................................................................
//.............................................................................
		public function get item_count(): int
		{
			return item_list_ != null ? item_list_.count: 0;
		}
//.............................................................................
//.............................................................................
//.............................................................................
		public function update_Layout(): void
		{
			if (null == item_view_)
				return;

			if (is_dragged_ && (alt_item_ != null))
			{//:don't move item out of tap
				pending_update_ = true;
				return;
			}
			alt_item_ = null;
			pending_update_ = false;

			calc_Item_Pix_Size();
			set_View_Count();

			if (!is_dragged_)
				fix_Camera_Pos();

			update_View();

			layout_.on_Resize(this, width_, height_, 0, null);
		}
//.............................................................................
		private function update_View(): void
		{
			place_Items();
			update_Rect();
			update_Track();
			update_Arrows();
		}
//.............................................................................
		private function calc_Item_Pix_Size(): void
		{
			total_pix_size_ = 0;
			item_width_  = 0;
			item_height_ = 0;
			cols_ = user_cols_;
			rows_ = user_rows_;

			var count: int = item_count + dummy_item_count_;
			if (count <= 0)
			{
				//Log("grid is empty");
				return;
			}

			var w: Number = width_ - x_border_ * 2;
			if (w < 1)
				w = 1;
			var h: Number = height_ - y_border_ * 2;
			if (h < 1)
				h = 1;

			if (AUTO_FIT == cols_)
			{
				if (user_item_width_ > 0)
				{
					cols_ = Math.floor(w / (user_item_width_ + x_spacing_));
					if (cols_ <= 0)
						cols_ = 1;
				}
				else
				{
					CONFIG::debug
					{
						throw new Error("AUTO_FIT conflict on x");
					}
				}
			}
			if (AUTO_FIT == rows_)
			{
				if (user_item_height_ > 0)
				{
					//if (1100101 == tag_)
						//Log("********* h / (user_item_height_ + y_spacing_)=" + (h / (user_item_height_ + y_spacing_)));
					rows_ = Math.floor(h / (user_item_height_ + y_spacing_));
					if (rows_ <= 0)
						rows_ = 1;
				}
				else
				{
					CONFIG::debug
					{
						throw new Error("AUTO_FIT conflict on y");
					}
				}
			}
			if (cols_ <= 0 || rows_ <= 0)
			{
				//Log("grid::rows_=" + rows_ + "; cols_=" + cols_);
				return;
			}
			item_width_ = w / cols_;
			item_height_ = h / rows_;

			//===============================================================

			var num_cells: int = rows_ * cols_;
			if (MODE_HORZ == mode_)
			{
				if (num_cells < count)//:adjust count for drag
					++cols_;
				overdrag_limit_ = Math.min(64 * hi_res_factor_, item_width_ * 0.75);
				var total_col_count: int = Math.floor(count / rows_);
				if (count % rows_)
					++total_col_count;
				if (total_col_count < user_cols_)
					total_col_count = user_cols_;
				total_pix_size_ = item_width_ * total_col_count;
			}
			else
			{
				if (num_cells < count)//:adjust count for drag
					++rows_;
				overdrag_limit_ = Math.min(64 * hi_res_factor_, item_height_ * 0.75);
				var total_row_count: int = Math.floor(count / cols_);
				if (count % cols_)
					++total_row_count;
				if (total_row_count < user_rows_)
					total_row_count = user_rows_;
				total_pix_size_ = item_height_ * total_row_count;
			}
			//Log("grid::size=" + w +"x" + h + "; rows_=" + rows_ + "; cols_=" + cols_);
		}
//.............................................................................
		private function set_View_Count(): void
		{
			var num_cells: int = rows_ * cols_;
			if (num_cells_ == num_cells)
				return;
			num_cells_ = num_cells;
			//Log("grid::num_cells_=" + num_cells_);
			var nc: int = camera_.numChildren;
			var child: IGridItemView;
			if (nc < num_cells)
			{
				for (var k: int = num_cells - nc; k > 0; --k)
				{//:create
					new item_view_(camera_);
				}
			}
			else if (nc > num_cells)
			{//:hide
				for (var j: int = nc - 1; j >= num_cells; --j)
				{
					child = camera_.getChildAt(j) as IGridItemView;
					child.resize_Item(0, 0, 0, 0);
					child.update_Item(null, 0);
				}
			}
		}
//.............................................................................
		private function fix_Camera_Pos(): void
		{
			var threshold: Number = drag_threshold_;
			if (MODE_HORZ == mode_)
			{
				var newX: Number = cam_rect_.x;
				var maxX: Number = Math.max(0, total_pix_size_ - width_);
				if (newX < threshold)
					newX = 0;
				else if (newX + threshold > maxX)
					newX = maxX;
				cam_rect_.x = newX;
			}
			else
			{
				var newY: Number = cam_rect_.y;
				var maxY: Number = Math.max(0, total_pix_size_ - height_);
				if (newY < threshold)
					newY = 0;
				else if (newY + threshold > maxY)
					newY = maxY;
				cam_rect_.y = newY;
			}
		}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
		private function place_Items(): void
		{
			//Log('');
			//Log('place items ' + num_cells_);
			var k: int = 0;
			var i: int;
			var j: int;
			var idx: int;
			var nx: Number;
			var ny: Number;

			if (MODE_HORZ == mode_)
			{
				var cx: int = cam_rect_.x;
				if (cx < 0)
					cx = 0;
				var first_col: int = Math.floor(cx / item_width_);
				var col_d: int = (Math.floor(cx / (item_width_ * cols_)) * cols_) - first_col + cols_;
				var add_x: int = 0;
				if (total_pix_size_ < width_)
				{
					switch(align_)
					{
					case TAlign.CENTER:
						add_x = (width_ - total_pix_size_) * .5;
						break;
					case TAlign.FAR:
						add_x = width_ - total_pix_size_;
						break;
					}
				}
				for (i = 0; i < cols_; ++i)
				{
					var ix : int = first_col + (col_d + i) % cols_;
					nx = ix * item_width_ + x_border_ + add_x;
					for (j = 0; j < rows_; ++j)
					{
						ny = j * item_height_ + y_border_;
						//Log("new idx=" + new_idx);
						idx = ix * rows_ + j;
						place_Item(idx, nx, ny, k);
						++k;
					}
				}
			}
			else
			{
				var cy: int = cam_rect_.y;
				if (cy < 0)
					cy = 0;
				var first_row: int = Math.floor(cy / item_height_);
				var row_d: int = (Math.floor(cy / (item_height_ * rows_)) * rows_) - first_row + rows_;
				var add_y: int = 0;
				if (total_pix_size_ < height_)
				{
					switch(align_)
					{
					case TAlign.CENTER:
						add_y = (height_ - total_pix_size_) * .5;
						break;
					case TAlign.FAR:
						add_y = height_ - total_pix_size_;
						break;
					}
				}
				for (j = 0; j < rows_; ++j)
				{
					var iy : int = first_row + (row_d + j) % rows_;
					ny = iy * item_height_ + y_border_ + add_y;
					for (i = 0; i < cols_; ++i)
					{
						nx = i * item_width_ + x_border_;
						idx = iy * cols_ + i;
						place_Item(idx, nx, ny, k);
						++k;
					}
				}
			}
		}
//.............................................................................
		private function place_Item(idx: int, nx: int, ny: int, k: int): void
		{
			if (k >= num_cells_)
				return;
			var nw: Number = user_item_width_;
			var nh: Number = user_item_height_;
			if (AUTO_FIT == user_item_width_)
				nw = item_width_ - x_spacing_;
			if (AUTO_FIT == user_item_height_)
				nh = item_height_ - y_spacing_;

			switch(item_x_align_)
			{
			case TAlign.CENTER:
				nx += (item_width_ - nw) * .5;
				break;
			case TAlign.FAR:
				nx += item_width_ - nw;
				break;
			}
			switch(item_y_align_)
			{
			case TAlign.CENTER:
				ny += (item_height_ - nh) * .5;
				break;
			case TAlign.FAR:
				ny += item_height_ - nh;
				break;
			}

			var child: IGridItemView = camera_.getChildAt(k) as IGridItemView;
			child.resize_Item(nx, ny, nw, nh);//:must be above
			child.update_Item(item_list_, idx);//:update may calc text size using nw, nh
			//Log('place item[' +idx +'] at ' + nx + ":" + ny + "; " + nw + "x" + nh);
		}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
		//override public function draw(): void
		//{
			//super.draw();
			//:4debug
		//}
//.............................................................................
		public function get x_spacing(): int { return x_spacing_; }
		public function set x_spacing(value: int): void
		{
			if (x_spacing_ != value)
			{
				x_spacing_ = value;
				update_Layout();
			}
		}
		public function get y_spacing(): int { return y_spacing_; }
		public function set y_spacing(value: int): void
		{
			if (y_spacing_ != value)
			{
				y_spacing_ = value;
				update_Layout();
			}
		}
//.............................................................................
		public function get item_x_align(): String { return item_x_align_; }
		public function set item_x_align(value: String): void
		{
			if (item_x_align_ != value)
			{
				item_x_align_ = value;
				update_Layout();
			}
		}
		public function get item_y_align(): String { return item_y_align_; }
		public function set item_y_align(value: String): void
		{
			if (item_y_align_ != value)
			{
				item_y_align_ = value;
				update_Layout();
			}
		}
//.............................................................................
//.............................................................................
//.............................................................................
		public function scroll(scroll_kind: int, force_update: Boolean = false): void
		{
			//switch(scroll_kind)
			//{
			//case TScroll.HOME:
				//if (MODE_HORZ == mode_)
				//{
					//cam_rect_.x = 0;
				//}
				//else
				//{
					//cam_rect_.y = 0;
				//}
				//anim_pos_ = 0;
				//v0_ = 0;
				//break;
			//case TScroll.END:
				//TODO fix me
				//break;
			//default:
				//return;
			//}
			if(scroll_kind == TScroll.HOME)
				set_Scroll_Pos(0, force_update);
		}
//.............................................................................
		public function set_Scroll_Pos(pos: int, force_update: Boolean = false): void
		{
			if (MODE_HORZ == mode_)
			{
				cam_rect_.x = pos;
			}
			else
			{
				cam_rect_.y = pos;
			}
			anim_pos_ = pos;
			v0_ = 0;

			if (is_dragged_)
			{
				is_dragged_ = false;
				pending_update_ ||= force_update;
				finish_Drag(false);
				return;
			}

			if (force_update)
				update_Layout();
			else
				update_View();
		}
//.............................................................................
		public function get_Scroll_Pos(): int
		{
			return anim_pos_;
		}
//.............................................................................
		public function refresh_Visible_Items(): void
		{
			for (var i: int = 0; i < num_cells_; ++i)
			{
				var child: IGridItemView = camera_.getChildAt(i) as IGridItemView;
				child.update_Item(item_list_, -1);//:sic
			}
		}
//.............................................................................
		public function set_Item_View(view: Class): void
		{
			if (item_view_ == view)
				return;
			item_view_ = view;
			if (camera_ != null)
				camera_.destroy_Children();
		}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
		override public function set visible(value: Boolean): void
		{
			super.visible = value;
			if (!value)
			{
				remove_Capture();
				stop_Drag(0, 0, true);
			}
		}
//.............................................................................
//.............................................................................
		private function set_Capture(): void
		{
			if (!capture_set_)
			{//:set capture
				capture_set_ = true;
				CONFIG::touch
				{
					set_Touch_Capture();
				}
				CONFIG::mouse
				{
					set_Mouse_Capture();
				}
			}
		}
//.............................................................................
		private function remove_Capture(): void
		{
			if (capture_set_)
			{//:release capture
				capture_set_ = false;
				CONFIG::touch
				{
					remove_Touch_Capture();
				}
				CONFIG::mouse
				{
					remove_Mouse_Capture();
				}
			}
		}
//.............................................................................
//.............................................................................
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
			add_Listener(MouseEvent.MOUSE_DOWN, on_Mouse_Down_);
			add_Listener(MouseEvent.MOUSE_DOWN, on_Mouse_Down_, null, true);
		}
//.............................................................................
		private function set_Mouse_Capture(): void
		{
			CONFIG::touch
			{
				if (is_touch_supported_)
					return;
			}
			add_Listener(MouseEvent.MOUSE_MOVE, on_Mouse_Move);
			add_Listener(MouseEvent.MOUSE_MOVE, on_Mouse_Move_Stage, stage, false, 1);
			add_Listener(MouseEvent.MOUSE_UP,	on_Mouse_Up_Stage,	 stage, false, 1);
		}
//.............................................................................
		private function remove_Mouse_Capture(): void
		{
			CONFIG::touch
			{
				if (is_touch_supported_)
					return;
			}
			remove_Listener(MouseEvent.MOUSE_MOVE, on_Mouse_Move);
			remove_Listener(MouseEvent.MOUSE_MOVE, on_Mouse_Move_Stage, stage);
			remove_Listener(MouseEvent.MOUSE_UP,   on_Mouse_Up_Stage, stage);
		}
//.............................................................................
		private function on_Mouse_Down_(e: MouseEvent): void
		{
			//Log('grid::mouse down, target=' + e.target.name + ", phase=" + e.eventPhase);
			if (EventPhase.BUBBLING_PHASE == e.eventPhase)
				return;
			if (e.target == this)
				e.stopPropagation();
			if (is_dragged_)
				stop_Drag(0, 0, true);
			prepare_Drag(0, e.stageX, e.stageY);
		}
//.............................................................................
//.............................................................................
		private function on_Mouse_Up_Stage(e: MouseEvent): void
		{
			var id: int = 0;
			remove_Tap(id);
			if (!is_dragged_)
				return;
			e.stopPropagation();
			remove_Capture();
			var time: int = KTimer.Get();
//			trace("1: diff_time_ = " + diff_time_ + "\t diff_pos_" + diff_pos_);
			do_Drag(e.stageX, e.stageY, time, false);
//			trace("2: diff_time_ = " + diff_time_ + "\t diff_pos_" + diff_pos_);
			stop_Drag(e.stageX, e.stageY, false);
		}
//.............................................................................
		private function on_Mouse_Move(e: MouseEvent): void
		{
			if (is_dragged_)
				return;
			var id: int = 0;
			if (!can_Start_Drag(id, e.stageX, e.stageY))
				return;
			e.stopPropagation();
			var time: int = KTimer.Get();
			start_Drag(e.stageX, e.stageY, time);
		}
//.............................................................................
		private function on_Mouse_Move_Stage(e: MouseEvent): void
		{
			if (!is_dragged_ || !visible)
				return;
			var time: int = KTimer.Get();
			do_Drag(e.stageX, e.stageY, time, true);
		}
//.............................................................................
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
		private function set_Touch_Capture():void
		{
			CONFIG::mouse
			{
				if (!is_touch_supported_)
					return;
			}
			add_Listener(TouchEvent.TOUCH_MOVE, on_Touch_Move);
			add_Listener(TouchEvent.TOUCH_MOVE, on_Touch_Move_Stage, stage, false, 1);
			add_Listener(TouchEvent.TOUCH_END,	on_Touch_End_Stage,	 stage, false, 1);
		}
//.............................................................................
		private function remove_Touch_Capture():void
		{
			CONFIG::mouse
			{
				if (!is_touch_supported_)
					return;
			}
			remove_Listener(TouchEvent.TOUCH_MOVE, on_Touch_Move);
			remove_Listener(TouchEvent.TOUCH_MOVE, on_Touch_Move_Stage, stage);
			remove_Listener(TouchEvent.TOUCH_END,  on_Touch_End_Stage, stage);
		}
//.............................................................................
		private function on_Touch_Begin(e: TouchEvent): void
		{
			//Log('grid::tap ' + e.touchPointID);
			e.stopPropagation();
			if (is_dragged_)
			{
				if (e.touchPointID == first_touch_id_)
					stop_Drag(0, 0, true);
			}
			prepare_Drag(e.touchPointID, e.stageX, e.stageY);
		}
//.............................................................................
		private function on_Touch_Move(e: TouchEvent): void
		{
			if (is_dragged_)
				return;
			var id: int = e.touchPointID;
			if (!can_Start_Drag(id, e.stageX, e.stageY))
				return;
			e.stopPropagation();
			first_touch_id_ = id;
			start_Drag(e.stageX, e.stageY, e.timestamp);
		}
//.............................................................................
		private function on_Touch_Move_Stage(e: TouchEvent): void
		{
			if (!is_dragged_ || !visible)
				return;
			if (e.touchPointID == first_touch_id_)
			{
				e.stopPropagation();
				do_Drag(e.stageX, e.stageY, e.timestamp, true);
			}
		}
//.............................................................................
		private function on_Touch_End_Stage(e: TouchEvent): void
		{
			var id: int = e.touchPointID;
			remove_Tap(id);
			if (!is_dragged_)
				return;
			//Log('grid::end tap ' + e.touchPointID);
			if (id != first_touch_id_)
				return;
			do_Drag(e.stageX, e.stageY, e.timestamp, false);
			stop_Drag(e.stageX, e.stageY, false);
			if (tap_list_.length > 0)
				return;
			remove_Capture();
		}
//.............................................................................
//.............................................................................
//.............................................................................
		}//:CONFIG::touch
//.............................................................................
		private function remove_Tap(id: int): void
		{
			var idx: int = find_Tap(id);
			if (idx < 0)
				return;
			if (CONFIG::air)
			{
				tap_list_.removeAt(idx);
			}
			else
			{
				tap_list_.splice(idx, 1);
			}
		}
//.............................................................................
		private function find_Tap(id: int): int
		{
			var len: int = tap_list_.length;
			for (var i: int = 0; i < len; ++i)
			{
				if (tap_list_[i].id_ == id)
				{
					return i;
				}
			}
			return -1;
		}
//.............................................................................
		private function prepare_Drag(id: int, sX: Number, sY: Number): void
		{
			var idx: int = find_Tap(id);
			var it: TapPoint;
			if (idx < 0)
			{
				it = new TapPoint();
				it.id_ = id;
				tap_list_.push(it);
			}
			else
			{
				it = tap_list_[idx];
			}
			it.x_ = sX;
			it.y_ = sY;

			set_Capture();
			v0_ = 0;
		}
//.............................................................................
		private function can_Start_Drag(id: int, sX: Number, sY: Number): Boolean
		{
			if (drag_disabled_)
				return false;
			var idx: int = find_Tap(id);
			if (idx < 0)
			{
				//Log('grid::no tap');
				return false;
			}
			var it: TapPoint = tap_list_[idx];
			var dx: Number = Math.abs(sX - it.x_);
			var dy: Number = Math.abs(sY - it.y_);
			var threshold: Number = drag_threshold_;
			if (MODE_HORZ == mode_)
			{
				if (dx > threshold/* || dy > drag_threshold_*/)
				{
					//Log('grid::noise');
					alt_item_ = null;
					return true;
				}
				//Log('grid::take over, dx=' + dx);
				if (alt_drag_enable_)
				{
					if (dy > threshold)
					{
						alt_item_ = find_Item_By_Pos(sX, sY);
						return alt_item_ != null;
					}
				}
			}
			else
			{
				if (dy > threshold/* || dx > drag_threshold_*/)
				{
					//Log('grid::noise');
					alt_item_ = null;
					return true;
				}
				//Log('grid::take over, dy=' + dy);
				if (alt_drag_enable_)
				{
					if (dx > threshold)
					{
						alt_item_ = find_Item_By_Pos(sX, sY);
						return alt_item_ != null;
					}
				}
			}
			//:TODO stop drag of another visel, if any, with same touchPointID?
			return false;
		}
//.............................................................................
		private function start_Drag(mX: Number, mY: Number, time: Number): void
		{
//			trace("start_Drag()");
			if (is_dragged_)
				return;
			is_dragged_ = true;
			prev_time_ = time;
			if (MODE_HORZ == mode_)
			{
				prev_pos_ = mX;
				if (alt_item_ != null)
				{
					alt_ofs_ = mY;
					alt_pos_ = alt_item_.y;
				}
			}
			else
			{
				if (alt_item_ != null)
				{
					alt_ofs_ = mX;
					alt_pos_ = alt_item_.x;
				}
				prev_pos_ = mY;
			}
			diff_pos_ = 0;
			diff_time_ = 0;
			if (null == alt_item_)
				track_.anim_Show(0.4, 1);//:must be above update_Arrows
			update_Track();
			update_Arrows();

			//Log('grid::bc start');
			broadcast_Event(OWNER_START_DRAG);
			//KUILayer.instance.on_Touch_Drag_Begin();
		}
//.............................................................................
		private function do_Drag(mX: Number, mY: Number, time: Number, calcDiff: Boolean): void
		{
//			trace('do drag ' + mX + "\t:" + mY + "\t time=" + KTimer.Get());
			//?var time: int = KTimer.Get();
			var gitm : KVisel;
			if (MODE_HORZ == mode_)
			{
				if (alt_item_ != null)
				{
//					trace("ALT DRAG[" + alt_drag_id_ + "]: " + (mY - alt_ofs_));	//+ gitm.y + " + "
					if ((mY - alt_ofs_) * alt_dir_ >= 0)
						alt_item_.move(alt_item_.x, alt_pos_ + (mY - alt_ofs_));
					else
						alt_item_.move(alt_item_.x, alt_pos_);
					return;
				}
				//else
				//{
				var dx: Number = prev_pos_ - mX;
				if (calcDiff)
				{
					//diff_pos_ = dx;
					//diff_time_ = time - prev_time_;
					diff_pos_  = (diff_pos_ + dx) * .5;
					diff_time_ = (diff_time_  + time - prev_time_) * .5;
					anim_time_ = time;
				}
				prev_pos_ = mX;
				prev_time_ = time;
				var newX: Number = cam_rect_.x + dx;
				var maxX: Number = Math.max(0, total_pix_size_ - width_);
				if (newX < -overdrag_limit_)
					newX = -overdrag_limit_;
				else if (newX > maxX + overdrag_limit_)
					newX = maxX + overdrag_limit_;
				cam_rect_.x = newX;
				//}
			}
			else
			{
				if (alt_item_ != null)
				{
					if ((mX - alt_ofs_) * alt_dir_ >= 0)
						alt_item_.move(alt_pos_ + (mX - alt_ofs_), alt_item_.y);
					else
						alt_item_.move(alt_pos_, alt_item_.y);
					return;
				}
				var dy: Number = prev_pos_ - mY;
				if (calcDiff)
				{
					//diff_pos_ = dy;
					//diff_time_ = time - prev_time_;
					diff_pos_  = (diff_pos_ + dy) * .5;
					diff_time_ = (diff_time_  + time - prev_time_) * .5;
					anim_time_ = time;
				}
				prev_pos_ = mY;
				prev_time_ = time;
				var newY: Number = cam_rect_.y + dy;
				var maxY: Number = Math.max(0, total_pix_size_ - height_);
				if (newY < -overdrag_limit_)
					newY = -overdrag_limit_;
				else if (newY > maxY + overdrag_limit_)
					newY = maxY + overdrag_limit_;
				cam_rect_.y = newY;
			}
			update_View();
		}
//.............................................................................
		private function stop_Drag(mX: Number, mY: Number, force: Boolean): void
		{
//			trace("stop_Drag()");
			if (!is_dragged_)
				return;
			is_dragged_ = false;

			if (alt_item_ != null)
			{
				var pull_out: Boolean;
				if (!force && (alt_item_.parent == camera_) && alt_item_.enabled)
				{
					if (MODE_HORZ == mode_)
						pull_out = Math.abs(alt_item_.y - alt_pos_) > item_height_ * 0.6;
					else
						pull_out = Math.abs(alt_item_.x - alt_pos_) > item_width_ * 0.6;
					//if (pull_out)
					//{
						//var givw : IGridItemViewEx = alt_item_ as IGridItemViewEx;
						//if (null != givw)
							//givw.pull_Out(mX, mY);
					//}
				}
				finish_Drag(pull_out);
				return;
			}
			v0_ = 0;
			if ((diff_time_ > 1e-6) && (diff_time_ < 500))//:ms
				v0_ = diff_pos_ / diff_time_;
			//Log("grid::anim START, ds=" + diff_pos_ + ", dt=" + diff_time_ + ", v0=" + v0_ + ", x=" + cam_rect_.x);
			sign_v0_ = (v0_ < 0) ? -1 : 1;
			v0_ *= sign_v0_;
			if (v0_ > speed_limit_)
				v0_ = speed_limit_;
			/*
			 * v*0.95=v-a*33;
			 * a=v*(1-0.95)/33
			*/
			a0_ = v0_ * 0.001515;

			if (MODE_HORZ == mode_)
				anim_pos_ = cam_rect_.x;
			else
				anim_pos_ = cam_rect_.y;
			return_mode_ = false;
			EnterFrameSignal.instance.add(on_Enter_Frame);

			//?broadcast_Event(new Event(OWNER_STOP_DRAG));

			//Log('');
			//Log('x=' + cam_rect_.x);
			//Log('ds = ' + diff_pos_ + ', dt =' + diff_time_ + ', v0=' + (v0_ * sign_v0_));

			//Main.instance.debug_Info('ds = ' + diff_pos_ + ', dt =' + diff_time_ + ', v0=' + (v0_ * sign_v0_));
		}
//.............................................................................
/*
After many hours of dissecting the algorithm, we concluded that Apple is in fact using magic numbers. And the magic number is: (drumroll) momentum * 0.95.

Basically, while the touch lasts, apple lets you move the screen 1:1.

On touch end Apple would get momentum by dividing number of pixels that the user had swiped, and time that the user has swiped for. If the number
of pixels was less than 10 or time was less than 0.5, momentum would be clamped to zero.

Anyways, once the momentum (speed) was known to us, they would multiply it by 0.95 in every frame, and then move the screen by that much.

So idiotically simple and elegant, that it hurts. :)
*/
//.............................................................................
		private function on_Enter_Frame(): void
		{
			//Log('on timer, ' + diff_pos_);
			if (is_dragged_)
				return;

			var time: Number = KTimer.Get();
			var dt: Number = time - anim_time_;
			anim_time_ = time;
			//?if (dt < 40)
				//?return;//:limit fps to 25??

			//:move
			var new_pos: Number = anim_pos_;
			var v: Number = v0_;
			var ds: Number = v * sign_v0_ * dt;
			new_pos += ds;
			var overdrag: Number = get_Overdrag(new_pos);
			var abs_overdrag: Number = Math.abs(overdrag);
			v -= a0_ * dt;

			if (return_mode_)
			{
				if (sign_v0_ * overdrag >= 0)
				{
					v = 0;//:stop return
				}
			}
			else if (abs_overdrag >= overdrag_limit_)
			{
				v = 0;//:stop inertia
			}
			v0_ = v;
			//Log("grid::anim CALC overdrag=" + overdrag + ", v=" + v + ", ds = " + ds + ", dt = " + dt + ", x=" + cam_rect_.x);
			//:if (v0_ * 33 < 2)
			if (v < 0.0606)
			{
//				trace("if (v < 0.001)\t // v0 =" + v0_);
				if (!return_mode_ && (abs_overdrag > 10))
				{
					return_mode_ = true;
					v0_ = abs_overdrag * 0.01;
					a0_ = v0_ * 0.001515;
					//a0_ = 0;
					sign_v0_ = (overdrag > 0) ? -1 : 1;
					//Log('x=' + cam_rect_.x);
					//Log("grid::anim RETURN, new v0=" + v * sign_v0_);
				}
				else
				{//:just stop
					//Log("grid::anim STOP, x=" + cam_rect_.x);
					finish_Drag(false);
					return;
				}
			}
			else
			{
				anim_pos_ = new_pos;
			}

			//:visualize
			if (MODE_HORZ == mode_)
			{
				if (Math.abs(anim_pos_ - cam_rect_.x) >= 1)
				{
					cam_rect_.x = anim_pos_;
					update_View();
				}
			}
			else
			{
				if (Math.abs(anim_pos_ - cam_rect_.y) >= 1)
				{
					cam_rect_.y = anim_pos_;
					update_View();
				}
			}
			//Log("grid::anim MOVE, x=" + cam_rect_.x);

//			trace("anim_pos_ = " + int(anim_pos_) + "\t dt = " + dt);
		}
/*
		private function on_Enter_Frame(): void
		{
			//Log('on timer, ' + diff_pos_);
			if (is_dragged_)
				return;

			var time: Number = KTimer.Get();
			var dt: Number = time - anim_time_;
			//if (dt < 40)
				//return;//:limit fps to 25
			if (dt < 16)
				return;//:limit fps to 60

			var a: Number = v0_ * .0015;	// 0.001;
			var dist: Number = get_Overdrag();
			var abs_dist: Number = Math.abs(dist);
			//Log('*anim, dst='+ dist);
			if (return_mode_)
				a = -v0_ * 0.01;
			else if (abs_dist > 0)
				a = 1;						//??????????/
			var v: Number = v0_ - a * dt;
			if (return_mode_)
			{
				if (sign_v0_ * dist >= 0)
					v = 0;
			}
			else if (abs_dist >= overdrag_limit_)
			{
				v = 0;
			}
			var ds: Number = v * dt;
			if (ds < 2)
			{
//				trace("if (v < 0.001)\t // v0 =" + v0_);
				if (!return_mode_ && (abs_dist > 0))
				{
					return_mode_ = true;
					v = abs_dist * 0.001;
					if (v < 0.01)
						v = 0.01;
					sign_v0_ = (dist > 0) ? -1 : 1;
					//Log('x=' + cam_rect_.x);
					//Log('return, new v0=' + v * sign_v0_);
				}
				else
				{//:just stop
					//Log('grid::anim STOP, x=' + cam_rect_.x);
					finish_Drag(false);
					return;
				}
			}

			//:visualize
			if (MODE_HORZ == mode_)
			{
				if (Math.abs(anim_pos_ - cam_rect_.x) >= 1)
				{
					cam_rect_.x = anim_pos_;
					update_View();
				}
			}
			else
			{
				if (Math.abs(anim_pos_ - cam_rect_.y) >= 1)
				{
					cam_rect_.y = anim_pos_;
					update_View();
				}
			}
			//Log('move ' + cam_rect_.x);

			//:move
			//Log('dt = ' + dt + ', v=' + v);
			anim_pos_ += ds * sign_v0_;
			anim_time_ = time;
			v0_ = v;
//			trace("anim_pos_ = " + int(anim_pos_) + "\t dt = " + dt);
		}
*/
//.............................................................................
		private function finish_Drag(pull_out: Boolean): void
		{
			EnterFrameSignal.instance.remove(on_Enter_Frame);
			track_.anim_Hide(2, 0);//:must be above update_Arrows
			//Log('grid::bc stop!');
			broadcast_Event(OWNER_STOP_DRAG);//?
			//KUILayer.instance.on_Touch_Drag_End();
			if (pending_update_)
			{
				update_Layout();
				return;
			}
			if (pull_out)
				return;
			fix_Camera_Pos();
			update_View();
		}
//.............................................................................
		private function get_Overdrag(anim_pos: Number): Number
		{
			if (MODE_HORZ == mode_)
			{
				var newX: Number = anim_pos;
				if (newX < 0)
					return newX;
				var maxX: Number = Math.max(0, total_pix_size_ - width_);
				if (newX > maxX)
					return newX - maxX;
			}
			else
			{
				var newY: Number = anim_pos;
				if (newY < 0)
					return newY;
				var maxY: Number = Math.max(0, total_pix_size_ - height_);
				if (newY > maxY)
					return newY - maxY;
			}
			return 0;
		}
//.............................................................................
		private function find_Item_By_Pos(sX: Number, sY: Number): KVisel
		{
			for (var i: int = 0; i < num_cells_; ++i)
			{
				var child: KVisel = camera_.getChildAt(i) as KVisel;
				if ((null == child) || !child.enabled)
					continue;
				if (child.hitTestPoint(sX, sY, false))
					return child;
			}
			return null;
		}
//.............................................................................
		private function update_Track(): void
		{
			if (MODE_HORZ == mode_)
				track_.visible = total_pix_size_ > width_;
			else
				track_.visible = total_pix_size_ > height_;
			if (!track_.visible)
				return;
			if (MODE_HORZ == mode_)
			{
				var tx: int = (track_.width - track_.skin_w_) * Math.max(0,
					Math.min(1, cam_rect_.x / (total_pix_size_ - width_)));
				var tw: int = Clamp(800 * track_.width / total_pix_size_, 48 * hi_res_factor_, 96 * hi_res_factor_);
				if ((track_.skin_x_ != tx) || (track_.skin_w_ != tw))
				{
					track_.skin_x_ = tx;
					track_.skin_w_ = tw;
					track_.draw();
				}
			}
			else
			{
				var ty: int = (track_.height - track_.skin_h_) * Math.max(0,
					Math.min(1, cam_rect_.y / (total_pix_size_ - height_)));
				var th: int = Clamp(800 * track_.height / total_pix_size_, 48 * hi_res_factor_, 96 * hi_res_factor_);
				if ((track_.skin_y_ != ty) || (track_.skin_h_ != th))
				{
					track_.skin_y_ = ty;
					track_.skin_h_ = th;
					track_.draw();
				}
			}
		}
//.............................................................................
//.............................................................................
//.............................................................................
		private function update_Arrows(): void
		{
			if (!track_.visible)
			{
				arrow_near_.anim_Hide(0.4, 0);
				arrow_far_.anim_Hide(0.4, 0);
				return;
			}
			//var a: Number = 0.5;
			var a: Number = 1;
			if (!track_.close_anim)
				a = 0.3;
			if (MODE_HORZ == mode_)
			{
				if (cam_rect_.x > 0)
					arrow_near_.anim_Show(2, a);
				else
					arrow_near_.anim_Hide(1, 0);
				if (cam_rect_.x < total_pix_size_ - width_)
					arrow_far_.anim_Show(1, a);
				else
					arrow_far_.anim_Hide(1, 0);
			}
			else
			{
				if (cam_rect_.y > 0)
					arrow_near_.anim_Show(2, a);
				else
					arrow_near_.anim_Hide(1, 0);
				if (cam_rect_.y < total_pix_size_ - height_)
					arrow_far_.anim_Show(1, a);
				else
					arrow_far_.anim_Hide(1, 0);
			}
		}
//.............................................................................
		private function update_Rect(): void
		{
			if (alt_drag_enable_)
			{//:workaround - clip is disabled!!!
				camera_.x = -cam_rect_.x;
				camera_.y = -cam_rect_.y;
			}
			else
			{
				camera_.scrollRect = cam_rect_;
			}
		}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	}
}
class TapPoint
{
	public var id_: int;
	public var x_: Number;
	public var y_: Number;

	public function TapPoint()
	{}
}