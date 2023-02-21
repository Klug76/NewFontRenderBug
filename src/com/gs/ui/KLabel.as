// label.text
// $Id: KLabel.as 2635 2023-02-19 15:57:42Z klug $
package com.gs.ui
{
	import flash.display.DisplayObjectContainer;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.StyleSheet;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.FullScreenEvent;

// UNICODE RANGE REFERENCE
/*
#
Default ranges
U+0020-U+0040, // Punctuation, Numbers
U+0041-U+005A, // Upper-Case A-Z
U+005B-U+0060, // Punctuation and Symbols
U+0061-U+007A, // Lower-Case a-z
U+007B-U+007E, // Punctuation and Symbols

Extended ranges (if multi-lingual required)
U+0080-U+00FF, // Latin I
U+0100-U+017F, // Latin Extended A
U+0400-U+04FF, // Cyrillic
U+0370-U+03FF, // Greek
U+1E00-U+1EFF, // Latin Extended Additional
*/

	public class KLabel extends KBaseLabel
	{
		//[Embed(source = '../../../std/assets/pf_ronda_seven.ttf', fontName = "MyFont",
		//fontWeight = 'regular',
		//unicodeRange = 'U+0020-U+0040,U+0041-U+005A,U+005B-U+0060,U+0061-U+007A,U+007B-U+007E',
		//mimeType = 'application/x-font'))]
		//public static const MyFont: Class;

		protected var tf_: TextField;
		protected var text_: String = "";
		protected var format_: TextFormat;
		protected var html_: Boolean = false;
		protected var auto_size_: Boolean = false;
		protected var h_align_: String = TAlign.CENTER;
		protected var v_align_: String = TAlign.CENTER;
		protected var text_width_: Number = 0;
		protected var text_height_: Number = 0;
		private var text_size_valid_for_: Number = 0;

		CONFIG::local_test
		{
			public static var debug_draw_count_: int = 0;
		}
	//.............................................................................
		public function KLabel(owner: DisplayObjectContainer,
							   txt: String = "",
							   fmt: TextFormat = null,
							   nx: Number = 0, ny: Number = 0, nw: Number = 0, nh: Number = 0)
		{
			super(owner, nx, ny, nw, nh);
			init(txt, fmt);
		}
//.............................................................................
		private function init(txt: String, fmt: TextFormat): void
		{
			text_ = txt;
			if ((txt != null) && (txt.length > 3) && (txt.indexOf("<") == 0))
				html_ = true;

			tf_ = new TextField();
			tf_.selectable = false;
			tf_.mouseEnabled = false;
			tf_.tabEnabled = false;
			tf_.width = width_;
			//?tf_.height = height_;
			//?tf_.autoSize = TextFieldAutoSize.LEFT;

			set_Default_Text_Format(fmt);

			update_TextField();

			addChild(tf_);
			mouseEnabled = mouseChildren = false;
		}
//.............................................................................
		public function get text_Field(): TextField { return tf_ };
//.............................................................................
		public function get text_width(): Number { return text_width_ };
		public function get text_height(): Number { return text_height_ };
//.............................................................................
		public function update_TextField(): void
		{
			if (html_)
			{
				tf_.htmlText = text_;
			}
			else
			{
				tf_.text = text_;
			}
			text_size_valid_for_ = 0;
		}
//.............................................................................
//.............................................................................
		public function get text(): String { return text_ };
		public function set text(value: String): void
		{
			if (text_ != value)
			{
				text_ = value;
				update_TextField();
				invalidate();
				CONFIG::debug
				{
					validate_Text();
				}
			}
		}
//.............................................................................
		private function validate_Text(): void
		{
			if (!html_)
				return;
			if ((null == text_) || (text_.length <= 0))
				return;
			try
			{
				var s: String = text_.split("<br>").join("");
				var xml: XML = new XML("<p>" + s + "</p>");
			}
			catch (err: Error)
			{
				trace("WARNING: bad html '" + text_ + "'");
			}
		}
//.............................................................................
		override public function update_Text(value: String): void
		{
			if (text_ != value)
			{
				text_ = value;
				update_TextField();
			}
		}
//.............................................................................
		public function get html(): Boolean { return html_; }
		public function set html(value: Boolean): void
		{
			if (html_ != value)
			{
				html_ = value;
				update_TextField();
				invalidate();
			}
		}
//.............................................................................
		public function get text_Format(): TextFormat { return format_; };
		public function set text_Format(value: TextFormat): void
		{
			set_Default_Text_Format(value);
			tf_.setTextFormat(format_);
			update_TextField();
			invalidate();
		}
//.............................................................................
		private function set_Default_Text_Format(value: TextFormat): void
		{
			if (null == value)
			{
				format_ = new TextFormat();
				format_.font = "Courier New";
				format_.size = 16;
			}
			else
			{
				format_ = value;
				if (value.font)
					tf_.embedFonts = value.font.charAt(0) == "#";
			}
			tf_.defaultTextFormat = format_;
		}
//.............................................................................
//.............................................................................
		public function set css(value: StyleSheet): void
		{
			tf_.styleSheet = value;
			html_ = true;//!?
			update_TextField();
			invalidate();
		}
//.............................................................................
//.............................................................................
		public function get auto_size(): Boolean { return auto_size_ };
		public function set auto_size(value: Boolean): void
		{
			if (auto_size_ != value)
			{
				auto_size_ = value;
				tf_.autoSize = value ? TextFieldAutoSize.LEFT : TextFieldAutoSize.NONE;
				update_TextField();
				invalidate();
			}
		}
//.............................................................................
//.............................................................................
//.............................................................................
		public function get h_align(): String { return h_align_ };
		public function set h_align(value: String): void
		{
			if (h_align_ != value)
			{
				h_align_ = value;
				invalidate();
			}
		}
//.............................................................................
//.............................................................................
		public function get v_align(): String { return v_align_ };
		public function set v_align(value: String): void
		{
			if (v_align_ != value)
			{
				v_align_ = value;
				invalidate();
			}
		}
//.............................................................................
		override public function draw(): void
		{
			CONFIG::local_test
			{
				++debug_draw_count_;
			}
			if (auto_size_)
			{
				text_width_ = tf_.width;
				text_height_ = tf_.height;
				width_ = Math.round(text_width_ + 0.5);
				height_ = Math.round(text_height_ + 0.5);
				//?resize(text_width_, text_height_);
				super.draw();
				return;
			}
			//if (tag_ == 1100101)
				//trace("width_ =", width_);
			super.draw();
			if (text_size_valid_for_ != width_)
			{
				if ((h_align_ != TAlign.NEAR) || (v_align_ != TAlign.NEAR))
				{
					text_size_valid_for_ = width_;
					tf_.width = width_;
					tf_.autoSize = TextFieldAutoSize.LEFT;
					text_width_ = tf_.width;
					text_height_ = tf_.height;
					tf_.autoSize = TextFieldAutoSize.NONE;
				}
			}
			var text_x: Number;
			var text_y: Number;
			var text_w: Number = text_width_;
			var text_h: Number = text_height_;
			if (text_w > width_)
				text_w = width_;
			if (text_h > height_)
				text_h = height_;
			switch(h_align_)
			{
			case TAlign.NEAR:
				text_x = 0;
				break;
			case TAlign.CENTER:
				text_x = (width_ - text_w) * 0.5;
				break;
			case TAlign.FAR:
				text_x = width_ - text_w;
				break;
			}
			switch(v_align_)
			{
			case TAlign.NEAR:
				text_y = 0;
				break;
			case TAlign.CENTER:
				text_y = (height_ - text_h) * 0.5;
				break;
			case TAlign.FAR:
				text_y = height_ - text_h;
				break;
			}
			tf_.x = Math.round(text_x);
			tf_.y = Math.round(text_y);
			if (h_align_ != TAlign.NEAR)
			{//:use h_align
				tf_.width = Math.round(text_w + 0.5);
			}
			else
			{//:use css-align
				tf_.width = width_;
			}
			if (v_align_ != TAlign.NEAR)
			{
				tf_.height = Math.round(text_h + 0.5);
			}
			else
			{
				tf_.height = height_;
			}
		}
//.............................................................................
		CONFIG::local_test
		{
			public function get_Debug_Draw_Count(): int
			{
				return debug_draw_count_;
			}
		}
//.............................................................................
//.............................................................................
		override public function destroy(): void
		{
			super.destroy();
			tf_ = null;
		}
//.............................................................................
	}

}