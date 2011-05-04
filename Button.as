package com.smp.components
{
	import flash.display.Sprite;
	import flash.filters.BitmapFilter;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.display.Shape;
	import flash.text.TextFormat;
	import flash.events.MouseEvent;
	
	import com.smp.common.text.TextUtils;
	import com.smp.common.display.ShapeUtils;
	
	
	public class Button extends Sprite
	{
		private var _txtfl:TextField;
		private var _bg:Shape;
		private var _bgOver:Shape;
		private var _bgWidth:Number;
		private var _bgHeight:Number;
		private var _marginTop:Number;
		private var _marginRight:Number;
		
		public function Button(label:String, fontFamily:String = "", fontSize:uint = 0, fontColor:uint = 0, bold:Boolean = false, bgWidth:Number = 0, bgHeight:Number = 0, bgColors:Array = null, bgRatios:Array = null, bgOverColors:Array = null, bgOverRatios:Array = null, marginTop:Number = 0, marginRight:Number = 0, border:Number = 1, borderColor:uint = 0xcccccc, labelEmboss:Boolean = true, bgShadow:Boolean = false ) {
			
			if (fontFamily == "") {
				fontFamily = "Verdana";
			}
			if (fontSize == 0) {
				fontSize = 12;
			}
			if (fontColor == 0) {
				fontColor = 0x000000;
			}
			
			if (bgColors == null) {
				bgColors = [0xffffff, 0xdadada]
			}
			if (bgRatios == null) {
				bgRatios = [0,255]
			}
			if (bgOverColors == null) {
				bgOverColors = [0xffffff, 0xd0d0d0]
			}
			if (bgOverRatios == null) {
				bgOverRatios = [0,200]
			}
			if (marginTop == 0) {

				_marginTop = 3;
			}else {
				_marginTop = marginTop;
			}
			if (marginRight == 0) {
				_marginRight = 8;
			}else {
				_marginRight = marginRight;
			}
			
			_txtfl = TextUtils.createTextField(label, new TextFormat(fontFamily, fontSize, fontColor, bold));
			_txtfl.x = _marginRight;
			_txtfl.y = _marginTop;

			
			if(labelEmboss){
				var dsfl:BitmapFilter = new DropShadowFilter(1, 45, 0xffffff, 1, 1, 1);
				_txtfl.filters = [dsfl];
			}
			addChild(_txtfl);
			
			if (bgWidth == 0) {

				_bgWidth = _txtfl.width + _marginRight*2;
			}else {
				_bgWidth = bgWidth;
			}
			if (bgHeight == 0) {
				_bgHeight = _txtfl.height + _marginTop*2;
			}else {
				_bgHeight = bgHeight
			}
			
			
			_bg = ShapeUtils.createGradientRectangle(_bgWidth, _bgHeight, bgColors, [1,1], bgRatios, -1, 0, 0, border, borderColor);
			_bgOver = ShapeUtils.createGradientRectangle(_bgWidth ,_bgHeight, bgOverColors, [1,1], bgOverRatios, -1, 0, 0, border, borderColor);

			
			if(bgShadow){
				var bgSh:BitmapFilter = new DropShadowFilter(3, 45, 0x000000, 0.3, 3, 3);
				_bg.filters = [bgSh];
				_bgOver.filters = [bgSh];
			}
			
			addChildAt(_bg,0);
			
			this.buttonMode = true;
			this.addEventListener(MouseEvent.MOUSE_OVER, onOver);
			this.addEventListener(MouseEvent.MOUSE_OUT, onOut);
			
		}
		
		public function set label(value:String):void
		{
			_txtfl.text = value;			
			/*
			_bgWidth = _txtfl.width + _marginRight * 2;
			_bgHeight = _txtfl.height + _marginTop * 2;
			_bg.width = _bgWidth;
			_bgOver.width = _bgWidth;
			_bg.height = _bgHeight;
			_bgOver.height = _bgHeight;
			*/

			
		}
		
		protected function onOver(evt:MouseEvent):void{
			removeChild(_bg);
			addChildAt(_bgOver,0);
		}
		
		protected function onOut(evt:MouseEvent):void{
			removeChild(_bgOver);
			addChildAt(_bg,0);
		}
	}
}