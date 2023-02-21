package com.gs.ui
{

	public class KLayout implements ILayout
	{
		protected var object_: Vector.<TLayoutData> = new Vector.<TLayoutData>();
		protected var last_used_: TLayoutData = null;

		protected var clamp_mode__: int = CLAMP_X | CLAMP_Y | CLAMP_W | CLAMP_H;

		static public const CLAMP_NONE: int			= 0x00;
		static public const CLAMP_X: int			= 0x01;
		static public const CLAMP_Y: int			= 0x02;
		static public const CLAMP_W: int			= 0x04;
		static public const CLAMP_H: int			= 0x08;
		static public const CLAMP_BY_UI_LAYER: int	= 0x10;

		public function KLayout()
		{}

		public function dispose(): void
		{
			object_.length = 0;
			object_ = null;
			last_used_ = null;
		}

		public function find_Data(visel: KVisel): TLayoutData
		{
			if (null == visel)
			{
				//trace("null visel");
				return null;
			}
			if ((last_used_ != null) && (last_used_.visel_ == visel))
				return last_used_;//:cache pair set_Pixel/Percent
			var len: int = object_.length;
			for (var i: int = 0; i < len; ++i)
			{
				var t: TLayoutData = object_[i];
				if (t.visel_ == visel)
				{
					last_used_ = t;
					return last_used_;
				}
			}
			last_used_ = new TLayoutData();
			object_.push(last_used_);
			last_used_.visel_ = visel;
			return last_used_;
		}

		public function set_Pixel_Rect(visel: KVisel, nX: Number, nY: Number, nX2: Number, nY2: Number): void
		{
			var data: TLayoutData = find_Data(visel);
			data.pix_x_  = nX;
			data.pix_y_  = nY;
			data.pix_x2_ = nX2;
			data.pix_y2_ = nY2;
		}

		public function set_Percent_Rect(visel: KVisel, nX: Number, nY: Number, nX2: Number, nY2: Number): void
		{
			var data: TLayoutData = find_Data(visel);
			data.perc_x_  = nX  * 0.01;
			data.perc_y_  = nY  * 0.01;
			data.perc_x2_ = nX2 * 0.01;
			data.perc_y2_ = nY2 * 0.01;
		}

		public function set_Clamp_Mode(visel: KVisel, mode: int): void
		{
			var data: TLayoutData = find_Data(visel);
			data.clamp_mode_ = mode;
		}

		public function set_Layout_Clamp_Mode(mode: int): void
		{
			clamp_mode__ = mode;
		}

		public function on_Resize(owner: KVisel, owner_w: Number, owner_h: Number, tween_time: Number, tween_style: Object): void
		{
			var len: int = object_.length;
			for (var i: int = 0; i < len; )
			{
				var obj: TLayoutData = object_[i];
				if (obj.visel_.parent != owner)
				{
					if (CONFIG::air)
					{
						object_.removeAt(i);
					}
					else
					{
						object_.splice(i, 1);
					}
					--len;
				}
				else
				{
					var nx: Number = obj.perc_x_ * owner_w + obj.pix_x_;
					var ny: Number = obj.perc_y_ * owner_h + obj.pix_y_;

					var nw: Number = obj.perc_x2_ * owner_w + obj.pix_x2_ - nx;
					var nh: Number = obj.perc_y2_ * owner_h + obj.pix_y2_ - ny;

					var obj_mode: int = obj.clamp_mode_ & clamp_mode__;
					if (obj_mode != 0)
					{
						//if (clamp_mode__ & CLAMP_BY_UI_LAYER)
						//{
							//owner_w = KUILayer.instance.width;
							//owner_h = KUILayer.instance.height;
						//}
						if (obj_mode & CLAMP_X)
							nx = KVisel.Clamp(nx, 0, owner_w);
						if (obj_mode & CLAMP_Y)
							ny = KVisel.Clamp(ny, 0, owner_h);
						if (obj_mode & CLAMP_W)
							nw = KVisel.Clamp(nw, 0, owner_w - nx);
						if (obj_mode & CLAMP_H)
							nh = KVisel.Clamp(nh, 0, owner_h - ny);
					}
					obj.visel_.tween(nx, ny, nw, nh, tween_time, tween_style);

					/*
					:conflicted with override public function tween :(
					var px1: Number	= obj.perc_x_;
					var px2: Number	= obj.perc_x2_;
					var py1: Number	= obj.perc_y_;
					var py2: Number	= obj.perc_y2_;
					px1 *= owner_w;
					px2 *= owner_w;
					py1 *= owner_h;
					py2 *= owner_h;
					var nx1: Number	= obj.pix_x_;
					var nx2: Number	= obj.pix_x2_;
					var ny1: Number	= obj.pix_y_;
					var ny2: Number	= obj.pix_y2_;
					nx1 += px1;
					nx2 += px2;
					ny1 += py1;
					ny2 += py2;

					if (clamp_mode_)
					{
						nx1 = KVisel.Clamp(nx1, 0, owner_w);
						nx2 = KVisel.Clamp(nx2, 0, owner_w);
						ny1 = KVisel.Clamp(ny1, 0, owner_h);
						ny2 = KVisel.Clamp(ny2, 0, owner_h);
					}

					var tween_data: Object = { ease: tween_style };
					if (nx1 === nx1)
					{//:has left
						tween_data.x = nx1;
						if (nx2 === nx2)//:has right
							tween_data.width = nx2 - nx1;
					}
					else
					{//:no left
						if (nx2 === nx2)//:has right
							tween_data.x = nx2 - obj.visel_.width;
					}
					if (ny1 === ny1)
					{//:has top
						tween_data.y = ny1;
						if (ny2 === ny2)//:has bottom
							tween_data.height = ny2 - ny1;
					}
					else
					{//:no top
						if (ny2 === ny2)//:has bottom
							tween_data.y = ny2 - obj.visel_.height;
					}

					TweenLite.to(obj.visel_, tween_time, tween_data);
					*/
					++i;
				}
				//if (obj.visel_.tag_ == 1100101)
					//trace("x =" + nx + ", y=" + ny + "; w=" + w + ", h=" + h +
						//", ow=" + owner_w + ", oh=" + owner_h);
			}
		}
	}

}