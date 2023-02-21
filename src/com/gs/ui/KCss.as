package com.gs.ui
{
	import flash.text.StyleSheet;

	//http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/StyleSheet.html
/*

color			color 			Only hexadecimal color values are supported. Named colors (such as blue) are not supported. Colors are written in the following format: #FF0000.
display 		display 		Supported values are inline, block, and none.
font-family 	fontFamily 		A comma-separated list of fonts to use, in descending order of desirability. Any font family name can be used. If you specify a generic font name, it is converted to an appropriate device font. The following font conversions are available: mono is converted to _typewriter, sans-serif is converted to _sans, and serif is converted to _serif.
font-size 		fontSize 		Only the numeric part of the value is used. Units (px, pt) are not parsed; pixels and points are equivalent.
font-style 		fontStyle 		Recognized values are normal and italic.
font-weight 	fontWeight 		Recognized values are normal and bold.
kerning 		kerning 		Recognized values are true and false. Kerning is supported for embedded fonts only. Certain fonts, such as Courier New, do not support kerning. The kerning property is only supported in SWF files created in Windows, not in SWF files created on the Macintosh. However, these SWF files can be played in non-Windows versions of Flash Player and the kerning still applies.
leading 		leading 		The amount of space that is uniformly distributed between lines. The value specifies the number of pixels that are added after each line. A negative value condenses the space between lines. Only the numeric part of the value is used. Units (px, pt) are not parsed; pixels and points are equivalent.
letter-spacing 	letterSpacing 	The amount of space that is uniformly distributed between characters. The value specifies the number of pixels that are added after each character. A negative value condenses the space between characters. Only the numeric part of the value is used. Units (px, pt) are not parsed; pixels and points are equivalent.
margin-left 	marginLeft 		Only the numeric part of the value is used. Units (px, pt) are not parsed; pixels and points are equivalent.
margin-right 	marginRight 	Only the numeric part of the value is used. Units (px, pt) are not parsed; pixels and points are equivalent.
text-align 		textAlign 		Recognized values are left, center, right, and justify.
text-decoration	textDecoration 	Recognized values are none and underline.
text-indent 	textIndent 		Only the numeric part of the value is used. Units (px, pt) are not parsed; pixels and points are equivalent.

*/
/*
a:link {
	text-decoration: underline;
	color: #666666;
}
a:hover {
	text-decoration: underline;
	color: #FF9900;
}
*/
/*
display:'inline'
*/

	public class KCss extends StyleSheet
	{
		public var factor_: Number;
		public var nobold_: Boolean;
		static public var def_font_family_: String;

		public function KCss(factor: Number = 1, nobold: Boolean = false)
		{
			super();
			factor_ = factor;
			nobold_ = nobold;
		}

		override public function setStyle(styleName: String, styleObject: Object): void
		{
			if ((factor_ != 1) && ("fontSize" in styleObject))
				styleObject.fontSize = Math.round(styleObject.fontSize * factor_);
			if (nobold_ && (styleObject.fontWeight == "bold"))
				styleObject.fontWeight = "normal";
			if (!("fontFamily" in styleObject) && (def_font_family_ !== null))
				styleObject.fontFamily = def_font_family_;
			//Log("css::setStyle(" + styleName + ", " + JSON.stringify(styleObject) + ")");
			super.setStyle(styleName, styleObject);
		}
	}
}